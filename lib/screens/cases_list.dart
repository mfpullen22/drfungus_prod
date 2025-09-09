import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CasesListScreen extends StatefulWidget {
  const CasesListScreen({super.key});

  @override
  State<CasesListScreen> createState() => _CasesListScreenState();
}

class _CasesListScreenState extends State<CasesListScreen> {
  Future<List<Map<String, dynamic>>> fetchCases() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('cases')
          .get(const GetOptions(source: Source.serverAndCache));

      List<Map<String, dynamic>> cases = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id; // Include document ID for navigation
        return data;
      }).toList();

      // Sort cases from newest to oldest
      cases.sort((a, b) => _compareDates(b, a));

      return cases;
    } catch (e) {
      throw Exception('Failed to load cases: $e');
    }
  }

  int _compareDates(Map<String, dynamic> a, Map<String, dynamic> b) {
    // Get year as int for comparison
    int yearA = int.tryParse(a['year'] ?? '0') ?? 0;
    int yearB = int.tryParse(b['year'] ?? '0') ?? 0;

    if (yearA != yearB) {
      return yearA.compareTo(yearB);
    }

    // If years are the same, compare months
    int monthA = _getMonthNumber(a['month'] ?? '');
    int monthB = _getMonthNumber(b['month'] ?? '');

    return monthA.compareTo(monthB);
  }

  int _getMonthNumber(String monthName) {
    const monthMap = {
      'january': 1,
      'february': 2,
      'march': 3,
      'april': 4,
      'may': 5,
      'june': 6,
      'july': 7,
      'august': 8,
      'september': 9,
      'october': 10,
      'november': 11,
      'december': 12,
    };

    return monthMap[monthName.toLowerCase()] ?? 0;
  }

  String _formatDate(String month, String year) {
    return '$month $year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Case of the Month")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchCases(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                "An error occurred loading cases!",
                style: TextStyle(fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No cases available", style: TextStyle(fontSize: 16)),
            );
          }

          final cases = snapshot.data!;

          return ListView.builder(
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final caseData = cases[index];
              final title = caseData['title'] ?? 'Untitled Case';
              final month = caseData['month'] ?? '';
              final year = caseData['year'] ?? '';
              final formattedDate = _formatDate(month, year);

              return Column(
                children: [
                  ListTile(
                    title: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      formattedDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    tileColor: Theme.of(context).colorScheme.secondaryContainer,
                    onTap: () {
                      // TODO: Navigate to case details screen
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => CaseDetailsScreen(
                      //       caseData: caseData,
                      //     ),
                      //   ),
                      // );
                      print('Tapped case: ${caseData['id']}');
                    },
                  ),
                  const SizedBox(height: 2),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
