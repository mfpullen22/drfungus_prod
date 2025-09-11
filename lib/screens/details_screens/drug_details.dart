import "package:drfungus_prod/widgets/activetrials.dart";
import "package:drfungus_prod/widgets/markdown_section.dart";
import "package:flutter/material.dart";

class DrugDetailsScreen extends StatelessWidget {
  const DrugDetailsScreen({required this.data, super.key});

  final dynamic data;

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildContentContainer(BuildContext context, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildReferencesSection(BuildContext context) {
    if (data.references.length == 0 || data.references[0] == "") {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _buildSectionHeader(context, "References"),
        _buildContentContainer(
          context,
          Column(
            children: data.references.asMap().entries.map<Widget>((entry) {
              final index = entry.key;
              final ref = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(top: 2, right: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        ref,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Trials
          if (data.trials[0] != "")
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ActiveTrialsListTile(data: data),
            ),

          // Generic and Trade Names
          _buildSectionHeader(context, "Generic and Trade Names"),
          _buildContentContainer(context, MarkdownSection(data.name)),

          // Mechanism of Action
          if (data.mechanism.isNotEmpty) ...[
            _buildSectionHeader(context, "Mechanism(s) of Action"),
            _buildContentContainer(context, MarkdownSection(data.mechanism)),
          ],

          // Susceptibility Patterns
          if (data.susceptibility.isNotEmpty) ...[
            _buildSectionHeader(context, "Susceptibility Patterns"),
            _buildContentContainer(
              context,
              MarkdownSection(data.susceptibility),
            ),
          ],

          // Route and Dosage
          if (data.dosage.isNotEmpty) ...[
            _buildSectionHeader(context, "Route and Dosage"),
            _buildContentContainer(context, MarkdownSection(data.dosage)),
          ],

          // Adverse Effects
          if (data.adverse.isNotEmpty) ...[
            _buildSectionHeader(context, "Adverse Effects"),
            _buildContentContainer(context, MarkdownSection(data.adverse)),
          ],

          // Current Status
          if (data.status.isNotEmpty) ...[
            _buildSectionHeader(context, "Current Status"),
            _buildContentContainer(context, MarkdownSection(data.status)),
          ],

          // References
          _buildReferencesSection(context),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/* import "package:drfungus_prod/screens/datalist.dart";
import "package:drfungus_prod/widgets/activetrials.dart";
import "package:drfungus_prod/widgets/markdown_section.dart";
import "package:flutter/material.dart";
import "package:simple_rich_text/simple_rich_text.dart";

class DrugDetailsScreen extends StatelessWidget {
  const DrugDetailsScreen({required this.data, super.key});

  final dynamic data;

  void trialTile(BuildContext context) async {
    // Fetch the active trials for the doc IDs in the data.trials array
    List<String> trialDocIds = List<String>.from(data.trials);
    // Navigate to the DataListScreen with the active trials
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DataListScreen(
          title: "Active Trials",
          docIds: trialDocIds, // Passing the docIds to DataListScreen
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.trials[0] != "") ActiveTrialsListTile(data: data),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Text(
            "Generic and Trade Names",
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: Colors.white),
          ),
        ),
        MarkdownSection(data.name),
        const SizedBox(height: 14),
        if (data.mechanism.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SimpleRichText(
              "Mechanism(s) of Action",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        MarkdownSection(data.mechanism),
        if (data.mechanism.isNotEmpty) const SizedBox(height: 14),
        if (data.susceptibility.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SimpleRichText(
              "Susceptibility Patterns",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        MarkdownSection(data.susceptibility),
        if (data.susceptibility.isNotEmpty) const SizedBox(height: 14),
        if (data.dosage.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SimpleRichText(
              "Route and Dosage",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        MarkdownSection(data.dosage),
        if (data.dosage.isNotEmpty) const SizedBox(height: 14),
        if (data.adverse.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SimpleRichText(
              "Adverse Effects",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        MarkdownSection(data.adverse),
        if (data.adverse.isNotEmpty) const SizedBox(height: 14),
        if (data.status.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SimpleRichText(
              "Current Status",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        MarkdownSection(data.status),
        if (data.references.length > 0 && data.references[0] != "")
          const SizedBox(height: 14),
        if (data.references.length > 0 && data.references[0] != "")
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SimpleRichText(
              "References",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        for (var ref in data.references)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              ref,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontSize: 12),
            ),
          ),
      ],
    );
  }
}



    /*
Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Text(
            "Generic and Trade Names",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white),
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: SimpleRichText(data.name,
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: SimpleRichText(
            "Mechanism(s) of Action",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white),
          ),
        ),
        SimpleRichText(
          data.mechanism,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: SimpleRichText(
            "Susceptibility Patterns",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white),
          ),
        ),
        SimpleRichText(
          data.susceptibility,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: SimpleRichText(
            "Route and Dosage",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white),
          ),
        ),
        SimpleRichText(
          data.dosage,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: SimpleRichText(
            "Adverse Effects",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white),
          ),
        ),
        SimpleRichText(
          data.adverse,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: SimpleRichText(
            "Current Status",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white),
          ),
        ),
        SimpleRichText(
          data.status,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
    */

 */
