// lib/screens/case_details_screen.dart - Educational Case Details (Updated for new image structure)
import 'package:drfungus_prod/widgets/markdown_section.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:drfungus_prod/models/case.dart';

class CaseDetailsScreen extends StatefulWidget {
  final Case caseItem;

  const CaseDetailsScreen({super.key, required this.caseItem});

  @override
  State<CaseDetailsScreen> createState() => _CaseDetailsScreenState();
}

class _CaseDetailsScreenState extends State<CaseDetailsScreen> {
  final Map<String, String?> _imageUrls = {};
  final Map<String, String> _imageLegends = {};
  final Map<String, bool> _expandedQuestions = {};
  bool _imagesLoading = true;

  @override
  void initState() {
    super.initState();

    /*     // Debug: Print the case data structure
    print('🚨 NEW CODE IS RUNNING - TEST MESSAGE');
    print('🔍 === CASE DATA DEBUG ===');
    print('🔍 Case Title: ${widget.caseItem.title}');
    print('🔍 Images array: ${widget.caseItem.images}');
    print('🔍 Questions array: ${widget.caseItem.questions}');
    print('🔍 Questions type: ${widget.caseItem.questions.runtimeType}');
    if (widget.caseItem.questions.isNotEmpty) {
      for (int i = 0; i < widget.caseItem.questions.length; i++) {
        print('🔍 Question $i: ${widget.caseItem.questions[i]}');
        print(
          '🔍 Question $i type: ${widget.caseItem.questions[i].runtimeType}',
        );
      }
    }
    print('🔍 === END CASE DATA DEBUG ==='); */

    _loadImages();

    // Initialize all questions as collapsed with unique keys
    for (int i = 0; i < widget.caseItem.questions.length; i++) {
      final questionMap = widget.caseItem.questions[i];
      questionMap.forEach((question, answer) {
        _expandedQuestions['question_${i}_${question.hashCode}'] = false;
      });
    }
  }

  Future<void> _loadImages() async {
    setState(() => _imagesLoading = true);

    for (Map<String, String> imageMap in widget.caseItem.images) {
      // Extract the filename (key) and legend (value) from each map
      for (var entry in imageMap.entries) {
        String imageName = entry.key;
        String legend = entry.value;

        try {
          final storage = FirebaseStorage.instanceFor(
            bucket: 'dr-fungus-app.firebasestorage.app',
          );

          // Try BOTH .jpg and .jpeg extensions for each image
          final extensionVariants = [
            imageName, // Original (e.g., "9324.jpeg" or "23434.jpg")
            imageName.replaceAll('.jpeg', '.jpg'), // Convert .jpeg to .jpg
            imageName.replaceAll('.jpg', '.jpeg'), // Convert .jpg to .jpeg
          ];

          // Remove duplicates
          final uniqueVariants = extensionVariants.toSet().toList();

          bool found = false;

          for (String fileName in uniqueVariants) {
            if (found) break;

            // Only check the images folder
            String folderPath = 'images/$fileName';
            try {
              final ref = storage.ref().child(folderPath);
              final url = await ref.getDownloadURL();

              _imageUrls[imageName] = url;
              _imageLegends[imageName] = legend; // Store the legend
              found = true;
              break;
            } catch (e) {
              print('❌ Folder path $folderPath failed');
            }
          }

          if (!found) {
            _imageUrls[imageName] = null;
            _imageLegends[imageName] =
                legend; // Store legend even if image fails
          }
        } catch (e) {
          _imageUrls[imageName] = null;
          _imageLegends[imageName] = legend;
        }
      }
    }

    setState(() => _imagesLoading = false);
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16, bottom: 8, left: 4, right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade600, Colors.purple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.school, color: Colors.white, size: 20),
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
        border: Border.all(color: Colors.purple.withOpacity(0.2), width: 1),
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

  Widget _buildCaseHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Case Title
          Text(
            widget.caseItem.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Case Information
          Text(
            'Submitted by: ${widget.caseItem.author}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            'Institution: ${widget.caseItem.institution}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            'Email: ${widget.caseItem.email}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      children: [
        _buildSectionHeader("Images"),
        _buildContentContainer(
          _imagesLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                  ),
                )
              : widget.caseItem.images.isEmpty ||
                    _imageUrls.values.every((url) => url == null)
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No images',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : Column(children: _buildImageList()),
        ),
      ],
    );
  }

  List<Widget> _buildImageList() {
    List<Widget> imageWidgets = [];

    for (Map<String, String> imageMap in widget.caseItem.images) {
      for (var entry in imageMap.entries) {
        String imageName = entry.key;
        String legend = entry.value;
        String? imageUrl = _imageUrls[imageName];

        if (imageUrl != null) {
          imageWidgets.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                GestureDetector(
                  onTap: () =>
                      _showFullScreenImage(imageUrl, imageName, legend),
                  child: Container(
                    height: 150, // Fixed height for grid consistency
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.purple,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.error,
                                color: Colors.grey,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Legend
                if (legend.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.purple.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      legend,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.purple.shade700,
                        fontStyle: FontStyle.italic,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }
      }
    }

    // Create 2-column grid
    List<Widget> rows = [];
    for (int i = 0; i < imageWidgets.length; i += 2) {
      List<Widget> rowChildren = [Expanded(child: imageWidgets[i])];

      // Add second column if it exists
      if (i + 1 < imageWidgets.length) {
        rowChildren.add(const SizedBox(width: 8)); // Spacing between columns
        rowChildren.add(Expanded(child: imageWidgets[i + 1]));
      } else {
        rowChildren.add(
          const Expanded(child: SizedBox()),
        ); // Empty space for odd number
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ),
        ),
      );
    }

    return rows;
  }

  void _showFullScreenImage(String imageUrl, String imageName, String legend) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Column(
              children: [
                // Image
                Expanded(
                  child: Center(
                    child: InteractiveViewer(
                      child: Image.network(imageUrl, fit: BoxFit.contain),
                    ),
                  ),
                ),

                // Legend at bottom (if exists)
                if (legend.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.black.withOpacity(0.8),
                    child: Text(
                      legend,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),

            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsSection() {
    if (widget.caseItem.questions.isEmpty) return const SizedBox.shrink();

    List<Widget> questionWidgets = [];

    for (int i = 0; i < widget.caseItem.questions.length; i++) {
      final questionMap = widget.caseItem.questions[i];

      questionMap.forEach((question, answer) {
        final uniqueKey = 'question_${i}_${question.hashCode}';
        final isExpanded = _expandedQuestions[uniqueKey] ?? false;

        questionWidgets.add(
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.purple.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: ExpansionTile(
              title: MarkdownSection(question),
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.purple.shade600,
              ),
              onExpansionChanged: (expanded) {
                setState(() {
                  _expandedQuestions[uniqueKey] = expanded;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: MarkdownSection(answer),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }

    return Column(children: questionWidgets);
  }

  Widget _buildReferencesSection() {
    if (widget.caseItem.references.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        _buildSectionHeader("References"),
        _buildContentContainer(
          Column(
            children: widget.caseItem.references.asMap().entries.map<Widget>((
              entry,
            ) {
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
                        color: Colors.purple.shade600,
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.caseItem.monthYearDisplay),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Case Header (Title and Author Info)
            _buildCaseHeader(),

            // History Section
            if (widget.caseItem.history.isNotEmpty) ...[
              _buildSectionHeader("History"),
              _buildContentContainer(MarkdownSection(widget.caseItem.history)),
            ],

            // Images Section
            _buildImagesSection(),

            // Physical Examination Section
            if (widget.caseItem.exam.isNotEmpty) ...[
              _buildSectionHeader("Physical Examination"),
              _buildContentContainer(MarkdownSection(widget.caseItem.exam)),
            ],

            // Laboratory Studies Section
            if (widget.caseItem.labs.isNotEmpty) ...[
              _buildSectionHeader("Laboratory Studies"),
              _buildContentContainer(MarkdownSection(widget.caseItem.labs)),
            ],

            // Questions Section (Accordions)
            if (widget.caseItem.questions.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildQuestionsSection(),
            ],

            // Discussion Section
            if (widget.caseItem.discussion.isNotEmpty) ...[
              _buildSectionHeader("Discussion"),
              _buildContentContainer(
                MarkdownSection(widget.caseItem.discussion),
              ),
            ],

            // References Section
            _buildReferencesSection(),

            // Bottom padding
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/* // lib/screens/case_details_screen.dart - Educational Case Details (Updated for new image structure)
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:drfungus_prod/models/case.dart';

class CaseDetailsScreen extends StatefulWidget {
  final Case caseItem;

  const CaseDetailsScreen({super.key, required this.caseItem});

  @override
  State<CaseDetailsScreen> createState() => _CaseDetailsScreenState();
}

class _CaseDetailsScreenState extends State<CaseDetailsScreen> {
  final Map<String, String?> _imageUrls = {};
  final Map<String, String> _imageLegends = {};
  final Map<String, bool> _expandedQuestions = {};
  bool _imagesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();

    // Initialize all questions as collapsed with unique keys
    for (int i = 0; i < widget.caseItem.questions.length; i++) {
      final questionMap = widget.caseItem.questions[i];
      questionMap.forEach((question, answer) {
        _expandedQuestions['question_${i}_${question.hashCode}'] = false;
      });
    }
  }

  Future<void> _loadImages() async {
    setState(() => _imagesLoading = true);

    for (Map<String, String> imageMap in widget.caseItem.images) {
      // Extract the filename (key) and legend (value) from each map
      for (var entry in imageMap.entries) {
        String imageName = entry.key;
        String legend = entry.value;

        try {
          final storage = FirebaseStorage.instanceFor(
            bucket: 'dr-fungus-app.firebasestorage.app',
          );

          // Try BOTH .jpg and .jpeg extensions for each image
          final extensionVariants = [
            imageName, // Original (e.g., "9324.jpeg" or "23434.jpg")
            imageName.replaceAll('.jpeg', '.jpg'), // Convert .jpeg to .jpg
            imageName.replaceAll('.jpg', '.jpeg'), // Convert .jpg to .jpeg
          ];

          // Remove duplicates
          final uniqueVariants = extensionVariants.toSet().toList();

          bool found = false;

          for (String fileName in uniqueVariants) {
            if (found) break;

            // Only check the images folder
            String folderPath = 'images/$fileName';
            try {
              final ref = storage.ref().child(folderPath);
              final url = await ref.getDownloadURL();

              _imageUrls[imageName] = url;
              _imageLegends[imageName] = legend; // Store the legend
              found = true;
              break;
            } catch (e) {
              // ignore: avoid_print
              print('❌ Folder path $folderPath failed');
            }
          }

          if (!found) {
            _imageUrls[imageName] = null;
            _imageLegends[imageName] =
                legend; // Store legend even if image fails
          }
        } catch (e) {
          _imageUrls[imageName] = null;
          _imageLegends[imageName] = legend;
        }
      }
    }

    setState(() => _imagesLoading = false);
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16, bottom: 8, left: 4, right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade600, Colors.purple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.school, color: Colors.white, size: 20),
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
        border: Border.all(color: Colors.purple.withOpacity(0.2), width: 1),
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

  Widget _buildCaseHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Case Title
          Text(
            widget.caseItem.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Case Information
          Text(
            'Submitted by: ${widget.caseItem.author}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            'Institution: ${widget.caseItem.institution}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            'Email: ${widget.caseItem.email}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      children: [
        _buildSectionHeader("Images"),
        _buildContentContainer(
          _imagesLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                  ),
                )
              : widget.caseItem.images.isEmpty ||
                    _imageUrls.values.every((url) => url == null)
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No images',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : Column(children: _buildImageList()),
        ),
      ],
    );
  }

  List<Widget> _buildImageList() {
    List<Widget> imageWidgets = [];

    for (Map<String, String> imageMap in widget.caseItem.images) {
      for (var entry in imageMap.entries) {
        String imageName = entry.key;
        String legend = entry.value;
        String? imageUrl = _imageUrls[imageName];

        if (imageUrl != null) {
          imageWidgets.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                GestureDetector(
                  onTap: () =>
                      _showFullScreenImage(imageUrl, imageName, legend),
                  child: Container(
                    height: 150, // Fixed height for grid consistency
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.purple,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.error,
                                color: Colors.grey,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Legend
                if (legend.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.purple.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      legend,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.purple.shade700,
                        fontStyle: FontStyle.italic,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }
      }
    }

    // Create 2-column grid
    List<Widget> rows = [];
    for (int i = 0; i < imageWidgets.length; i += 2) {
      List<Widget> rowChildren = [Expanded(child: imageWidgets[i])];

      // Add second column if it exists
      if (i + 1 < imageWidgets.length) {
        rowChildren.add(const SizedBox(width: 8)); // Spacing between columns
        rowChildren.add(Expanded(child: imageWidgets[i + 1]));
      } else {
        rowChildren.add(
          const Expanded(child: SizedBox()),
        ); // Empty space for odd number
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ),
        ),
      );
    }

    return rows;
  }

  void _showFullScreenImage(String imageUrl, String imageName, String legend) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Column(
              children: [
                // Image
                Expanded(
                  child: Center(
                    child: InteractiveViewer(
                      child: Image.network(imageUrl, fit: BoxFit.contain),
                    ),
                  ),
                ),

                // Legend at bottom (if exists)
                if (legend.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.black.withOpacity(0.8),
                    child: Text(
                      legend,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),

            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsSection() {
    if (widget.caseItem.questions.isEmpty) return const SizedBox.shrink();

    List<Widget> questionWidgets = [];

    for (int i = 0; i < widget.caseItem.questions.length; i++) {
      final questionMap = widget.caseItem.questions[i];

      questionMap.forEach((question, answer) {
        final uniqueKey = 'question_${i}_${question.hashCode}';
        final isExpanded = _expandedQuestions[uniqueKey] ?? false;

        questionWidgets.add(
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.purple.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: ExpansionTile(
              title: Text(
                question,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.purple.shade600,
              ),
              onExpansionChanged: (expanded) {
                setState(() {
                  _expandedQuestions[uniqueKey] = expanded;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      answer,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }

    return Column(children: questionWidgets);
  }

  Widget _buildReferencesSection() {
    if (widget.caseItem.references.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        _buildSectionHeader("References"),
        _buildContentContainer(
          Column(
            children: widget.caseItem.references.asMap().entries.map<Widget>((
              entry,
            ) {
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
                        color: Colors.purple.shade600,
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.caseItem.monthYearDisplay),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Case Header (Title and Author Info)
            _buildCaseHeader(),

            // History Section
            if (widget.caseItem.history.isNotEmpty) ...[
              _buildSectionHeader("History"),
              _buildContentContainer(
                Text(
                  widget.caseItem.history,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ),
            ],

            // Images Section
            _buildImagesSection(),

            // Physical Examination Section
            if (widget.caseItem.exam.isNotEmpty) ...[
              _buildSectionHeader("Physical Examination"),
              _buildContentContainer(
                Text(
                  widget.caseItem.exam,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ),
            ],

            // Laboratory Studies Section
            if (widget.caseItem.labs.isNotEmpty) ...[
              _buildSectionHeader("Laboratory Studies"),
              _buildContentContainer(
                Text(
                  widget.caseItem.labs,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ),
            ],

            // Questions Section (Accordions)
            if (widget.caseItem.questions.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildQuestionsSection(),
            ],

            // References Section
            _buildReferencesSection(),

            // Bottom padding
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
 */
