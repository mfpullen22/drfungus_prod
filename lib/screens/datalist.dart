// lib/screens/datalist.dart - Your original logic + beautiful styling
import 'package:flutter/material.dart';
import 'package:drfungus_prod/services/firebase_service.dart';
import 'package:drfungus_prod/screens/item_details_screen.dart';

class DataListScreen extends StatefulWidget {
  const DataListScreen({this.title, this.docIds, super.key});

  final String? title;
  final List<String>? docIds;

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, int> _letterIndexMap = {};
  List<dynamic> _sortedData = [];

  Future<List<dynamic>>? getData() {
    if (widget.title == "Fungi") return getBugs();
    if (widget.title == "Medications") return getDrugs();
    if (widget.title == "Mycoses") return getMycoses();
    if (widget.title == "Trials") return getTrials();
    if (widget.title == "Active Trials") {
      return getActiveTrials(widget.docIds!);
    }
    return null;
  }

  void _generateIndexMap() {
    _letterIndexMap.clear();
    for (int i = 0; i < _sortedData.length; i++) {
      final firstLetter = _sortedData[i].name[0].toUpperCase();
      if (!_letterIndexMap.containsKey(firstLetter)) {
        _letterIndexMap[firstLetter] = i;
      }
    }
  }

  void _scrollToLetter(String letter) {
    final index = _letterIndexMap[letter];
    if (index != null) {
      // Your original working calculation
      final offset = index * 58.0; // ListTile + SizedBox
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  // Get collection-specific styling
  Map<String, dynamic> _getCollectionStyle() {
    switch (widget.title) {
      case "Fungi":
        return {
          'icon': Icons.hub,
          'color': Colors.green,
          'gradient': [Colors.green.shade50, Colors.green.shade100],
        };
      case "Medications":
        return {
          'icon': Icons.medication,
          'color': Colors.blue,
          'gradient': [Colors.blue.shade50, Colors.blue.shade100],
        };
      case "Mycoses":
        return {
          'icon': Icons.medical_information,
          'color': Colors.red,
          'gradient': [Colors.red.shade50, Colors.red.shade100],
        };
      case "Trials":
      case "Active Trials":
        return {
          'icon': Icons.biotech,
          'color': Colors.purple,
          'gradient': [Colors.purple.shade50, Colors.purple.shade100],
        };
      default:
        return {
          'icon': Icons.help_outline,
          'color': Colors.grey,
          'gradient': [Colors.grey.shade50, Colors.grey.shade100],
        };
    }
  }

  Widget _buildAlphabetHeader() {
    const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    final style = _getCollectionStyle();

    return Container(
      color: style['color'],
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: letters.length,
        itemBuilder: (context, index) {
          final letter = letters[index];
          final hasData = _letterIndexMap.containsKey(letter);

          return GestureDetector(
            onTap: hasData ? () => _scrollToLetter(letter) : null,
            child: Container(
              alignment: Alignment.center,
              width: 30,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                letter,
                style: TextStyle(
                  color: hasData ? Colors.white : Colors.white.withOpacity(0.4),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final futureData = getData();
    final style = _getCollectionStyle();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.title ?? "Data List"),
        backgroundColor: style['color'],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureData,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: style['color']),
                  const SizedBox(height: 16),
                  Text(
                    "Loading ${widget.title?.toLowerCase() ?? 'data'}...",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text("An error occurred!"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data available"));
          }

          _sortedData = List.from(snapshot.data!)
            ..sort((a, b) => a.name.compareTo(b.name));
          _generateIndexMap();

          return Column(
            children: [
              _buildAlphabetHeader(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _sortedData.length,
                  itemBuilder: (ctx, index) {
                    final item = _sortedData[index];

                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: style['gradient'],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                offset: const Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: style['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: style['color'].withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                style['icon'],
                                color: style['color'],
                                size: 20,
                              ),
                            ),
                            title: Text(
                              item.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: style['color'],
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => ItemDetailsScreen(
                                    name: item.name,
                                    data: item,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 2), // Your original spacing
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
