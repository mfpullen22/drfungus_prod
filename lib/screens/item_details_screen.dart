import "package:drfungus_prod/models/bug.dart";
import "package:drfungus_prod/models/drug.dart";
import "package:drfungus_prod/models/mycoses.dart";
import "package:drfungus_prod/models/trial.dart";
import "package:drfungus_prod/screens/details_screens/bug_details.dart";
import "package:drfungus_prod/screens/details_screens/drug_details.dart";
import "package:drfungus_prod/screens/details_screens/mycoses_details.dart";
import "package:drfungus_prod/screens/details_screens/trials_details.dart";
import "package:flutter/material.dart";

class ItemDetailsScreen extends StatelessWidget {
  const ItemDetailsScreen({required this.name, required this.data, super.key});

  final String name;
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (data is Drug) {
      content = DrugDetailsScreen(data: data);
    } else if (data is Bug) {
      content = BugDetailsScreen(bug: data);
    } else if (data is Mycoses) {
      content = MycosesDetailsScreen(mycoses: data);
    } else if (data is Trial) {
      content = TrialDetailsScreen(data: data);
    } else {
      content = const Center(child: Text("Invalid data type"));
    }

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(16.0), child: content),
        ),
      ),
    );
  }
}
