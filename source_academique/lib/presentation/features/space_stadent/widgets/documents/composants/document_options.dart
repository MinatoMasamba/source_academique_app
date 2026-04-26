// lib/presentation/features/space_stadent/widgets/documents/composants/document_options.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentOptions extends StatelessWidget {
  final String fileUrl;
  final VoidCallback onDelete;

  const DocumentOptions({
    super.key,
    required this.fileUrl,
    required this.onDelete,
  });

  Future<void> _openFile() async {
    final uri = Uri.parse(fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareFile() async {
    // Utiliser share_utils.dart si disponible
    await Share.share(fileUrl);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (value) {
        switch (value) {
          case 'open':
            _openFile();
            break;
          case 'share':
            _shareFile();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'open',
          child: Row(children: [Icon(Icons.open_in_new, size: 18), SizedBox(width: 8), Text("Ouvrir")]),
        ),
        const PopupMenuItem(
          value: 'share',
          child: Row(children: [Icon(Icons.share, size: 18), SizedBox(width: 8), Text("Partager")]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text("Supprimer", style: TextStyle(color: Colors.red))]),
        ),
      ],
    );
  }
}