// lib/screens/search.dart - Improved version of your original
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
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void search(String input) async {
    // Cancel previous timer
    _debounceTimer?.cancel();

    if (input.isEmpty) {
      setState(() {
        query = '';
        searchResults = [];
        isLoading = false;
      });
      return;
    }

    // Debounce search by 300ms to avoid too many searches
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      await _performSearch(input);
    });
  }

  Future<void> _performSearch(String input) async {
    setState(() {
      isLoading = true;
    });

    String lowerCaseInput = input.toLowerCase();

    try {
      // Perform search in all collections (your original approach)
      QuerySnapshot bugsSnapshot = await FirebaseFirestore.instance
          .collection('bugs')
          .get(const GetOptions(source: Source.serverAndCache));

      QuerySnapshot drugsSnapshot = await FirebaseFirestore.instance
          .collection('drugs')
          .get(const GetOptions(source: Source.serverAndCache));

      QuerySnapshot mycosesSnapshot = await FirebaseFirestore.instance
          .collection('mycoses')
          .get(const GetOptions(source: Source.serverAndCache));

      // Combine the results from all collections (your original approach)
      List<DocumentSnapshot> allResults = [];
      allResults.addAll(bugsSnapshot.docs);
      allResults.addAll(drugsSnapshot.docs);
      allResults.addAll(mycosesSnapshot.docs);

      // Filter results (your original approach but improved)
      List<DocumentSnapshot> filteredResults = allResults.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] ?? '').toString().toLowerCase();
        final nameLower = (data['name_lower'] ?? '').toString().toLowerCase();
        final keywords = List<String>.from(data['keywords'] ?? []);

        // Check name fields first (primary matching)
        if (name.contains(lowerCaseInput) ||
            nameLower.contains(lowerCaseInput)) {
          return true;
        }

        // Then check keywords (secondary matching)
        return keywords.any(
          (keyword) => keyword.toLowerCase().contains(lowerCaseInput),
        );
      }).toList();

      // Sort results (your original approach)
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
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error silently or show a snackbar
    }
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
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchResults.isEmpty && query.isNotEmpty
                ? const Center(
                    child: Text(
                      "No results found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : query.isEmpty
                ? const Center(
                    child: Text(
                      "Start typing to search",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      var document = searchResults[index];
                      var data = document.data() as Map<String, dynamic>;

                      // Determine collection type for icon and styling
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
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Icon(
                            collectionIcon,
                            color: iconColor,
                            size: 32,
                          ),
                          title: Text(
                            data['name'] ?? 'Unknown',
                            style: TextStyle(
                              color: iconColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            collectionName,
                            style: TextStyle(
                              color: iconColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/* import 'package:drfungus_prod/models/bug.dart';
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
