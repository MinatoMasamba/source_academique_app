// lib/presentation/features/space_stadent/widgets/posts/composants/post_options_menu.dart
import 'package:flutter/material.dart';

class PostOptionsMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const PostOptionsMenu({
    super.key,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
          case 'share':
            onShare();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text("Modifier")]),
        ),
        const PopupMenuItem(
          value: 'share',
          child: Row(children: [Icon(Icons.share_outlined, size: 18), SizedBox(width: 8), Text("Partager")]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text("Supprimer", style: TextStyle(color: Colors.red))]),
        ),
      ],
    );
  }
}