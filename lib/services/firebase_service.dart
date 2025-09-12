import "package:cloud_firestore/cloud_firestore.dart";
import "package:drfungus_prod/models/bug.dart";
import "package:drfungus_prod/models/case.dart";
import "package:drfungus_prod/models/drug.dart";
import "package:drfungus_prod/models/mycoses.dart";
import "package:drfungus_prod/models/trial.dart";
import 'package:azlistview/azlistview.dart';

Future<List<Bug>> getBugs() async {
  final data = await FirebaseFirestore.instance
      .collection("bugs")
      .get(const GetOptions(source: Source.serverAndCache));
  final List<Bug> bugList = [];

  for (var doc in data.docs) {
    final newBug = Bug.fromMap(doc.data());
    bugList.add(newBug);
  }

  // Add suspension tag and sort alphabetically
  for (var bug in bugList) {
    bug.tag = bug.name.isNotEmpty ? bug.name[0].toUpperCase() : "#";
  }

  // Sort alphabetically by name (case-insensitive)
  bugList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  // Apply suspension utilities for the alphabet navigation
  SuspensionUtil.sortListBySuspensionTag(bugList);
  SuspensionUtil.setShowSuspensionStatus(bugList);

  return bugList;
}

Future<List<Drug>> getDrugs() async {
  final data = await FirebaseFirestore.instance
      .collection("drugs")
      .get(const GetOptions(source: Source.serverAndCache));
  final List<Drug> drugList = [];

  for (var doc in data.docs) {
    final newDrug = Drug.fromMap(doc.data());
    drugList.add(newDrug);
  }

  // Add suspension tag and sort alphabetically
  for (var drug in drugList) {
    drug.tag = drug.name.isNotEmpty ? drug.name[0].toUpperCase() : "#";
  }

  // Sort alphabetically by name (case-insensitive)
  drugList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  // Apply suspension utilities for the alphabet navigation
  SuspensionUtil.sortListBySuspensionTag(drugList);
  SuspensionUtil.setShowSuspensionStatus(drugList);

  return drugList;
}

Future<List<Mycoses>> getMycoses() async {
  final data = await FirebaseFirestore.instance
      .collection("mycoses")
      .get(const GetOptions(source: Source.serverAndCache));
  final List<Mycoses> mycosesList = [];

  for (var doc in data.docs) {
    final newMycoses = Mycoses.fromMap(doc.data());
    mycosesList.add(newMycoses);
  }

  // Add suspension tag and sort alphabetically
  for (var mycoses in mycosesList) {
    mycoses.tag = mycoses.name.isNotEmpty ? mycoses.name[0].toUpperCase() : "#";
  }

  // Sort alphabetically by name (case-insensitive)
  mycosesList.sort(
    (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
  );

  // Apply suspension utilities for the alphabet navigation
  SuspensionUtil.sortListBySuspensionTag(mycosesList);
  SuspensionUtil.setShowSuspensionStatus(mycosesList);

  return mycosesList;
}

Future<List<Case>> getCases() async {
  try {
    final data = await FirebaseFirestore.instance
        .collection("cases")
        .get(const GetOptions(source: Source.serverAndCache));

    final List<Case> casesList = [];

    for (var doc in data.docs) {
      try {
        final docData = doc.data();
        final newCase = Case.fromMap(docData);
        casesList.add(newCase);
      } catch (e) {
        print('Error processing case document ${doc.id}: $e');
        // Continue with other documents
        continue;
      }
    }

    return casesList;
  } catch (e) {
    print('Error fetching cases: $e');
    rethrow;
  }
}

Future<List<Trial>> getTrials() async {
  final data = await FirebaseFirestore.instance
      .collection("trials")
      .get(const GetOptions(source: Source.serverAndCache));
  final List<Trial> trialsList = [];

  for (var doc in data.docs) {
    final newTrial = Trial(
      name: doc["name"],
      organization: doc["organization"],
      principal: doc["principal"],
      description: doc["description"],
      url: doc["url"],
      email: doc["email"],
    );
    trialsList.add(newTrial);
  }

  for (var trial in trialsList) {
    trial.tag = trial.name.isNotEmpty ? trial.name[0].toUpperCase() : "#";
  }

  SuspensionUtil.sortListBySuspensionTag(trialsList);
  SuspensionUtil.setShowSuspensionStatus(trialsList);

  return trialsList;
}

Future<List<Trial>> getActiveTrials(List<String> docIds) async {
  final List<Trial> trialsList = [];

  for (var docId in docIds) {
    final doc = await FirebaseFirestore.instance
        .collection("trials")
        .doc(docId)
        .get(const GetOptions(source: Source.serverAndCache));
    if (doc.exists) {
      final newTrial = Trial(
        name: doc["name"],
        organization: doc["organization"],
        principal: doc["principal"],
        description: doc["description"],
        url: doc["url"],
        email: doc["email"],
      );
      trialsList.add(newTrial);
    }
  }

  trialsList.sort((a, b) => a.name.compareTo(b.name));

  return trialsList;
}
