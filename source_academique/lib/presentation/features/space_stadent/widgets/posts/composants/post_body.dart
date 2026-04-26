// lib/presentation/features/space_stadent/widgets/posts/composants/post_body.dart
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import 'package:source_academique/core/constants/app_colors.dart';
import 'package:source_academique/core/utils/my_widget_factory.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';

class PostBody extends StatelessWidget {
  final PostNews post;
  final VoidCallback onTap;

  const PostBody({super.key, required this.post, required this.onTap});

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  bool _isImageFile(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.gif') ||
        lowerUrl.endsWith('.webp') ||
        lowerUrl.contains('image');
  }

  (IconData, Color) _getFileTypeInfo(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.endsWith('.pdf')) {
      return (Icons.picture_as_pdf, Colors.red);
    } else if (lowerUrl.endsWith('.doc') || lowerUrl.endsWith('.docx')) {
      return (Icons.description, Colors.blue);
    } else if (lowerUrl.endsWith('.ppt') || lowerUrl.endsWith('.pptx')) {
      return (Icons.slideshow, Colors.orange);
    } else if (lowerUrl.endsWith('.xls') || lowerUrl.endsWith('.xlsx')) {
      return (Icons.table_chart, Colors.green);
    } else if (lowerUrl.endsWith('.txt')) {
      return (Icons.text_snippet, Colors.grey);
    } else if (lowerUrl.endsWith('.mp4') || lowerUrl.endsWith('.mov') || lowerUrl.endsWith('.avi')) {
      return (Icons.video_file, Colors.purple);
    } else if (lowerUrl.endsWith('.mp3') || lowerUrl.endsWith('.wav')) {
      return (Icons.audio_file, Colors.teal);
    } else {
      return (Icons.insert_drive_file, Colors.grey);
    }
  }

  bool _looksLikeMarkdown(String text) {
    if (text.contains(RegExp(r'<[^>]+>'))) return false;
    return text.contains(RegExp(r'(^|\n)#{1,6}\s')) ||
           text.contains(RegExp(r'\*\*|\*\_')) ||
           text.contains(RegExp(r'\[.*\]\(.*\)')) ||
           text.contains(RegExp(r'\$\$?[\s\S]+?\$\$?'));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayHtml = _looksLikeMarkdown(post.titre)
        ? md.markdownToHtml(post.titre, inlineOnly: false)
        : post.titre;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HtmlWidget(
            displayHtml,
            factoryBuilder: () => MathWidgetFactory(),
            textStyle: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.4,
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
          if (post.fichierUrl != null) ...[
            const SizedBox(height: 12),
            if (_isImageFile(post.fichierUrl!))
              GestureDetector(
                onTap: () => _openFile(post.fichierUrl!),
                child: Hero(
                  tag: post.fichierUrl!,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      post.fichierUrl!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / 
                                    loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print("❌ Erreur chargement image: $error");
                        return Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                "Image non disponible",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () => _openFile(post.fichierUrl!),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getFileTypeInfo(post.fichierUrl!).$2.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getFileTypeInfo(post.fichierUrl!).$1,
                          color: _getFileTypeInfo(post.fichierUrl!).$2,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getFileName(post.fichierUrl!),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getFileSize(post.fichierUrl!),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white12 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(Icons.open_in_new, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _getFileName(String url) {
    final uri = Uri.parse(url);
    final path = uri.path;
    final parts = path.split('/');
    return parts.isNotEmpty ? parts.last : "Fichier joint";
  }

  String _getFileSize(String url) {
    final ext = url.toLowerCase().split('.').last;
    switch (ext) {
      case 'pdf':
        return "Document PDF • 2.3 MB";
      case 'jpg':
      case 'jpeg':
      case 'png':
        return "Image • 1.2 MB";
      case 'doc':
      case 'docx':
        return "Document Word • 1.5 MB";
      default:
        return "Fichier joint";
    }
  }
}

extension ColorExtension on Color {
  String toHex() {
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}