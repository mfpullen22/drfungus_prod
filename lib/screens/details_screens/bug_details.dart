// lib/screens/bug_details_screen.dart - Details page for bugs (fungi)
import 'package:flutter/material.dart';
import 'package:drfungus_prod/models/bug.dart';
import 'package:drfungus_prod/widgets/markdown_section.dart';

class BugDetailsScreen extends StatelessWidget {
  final Bug bug;

  const BugDetailsScreen({super.key, required this.bug});

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16, bottom: 8, left: 4, right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.hub, color: Colors.white, size: 20),
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
        border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
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

  Widget _buildLaboratoryFeaturesSection() {
    // Check if any lab feature fields have content
    bool hasMacro = bug.macro.isNotEmpty;
    bool hasMicro = bug.micro.isNotEmpty;
    bool hasHisto = bug.histo.isNotEmpty;

    // If none have content, don't show the section
    if (!hasMacro && !hasMicro && !hasHisto) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _buildSectionHeader("Laboratory Features"),
        _buildContentContainer(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Macroscopic Features
              if (hasMacro) ...[
                Text(
                  'Macroscopic Features',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                MarkdownSection(bug.macro),
                if (hasMicro || hasHisto) const SizedBox(height: 16),
              ],

              // Microscopic Features
              if (hasMicro) ...[
                Text(
                  'Microscopic Features',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                MarkdownSection(bug.micro),
                if (hasHisto) const SizedBox(height: 16),
              ],

              // Histopathologic Features
              if (hasHisto) ...[
                Text(
                  'Histopathologic Features',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                MarkdownSection(bug.histo),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReferencesSection() {
    if (bug.references.isEmpty ||
        (bug.references.length == 1 && bug.references[0].isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _buildSectionHeader("References"),
        _buildContentContainer(
          Column(
            children: bug.references
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
                            color: Colors.green.shade600,
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
    // Return content with full white background container
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description Section
          if (bug.description.isNotEmpty) ...[
            _buildSectionHeader("Description"),
            _buildContentContainer(MarkdownSection(bug.description)),
          ],

          // Species Information Section
          if (bug.species.isNotEmpty) ...[
            _buildSectionHeader("Species Information"),
            _buildContentContainer(MarkdownSection(bug.species)),
          ],

          // Clinical Information Section
          if (bug.clinical.isNotEmpty) ...[
            _buildSectionHeader("Clinical Information"),
            _buildContentContainer(MarkdownSection(bug.clinical)),
          ],

          // Laboratory Features Section (custom layout)
          _buildLaboratoryFeaturesSection(),

          // Laboratory Precautions Section
          if (bug.precautions.isNotEmpty) ...[
            _buildSectionHeader("Laboratory Precautions"),
            _buildContentContainer(MarkdownSection(bug.precautions)),
          ],

          // Susceptibility Information Section
          if (bug.susceptibility.isNotEmpty) ...[
            _buildSectionHeader("Susceptibility Information"),
            _buildContentContainer(MarkdownSection(bug.susceptibility)),
          ],

          // References Section
          _buildReferencesSection(),

          // Bottom padding and spacer to ensure white background fills screen
          const SizedBox(height: 16),

          // This ensures the white background extends to fill remaining space
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: Container(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/* import 'package:drfungus_prod/widgets/activetrials.dart';
import 'package:drfungus_prod/widgets/markdown_section.dart';
import 'package:flutter/material.dart';

class BugDetailsScreen extends StatelessWidget {
  const BugDetailsScreen({required this.data, super.key});

  final dynamic data;

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentContainer(BuildContext context, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
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
                        color: Colors.green.shade600,
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
      padding: const EdgeInsets.all(4), // Minimal padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Trials
          if (data.trials[0] != "")
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ActiveTrialsListTile(data: data),
            ),

          // Description
          if (data.description.isNotEmpty) ...[
            _buildSectionHeader(context, "Description and Natural Habitats"),
            _buildContentContainer(context, MarkdownSection(data.description)),
          ],

          // Species
          if (data.species.isNotEmpty) ...[
            _buildSectionHeader(context, "Species"),
            _buildContentContainer(context, MarkdownSection(data.species)),
          ],

          // Clinical Significance
          if (data.clinical.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              "Pathogenicity and Clinical Significance",
            ),
            _buildContentContainer(context, MarkdownSection(data.clinical)),
          ],

          // Features
          if (data.features.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              "Micro/Macroscopic, and Histologic Features",
            ),
            _buildContentContainer(context, MarkdownSection(data.features)),
          ],

          // Precautions
          if (data.precautions.isNotEmpty) ...[
            _buildSectionHeader(context, "Laboratory Precautions"),
            _buildContentContainer(context, MarkdownSection(data.precautions)),
          ],

          // Susceptibility
          if (data.susceptibility.isNotEmpty) ...[
            _buildSectionHeader(context, "Susceptibility Patterns"),
            _buildContentContainer(
              context,
              MarkdownSection(data.susceptibility),
            ),
          ],

          // References
          _buildReferencesSection(context),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
} */

/* import 'package:drfungus_prod/widgets/activetrials.dart';
import 'package:drfungus_prod/widgets/markdown_section.dart';
import 'package:flutter/material.dart';
import "package:simple_rich_text/simple_rich_text.dart";

class BugDetailsScreen extends StatelessWidget {
  const BugDetailsScreen({required this.data, super.key});

  final dynamic data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.trials[0] != "") ActiveTrialsListTile(data: data),
        if (data.description.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SimpleRichText(
              "Description and Natural Habitats",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        //FormattedText(firestoreString: data.description),
        MarkdownSection(data.description),
        if (data.description.isNotEmpty) const SizedBox(height: 14),
        if (data.species.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SimpleRichText(
              "Species",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        MarkdownSection(data.species),
        if (data.species.isNotEmpty) const SizedBox(height: 14),
        if (data.clinical.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SimpleRichText(
              "Pathogenicity and Clinical Significance",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        MarkdownSection(data.clinical),
        if (data.clinical.isNotEmpty) const SizedBox(height: 14),
        if (data.features.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SimpleRichText(
              "Micro\\/Macroscopic, and Histologic features",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        MarkdownSection(data.features),
        if (data.features.isNotEmpty) const SizedBox(height: 14),
        if (data.precautions.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SimpleRichText(
              "Laboratory Precautions",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        MarkdownSection(data.precautions),
        if (data.precautions.isNotEmpty) const SizedBox(height: 14),
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



*/
 */
