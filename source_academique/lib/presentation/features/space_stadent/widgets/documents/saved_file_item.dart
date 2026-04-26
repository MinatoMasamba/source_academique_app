// lib/presentation/features/space_stadent/widgets/documents/saved_file_item.dart
import 'package:flutter/material.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/documents/composants/document_thumbnail.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/documents/composants/document_options.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/shared/student_glass_card.dart';

class SavedFileItem extends StatelessWidget {
  final StudentFile file;
  final VoidCallback onDelete;

  const SavedFileItem({
    super.key,
    required this.file,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StudentGlassCard(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Vignette selon l'extension
          DocumentThumbnail(
            fileName: file.fileName,
            size: 48,
          ),
          const SizedBox(width: 12),
          // Informations textuelles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "${file.formattedSize} • ${_formatDate(file.uploadedAt)}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Menu options (ouvrir, partager, supprimer)
          DocumentOptions(
            fileUrl: file.fileUrl,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 7) {
      return "${date.day}/${date.month}/${date.year}";
    } else if (diff.inDays > 0) {
      return "Il y a ${diff.inDays}j";
    } else if (diff.inHours > 0) {
      return "Il y a ${diff.inHours}h";
    } else if (diff.inMinutes > 0) {
      return "Il y a ${diff.inMinutes}min";
    } else {
      return "À l'instant";
    }
  }
}