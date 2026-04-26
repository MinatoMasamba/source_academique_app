// lib/presentation/features/space_stadent/widgets/documents/composants/document_storage_info.dart
import 'package:flutter/material.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/shared/student_glass_card.dart';

class DocumentStorageInfo extends StatelessWidget {
  final int usedBytes;
  final int totalBytes; // ex: 2 * 1024 * 1024 * 1024 (2 Go)

  const DocumentStorageInfo({
    super.key,
    required this.usedBytes,
    required this.totalBytes,
  });

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    if (bytes < 1024 * 1024 * 1024) return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalBytes > 0 ? usedBytes / totalBytes : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StudentGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_queue, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                "Stockage local",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.white24 : Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation(Colors.blue),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatBytes(usedBytes),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                _formatBytes(totalBytes),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}