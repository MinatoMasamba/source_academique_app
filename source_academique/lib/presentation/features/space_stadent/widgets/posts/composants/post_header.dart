// lib/presentation/features/space_stadent/widgets/posts/composants/post_header.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/posts/composants/post_options_menu.dart';

class PostHeader extends StatelessWidget {
  final PostNews post;
  final bool isOwner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const PostHeader({
    super.key,
    required this.post,
    required this.isOwner,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
  });

  void _navigateToProfile(BuildContext context) {
    final userId = post.user['id'];
    if (userId != null) {
      context.push('/profile/$userId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _navigateToProfile(context),
          child: CircleAvatar(
            radius: 18,
            backgroundImage: post.userAvatar != null ? NetworkImage(post.userAvatar!) : null,
            child: post.userAvatar == null
                ? Icon(Icons.person, size: 18, color: Colors.blue)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => _navigateToProfile(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.userFullName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${post.formattedDate} • ${post.faculter ?? "Communauté"}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        if (isOwner)
          PostOptionsMenu(
            onEdit: onEdit,
            onDelete: onDelete,
            onShare: onShare,
          )
        else
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: onShare,
          ),
      ],
    );
  }
}