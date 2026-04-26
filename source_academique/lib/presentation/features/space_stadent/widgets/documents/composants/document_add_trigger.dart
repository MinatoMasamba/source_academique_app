// lib/presentation/features/space_stadent/widgets/documents/composants/document_add_trigger.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/shared/student_glass_card.dart';

class DocumentAddTrigger extends StatelessWidget {
  final Function(File file, String fileName) onFileSelected;

  const DocumentAddTrigger({super.key, required this.onFileSelected});

  Future<void> _pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        onFileSelected(file, fileName);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur sélection: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StudentGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: InkWell(
        onTap: () => _pickFile(context),
        borderRadius: BorderRadius.circular(24),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text("Ajouter un document"),
          ],
        ),
      ),
    );
  }
}