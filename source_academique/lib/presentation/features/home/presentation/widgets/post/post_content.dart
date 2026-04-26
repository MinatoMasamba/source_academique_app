import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:source_academique/core/constants/app_colors.dart';
//import 'package:source_academique/core/utils/math_widget_factory.dart';
import 'package:source_academique/core/utils/my_widget_factory.dart';
import 'package:url_launcher/url_launcher.dart';

class PostContent extends StatelessWidget {
  final String htmlContent;   // Peut être du HTML ou du Markdown
  final String? imageUrl;
  final bool isDark;
  final VoidCallback onImageTap;

  const PostContent({
    super.key,
    required this.htmlContent,
    this.imageUrl,
    required this.isDark,
    required this.onImageTap,
  });

  /// Vérifie si le contenu ressemble à du Markdown (et non du HTML)
  bool _looksLikeMarkdown(String text) {
    // Si on trouve des balises HTML, on considère que c'est déjà du HTML
    if (text.contains(RegExp(r'<[^>]+>'))) return false;
    // Sinon, on cherche des motifs Markdown typiques
    return text.contains(RegExp(r'(^|\n)#{1,6}\s')) ||   // titres #
           text.contains(RegExp(r'\*\*|\*\_')) ||        // gras/italique
           text.contains(RegExp(r'\[.*\]\(.*\)')) ||     // liens
           text.contains(RegExp(r'\$\$?[\s\S]+?\$\$?')); // maths
  }

  @override
  Widget build(BuildContext context) {
    // Si c'est du Markdown, on le convertit en HTML
    final displayHtml = _looksLikeMarkdown(htmlContent)
        ? md.markdownToHtml(htmlContent, inlineOnly: false)
        : htmlContent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HtmlWidget(
          displayHtml,
          factoryBuilder: () => MathWidgetFactory(),
          textStyle: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black87,
            height: 1.5,
          ),
          customStylesBuilder: (element) {
            final localName = element.localName;
            if (localName == 'table') {
              return {
                'border': '1px solid ${isDark ? "#444" : "#ccc"}',
                'width': '100%',
                'border-collapse': 'collapse',
                'margin': '10px 0',
              };
            }
            if (localName == 'th') {
              return {
                'background-color': isDark ? '#333' : '#eee',
                'font-weight': 'bold',
                'padding': '8px',
                'border': '1px solid ${isDark ? "#555" : "#ddd"}',
              };
            }
            if (localName == 'td') {
              return {
                'padding': '8px',
                'border': '1px solid ${isDark ? "#555" : "#ddd"}',
              };
            }
            if (localName == 'a') {
              return {
                'color': AppColors.primary.toHex(),
                'text-decoration': 'none',
              };
            }
            if (localName == 'pre') {
              return {
                'background-color': isDark ? '#1e1e1e' : '#f5f5f5',
                'padding': '12px',
                'border-radius': '8px',
                'overflow-x': 'auto',
              };
            }
            return null;
          },
          onTapUrl: (url) async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return true;
            }
            return false;
          },
        ),
        if (imageUrl != null) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onImageTap,
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Image.network(
                imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, size: 50),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}

extension ColorExtension on Color {
  String toHex() {
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}