// lib/presentation/features/space_stadent/widgets/documents/composants/document_thumbnail.dart
import 'package:flutter/material.dart';

class DocumentThumbnail extends StatelessWidget {
  final String fileName;
  final double size;

  const DocumentThumbnail({
    super.key,
    required this.fileName,
    this.size = 40,
  });

  String _extension() {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  IconData _getIcon() {
    switch (_extension()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getColor() {
    switch (_extension()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_getIcon(), color: _getColor(), size: size * 0.6),
    );
  }
}