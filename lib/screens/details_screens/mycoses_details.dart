// lib/screens/mycoses_details_screen.dart - Details page for mycoses (Fixed for infinite height)
import 'package:flutter/material.dart';
import 'package:drfungus_prod/models/mycoses.dart';
import 'package:drfungus_prod/widgets/markdown_section.dart';

class MycosesDetailsScreen extends StatelessWidget {
  final Mycoses mycoses;

  const MycosesDetailsScreen({super.key, required this.mycoses});

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16, bottom: 8, left: 4, right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade600, Colors.red.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.medical_information, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentContainer(Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
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

  Widget _buildDiagnosticsSection() {
    // Check if any lab fields have content
    bool hasLabExam = mycoses.labexam.isNotEmpty;
    bool hasLabIso = mycoses.labiso.isNotEmpty;
    bool hasLabConfirm = mycoses.labconfirm.isNotEmpty;

    // If none have content, don't show the section
    if (!hasLabExam && !hasLabIso && !hasLabConfirm) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _buildSectionHeader("Diagnostics"),
        _buildContentContainer(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Laboratory Direct Examination
              if (hasLabExam) ...[
                Text(
                  'Laboratory Direct Examination',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                MarkdownSection(mycoses.labexam),
                if (hasLabIso || hasLabConfirm) const SizedBox(height: 16),
              ],

              // Laboratory Isolation
              if (hasLabIso) ...[
                Text(
                  'Laboratory Isolation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                MarkdownSection(mycoses.labiso),
                if (hasLabConfirm) const SizedBox(height: 16),
              ],

              // Laboratory Confirmation
              if (hasLabConfirm) ...[
                Text(
                  'Laboratory Confirmation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                MarkdownSection(mycoses.labconfirm),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReferencesSection() {
    if (mycoses.references.isEmpty ||
        (mycoses.references.length == 1 && mycoses.references[0].isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _buildSectionHeader("References"),
        _buildContentContainer(
          Column(
            children: mycoses.references
                .where((ref) => ref.isNotEmpty)
                .toList()
                .asMap()
                .entries
                .map<Widget>((entry) {
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
                            color: Colors.red.shade600,
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
                })
                .toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Return just the content Column without Scaffold since it's already in item_details_screen
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Synonyms Section
        if (mycoses.synonyms.isNotEmpty) ...[
          _buildSectionHeader("Synonyms"),
          _buildContentContainer(MarkdownSection(mycoses.synonyms)),
        ],

        // Definition Section
        if (mycoses.definition.isNotEmpty) ...[
          _buildSectionHeader("Definition"),
          _buildContentContainer(MarkdownSection(mycoses.definition)),
        ],

        // Natural Environment Section
        if (mycoses.natural.isNotEmpty) ...[
          _buildSectionHeader("Natural Environment"),
          _buildContentContainer(MarkdownSection(mycoses.natural)),
        ],

        // Overview Section
        if (mycoses.overview.isNotEmpty) ...[
          _buildSectionHeader("Overview"),
          _buildContentContainer(MarkdownSection(mycoses.overview)),
        ],

        // Epidemiology Section
        if (mycoses.epidemiology.isNotEmpty) ...[
          _buildSectionHeader("Epidemiology"),
          _buildContentContainer(MarkdownSection(mycoses.epidemiology)),
        ],

        // Diagnostics Section (custom layout)
        _buildDiagnosticsSection(),

        // Treatment Section
        if (mycoses.treatment.isNotEmpty) ...[
          _buildSectionHeader("Treatment"),
          _buildContentContainer(MarkdownSection(mycoses.treatment)),
        ],

        // Susceptibility Section
        if (mycoses.susceptibility.isNotEmpty) ...[
          _buildSectionHeader("Susceptibility"),
          _buildContentContainer(MarkdownSection(mycoses.susceptibility)),
        ],

        // References Section
        _buildReferencesSection(),

        // Bottom padding
        const SizedBox(height: 16),
      ],
    );
  }
}

/* import 'package:drfungus_prod/widgets/activetrials.dart';
import 'package:drfungus_prod/widgets/markdown_section.dart';
import 'package:flutter/material.dart';

class MycosesDetailsScreen extends StatelessWidget {
  const MycosesDetailsScreen({required this.data, super.key});

  final dynamic data;

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade600, Colors.red.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
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
        border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
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
                        color: Colors.red.shade600,
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

          // Mycology
          if (data.mycology.isNotEmpty) ...[
            _buildSectionHeader(context, "Mycology"),
            _buildContentContainer(context, MarkdownSection(data.mycology)),
          ],

          // Epidemiology
          if (data.epidemiology.isNotEmpty) ...[
            _buildSectionHeader(context, "Epidemiology"),
            _buildContentContainer(context, MarkdownSection(data.epidemiology)),
          ],

          // Pathogenesis
          if (data.pathogenesis.isNotEmpty) ...[
            _buildSectionHeader(context, "Pathogenesis"),
            _buildContentContainer(context, MarkdownSection(data.pathogenesis)),
          ],

          // Clinical Manifestations
          if (data.clinical.isNotEmpty) ...[
            _buildSectionHeader(context, "Clinical Manifestations"),
            _buildContentContainer(context, MarkdownSection(data.clinical)),
          ],

          // Diagnosis
          if (data.diagnosis.isNotEmpty) ...[
            _buildSectionHeader(context, "Diagnosis"),
            _buildContentContainer(context, MarkdownSection(data.diagnosis)),
          ],

          // Treatment
          if (data.treatment.isNotEmpty) ...[
            _buildSectionHeader(context, "Treatment"),
            _buildContentContainer(context, MarkdownSection(data.treatment)),
          ],

          // References
          _buildReferencesSection(context),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/* import 'package:drfungus_prod/widgets/activetrials.dart';
import 'package:drfungus_prod/widgets/markdown_section.dart';
import 'package:flutter/material.dart';
import "package:simple_rich_text/simple_rich_text.dart";

class MycosesDetailsScreen extends StatelessWidget {
  const MycosesDetailsScreen({required this.data, super.key});

  final dynamic data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (data.trials[0] != "") ActiveTrialsListTile(data: data),
        if (data.mycology.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SimpleRichText(
              "Mycology",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        if (data.mycology.isNotEmpty) MarkdownSection(data.mycology),
        if (data.mycology.isNotEmpty) const SizedBox(height: 14),
        if (data.epidemiology.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SimpleRichText(
              "Epidemiology",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        if (data.epidemiology.isNotEmpty) MarkdownSection(data.epidemiology),
        if (data.epidemiology.isNotEmpty) const SizedBox(height: 14),
        if (data.pathogenesis.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SimpleRichText(
              "Pathogenesis",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        if (data.pathogenesis.isNotEmpty) MarkdownSection(data.pathogenesis),
        if (data.pathogenesis.isNotEmpty) const SizedBox(height: 14),
        if (data.clinical.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SimpleRichText(
              "Clinical Manifestations",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        if (data.clinical.isNotEmpty) MarkdownSection(data.clinical),
        if (data.clinical.isNotEmpty) const SizedBox(height: 14),
        if (data.diagnosis.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SimpleRichText(
              "Diagnosis",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        if (data.diagnosis.isNotEmpty) MarkdownSection(data.diagnosis),
        if (data.diagnosis.isNotEmpty) const SizedBox(height: 14),
        if (data.treatment.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SimpleRichText(
              "Treatment",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        if (data.treatment.isNotEmpty) MarkdownSection(data.treatment),
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


/* import 'package:flutter/material.dart';
import "package:simple_rich_text/simple_rich_text.dart";

class MycosesDetailsScreen extends StatelessWidget {
  const MycosesDetailsScreen({required this.data, super.key});

  final dynamic data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: SimpleRichText(
            "Mycology",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white),
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: SimpleRichText(
            data.mycology,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: SimpleRichText(
            "Epidemiology",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white),
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: SimpleRichText(
            data.epidemiology,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: SimpleRichText(
            "Pathogenesis",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white),
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: SimpleRichText(
            data.pathogenesis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: SimpleRichText(
            "Clinical Manifestations",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white),
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: SimpleRichText(
            data.clinical,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: SimpleRichText(
            "Diagnosis",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white),
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: SimpleRichText(
            data.diagnosis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: SimpleRichText(
            "Treatment",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white),
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: SimpleRichText(
            data.treatment,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
} */

 */
 */
