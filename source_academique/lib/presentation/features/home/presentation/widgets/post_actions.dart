import 'package:flutter/material.dart';
import 'package:source_academique/core/constants/app_colors.dart';

class PostActions extends StatelessWidget {
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final bool isDark;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostActions({
    super.key,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
    required this.isDark,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          label: likeCount.toString(),
          isActive: isLiked,
          activeColor: Colors.red,
          onTap: onLike,
        ),
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          label: commentCount.toString(),
          isActive: false,
          onTap: onComment,
        ),
        _buildActionButton(
          icon: Icons.share_outlined,
          label: "Partager",
          isActive: false,
          onTap: onShare,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Color? activeColor,
  }) {
    final color = isActive
        ? (activeColor ?? AppColors.secondary)
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