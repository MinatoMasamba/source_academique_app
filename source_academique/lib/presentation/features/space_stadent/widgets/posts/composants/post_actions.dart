// lib/presentation/features/space_stadent/widgets/posts/composants/post_actions.dart
import 'package:flutter/material.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';

class PostActions extends StatelessWidget {
  final PostNews post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const PostActions({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
          label: post.likesCount.toString(),
          isActive: post.isLiked,
          activeColor: Colors.red,
          onTap: onLike,
          isDark: isDark,
        ),
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          label: post.commentsCount.toString(),
          onTap: onComment,
          isDark: isDark,
        ),
        _buildActionButton(
          icon: Icons.share_outlined,
          label: post.sharesCount.toString(),
          onTap: onShare,
          isDark: isDark,
        ),
        _buildActionButton(
          icon: post.isSaved ? Icons.bookmark : Icons.bookmark_border_outlined,
          label: "",
          onTap: onSave,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool isActive = false,
    Color? activeColor,
  }) {
    final color = isActive
        ? (activeColor ?? Colors.blue)
        : (isDark ? Colors.white70 : Colors.black54);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ],
      ),
    );
  }
}