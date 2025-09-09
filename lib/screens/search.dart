// lib/screens/search.dart - Optimized version
import 'package:drfungus_prod/models/bug.dart';
import 'package:drfungus_prod/models/drug.dart';
import 'package:drfungus_prod/models/mycoses.dart';
import 'package:drfungus_prod/screens/item_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  String query = '';
  List<DocumentSnapshot> searchResults = [];
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  // Debounce timer to avoid too many searches
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void search(String input) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    if (input.trim().isEmpty) {
      setState(() {
        query = '';
        searchResults = [];
        isLoading = false;
        hasError = false;
      });
      return;
    }

    // Debounce search by 500ms to avoid excessive queries
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(input.trim().toLowerCase());
    });
  }

  Future<void> _performSearch(String searchTerm) async {
    if (searchTerm.length < 2) return; // Minimum 2 characters

    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      // Create search variants for better matching
      final searchVariants = _generateSearchVariants(searchTerm);

      // Perform parallel searches across all collections
      final futures = [
        _searchCollection('bugs', searchVariants),
        _searchCollection('drugs', searchVariants),
        _searchCollection('mycoses', searchVariants),
      ];

      final results = await Future.wait(futures);

      // Combine and deduplicate results
      final Set<String> seenIds = {};
      final List<DocumentSnapshot> allResults = [];

      for (var collectionResults in results) {
        for (var doc in collectionResults) {
          if (!seenIds.contains(doc.id)) {
            seenIds.add(doc.id);
            allResults.add(doc);
          }
        }
      }

      // Sort by relevance (exact matches first, then partial matches)
      allResults.sort(
        (a, b) =>
            _calculateRelevance(b, searchTerm) -
            _calculateRelevance(a, searchTerm),
      );

      setState(() {
        query = searchTerm;
        searchResults = allResults;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Search failed: ${e.toString()}';
      });
    }
  }

  List<String> _generateSearchVariants(String term) {
    final variants = <String>{term};

    // Add partial matches for longer terms
    if (term.length >= 3) {
      for (int i = 0; i <= term.length - 3; i++) {
        variants.add(term.substring(i, i + 3));
      }
    }

    return variants.toList();
  }

  Future<List<DocumentSnapshot>> _searchCollection(
    String collection,
    List<String> searchTerms,
  ) async {
    try {
      // Use compound queries for better performance
      final queries = <Future<QuerySnapshot>>[];

      for (String term in searchTerms.take(5)) {
        // Limit to 5 variants to avoid quota issues
        // Search in name_lower field
        queries.add(
          FirebaseFirestore.instance
              .collection(collection)
              .where('name_lower', isGreaterThanOrEqualTo: term)
              .where('name_lower', isLessThan: '${term}z')
              .limit(20)
              .get(const GetOptions(source: Source.serverAndCache)),
        );

        // Search in keywords array
        queries.add(
          FirebaseFirestore.instance
              .collection(collection)
              .where('keywords', arrayContainsAny: [term])
              .limit(20)
              .get(const GetOptions(source: Source.serverAndCache)),
        );
      }

      final results = await Future.wait(queries);
      final Set<String> seenIds = {};
      final List<DocumentSnapshot> uniqueDocs = [];

      for (var snapshot in results) {
        for (var doc in snapshot.docs) {
          if (!seenIds.contains(doc.id)) {
            seenIds.add(doc.id);
            uniqueDocs.add(doc);
          }
        }
      }

      return uniqueDocs;
    } catch (e) {
      debugPrint('Error searching collection $collection: $e');
      return [];
    }
  }

  int _calculateRelevance(DocumentSnapshot doc, String searchTerm) {
    final data = doc.data() as Map<String, dynamic>;
    final name = (data['name'] ?? '').toString().toLowerCase();
    final keywords = List<String>.from(data['keywords'] ?? []);

    int score = 0;

    // Exact name match gets highest score
    if (name == searchTerm) score += 1000;

    // Name starts with search term (very high priority)
    if (name.startsWith(searchTerm)) score += 500;

    // Any word in the name starts with search term
    final nameWords = name.split(RegExp(r'[\s,\-\(\)]'));
    for (String word in nameWords) {
      if (word.startsWith(searchTerm)) score += 300;
    }

    // Name contains search term (but not at start)
    if (name.contains(searchTerm) && !name.startsWith(searchTerm)) {
      score += 100;
    }

    // Keywords exact match
    for (String keyword in keywords) {
      final keywordLower = keyword.toLowerCase();
      if (keywordLower == searchTerm) {
        score += 750;
      } else if (keywordLower.startsWith(searchTerm)) {
        score += 400;
      } else {
        // Check if any word in keyword starts with search term
        final keywordWords = keywordLower.split(RegExp(r'[\s,\-\(\)]'));
        for (String word in keywordWords) {
          if (word.startsWith(searchTerm)) {
            score += 200;
            break;
          }
        }

        // Lower score for contains (but not starts with)
        if (keywordLower.contains(searchTerm)) {
          score += 50;
        }
      }
    }

    return score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Search Dr. Fungus')),
      body: Column(
        children: <Widget>[
          // Search Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              onChanged: search,
              decoration: InputDecoration(
                hintText: 'Search fungi, mycoses, medications...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
          ),

          // Results
          Expanded(child: _buildResultsWidget()),
        ],
      ),
    );
  }

  Widget _buildResultsWidget() {
    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => search(query),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Search for fungi, mycoses, or medications',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No results found for "$query"',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different search term',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        var document = searchResults[index];
        var data = document.data() as Map<String, dynamic>;

        // Determine collection type for icon
        IconData collectionIcon = Icons.help_outline;
        Color iconColor = Colors.grey;
        String collectionName = '';

        if (document.reference.parent.id == 'bugs') {
          collectionIcon = Icons.hub;
          iconColor = Colors.green;
          collectionName = 'Fungi';
        } else if (document.reference.parent.id == 'drugs') {
          collectionIcon = Icons.medication;
          iconColor = Colors.blue;
          collectionName = 'Medication';
        } else if (document.reference.parent.id == 'mycoses') {
          collectionIcon = Icons.medical_information;
          iconColor = Colors.red;
          collectionName = 'Mycoses';
        }

        dynamic modelData;
        if (document.reference.parent.id == 'bugs') {
          modelData = Bug.fromMap(data);
        } else if (document.reference.parent.id == 'drugs') {
          modelData = Drug.fromMap(data);
        } else if (document.reference.parent.id == 'mycoses') {
          modelData = Mycoses.fromMap(data);
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: Icon(collectionIcon, color: iconColor),
            title: Text(
              data['name'] ?? 'Unknown',
              style: TextStyle(color: iconColor, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              collectionName,
              style: TextStyle(color: iconColor, fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) =>
                      ItemDetailsScreen(name: data["name"], data: modelData),
                ),
              );
            },
          ),
        );
      },
    );
  }
}


/* // ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:drfungus_prod/models/bug.dart';
import 'package:drfungus_prod/models/drug.dart';
import 'package:drfungus_prod/models/mycoses.dart';
import 'package:drfungus_prod/screens/item_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  String query = '';
  List<DocumentSnapshot> searchResults = [];

  void search(String input) async {
    if (input.isEmpty) {
      setState(() {
        query = '';
        searchResults = [];
      });
      return;
    }

    String lowerCaseInput = input.toLowerCase();

    // Perform search in the "bugs" collection
    QuerySnapshot bugsSnapshot = await FirebaseFirestore.instance
        .collection('bugs')
        //.where('name_lower', isGreaterThanOrEqualTo: lowerCaseInput)
        //.where('name_lower', isLessThanOrEqualTo: lowerCaseInput + '\uf8ff')
        //.where('keywords', arrayContains: lowerCaseInput)
        .get();

    // Perform search in the "drugs" collection
    QuerySnapshot drugsSnapshot = await FirebaseFirestore.instance
        .collection('drugs')
        //.where('name_lower', isGreaterThanOrEqualTo: lowerCaseInput)
        //.where('name_lower', isLessThanOrEqualTo: lowerCaseInput + '\uf8ff')
        //.where('keywords', arrayContains: lowerCaseInput)
        .get();

    // Perform search in the "mycoses" collection
    QuerySnapshot mycosesSnapshot = await FirebaseFirestore.instance
        .collection('mycoses')
        //.where('name_lower', isGreaterThanOrEqualTo: lowerCaseInput)
        //.where('name_lower', isLessThanOrEqualTo: lowerCaseInput + '\uf8ff')
        //.where('keywords', arrayContains: lowerCaseInput)
        .get();

    // Combine the results from all collections
    List<DocumentSnapshot> allResults = [];
    allResults.addAll(bugsSnapshot.docs);
    allResults.addAll(drugsSnapshot.docs);
    allResults.addAll(mycosesSnapshot.docs);

    List<DocumentSnapshot> filteredResults = allResults.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final keywords = List<String>.from(data['keywords']);
      return keywords.any((keyword) => keyword.contains(lowerCaseInput));
    }).toList();

    filteredResults.sort((a, b) {
      final nameA = (a.data() as Map<String, dynamic>)['name']
          .toString()
          .toLowerCase();
      final nameB = (b.data() as Map<String, dynamic>)['name']
          .toString()
          .toLowerCase();
      return nameA.compareTo(nameB);
    });

    setState(() {
      query = input;
      searchResults = filteredResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Search Dr. Fungus')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              onChanged: (value) => search(value),
              decoration: InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                var document = searchResults[index];
                var data = document.data() as Map<String, dynamic>;

                dynamic modelData;
                if (document.reference.parent.id == 'bugs') {
                  modelData = Bug.fromMap(data);
                } else if (document.reference.parent.id == 'drugs') {
                  modelData = Drug.fromMap(data);
                } else if (document.reference.parent.id == 'mycoses') {
                  modelData = Mycoses.fromMap(data);
                }

                return ListTile(
                  title: Text(
                    data['name'] ?? '',
                    style: const TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ItemDetailsScreen(
                          name: data["name"],
                          data: modelData,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
 */