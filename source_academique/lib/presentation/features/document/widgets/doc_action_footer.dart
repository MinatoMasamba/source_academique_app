import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'download_progress_button.dart'; // à créer

class DocActionFooter extends StatelessWidget {
  final String fileUrl;
  final String fileName;
  final VoidCallback onPreview;

  const DocActionFooter({
    super.key,
    required this.fileUrl,
    required this.fileName,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildSquareButton(context, Icons.remove_red_eye_outlined, onPreview),
            const SizedBox(width: 16),
            Expanded(
              child: DownloadProgressButton(
                fileUrl: fileUrl,
                fileName: fileName,
                onDownloadComplete: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Document téléchargé !")),
                  );
                },
                onError: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Erreur de téléchargement"), backgroundColor: Colors.red),
                  );
                },
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: 1, end: 0, duration: 500.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildSquareButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon),
      ),
    );
  }
}