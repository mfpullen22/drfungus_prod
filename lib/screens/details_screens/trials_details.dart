import 'package:drfungus_prod/widgets/markdown_section.dart';
import "package:flutter/material.dart";
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class TrialDetailsScreen extends StatelessWidget {
  const TrialDetailsScreen({required this.data, super.key});

  final dynamic data;

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

  Widget _buildContactSection(BuildContext context) {
    if (data.url.isEmpty && data.email.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _buildSectionHeader(context, "Study Website and Contact E-mail"),
        _buildContentContainer(
          context,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.url.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6, right: 8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: "Study Website: ",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: data.url,
                              style: TextStyle(
                                color: Colors.purple.shade600,
                                decoration: TextDecoration.underline,
                                fontSize: 13,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _launchURL(data.url),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (data.email.isNotEmpty) const SizedBox(height: 8),
              ],

              if (data.email.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6, right: 8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: "Contact E-mail: ",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: data.email,
                              style: TextStyle(
                                color: Colors.purple.shade600,
                                decoration: TextDecoration.underline,
                                fontSize: 13,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _launchEmail(data.email),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clinical Trial Title
          _buildSectionHeader(context, "Clinical Trial Title"),
          _buildContentContainer(context, MarkdownSection(data.name)),

          // Organization and Principal Investigator
          _buildSectionHeader(
            context,
            "Organization and Principal Investigator",
          ),
          _buildContentContainer(
            context,
            MarkdownSection("${data.organization} - ${data.principal}"),
          ),

          // Study Description
          _buildSectionHeader(context, "Study Description"),
          _buildContentContainer(context, MarkdownSection(data.description)),

          // Contact Information
          _buildContactSection(context),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/*
void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $emailUri';
    }
  }
  */
/*
Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: SimpleRichText(
            "Clinical Trial Title",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white),
          ),
        ),
        SimpleRichText(
          data.name,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: SimpleRichText(
            "Organization and Principal Investigator",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: SimpleRichText(
            "${data.organization} - ${data.principal}",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: SimpleRichText(
            "Study Description",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white),
          ),
        ),
        SimpleRichText(
          data.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: SimpleRichText(
            "Study Website and/or Contact E-mail",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white),
          ),
        ),
        if (data.url.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: RichText(
              text: TextSpan(
                text: "Study Website: ",
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: data.url,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[
                              900], // Optional: make the text look like a link
                          decoration: TextDecoration
                              .underline, // Optional: underline the text
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _launchURL(data.url);
                      },
                  ),
                ],
              ),
            ),
          ),
        if (data.email.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: RichText(
              text: TextSpan(
                text: "Contact E-mail: ",
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: data.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[
                              900], // Optional: make the text look like a link
                          decoration: TextDecoration
                              .underline, // Optional: underline the text
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _launchEmail(data.email);
                      },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
    */
