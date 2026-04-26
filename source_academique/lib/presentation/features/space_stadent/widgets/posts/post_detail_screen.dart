// lib/presentation/features/space_stadent/widgets/posts/post_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';
import 'package:source_academique/presentation/features/space_stadent/presentation/bloc/student_space_bloc.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/posts/composants/post_header.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/posts/composants/post_body.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/posts/composants/post_actions.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/posts/comment_sheet.dart';

class PostDetailScreen extends StatelessWidget {
  final PostNews post;

  const PostDetailScreen({super.key, required this.post});

  void _recordView(BuildContext context) {
    print("👁️ [PostDetailScreen] Enregistrement de la vue pour le post: ${post.shareableId}");
    try {
      context.read<StudentSpaceBloc>().add(RecordViewEvent(post.shareableId));
    } catch (e) {
      print("⚠️ [PostDetailScreen] Impossible d'enregistrer la vue: $e");
    }
  }

  void _toggleLike(BuildContext context) {
    print("❤️ [PostDetailScreen] Like togglé pour le post: ${post.shareableId}");
    try {
      context.read<StudentSpaceBloc>().add(ToggleLikeEvent(post.shareableId, post.isLiked));
    } catch (e) {
      print("⚠️ [PostDetailScreen] Impossible de toggler le like: $e");
    }
  }

  Future<void> _sharePost(BuildContext context) async {
    print("📤 [PostDetailScreen] Partage du post: ${post.shareableId}");
    try {
      await Share.share(post.shareableLink, subject: post.titre);
      context.read<StudentSpaceBloc>().add(SharePostEvent(post.shareableId));
    } catch (e) {
      print("⚠️ [PostDetailScreen] Erreur lors du partage: $e");
    }
  }

  void _showComments(BuildContext context) {
    print("💬 [PostDetailScreen] Ouverture des commentaires pour le post: ${post.shareableId}");
    try {
      final bloc = context.read<StudentSpaceBloc>();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (bottomSheetContext) => BlocProvider.value(
          value: bloc,
          child: CommentSheet(post: post),
        ),
      );
    } catch (e) {
      print("⚠️ [PostDetailScreen] Impossible d'ouvrir les commentaires: $e");
    }
  }

  void _editPost(BuildContext context) {}
  void _deletePost(BuildContext context) {}
  void _savePost(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    _recordView(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail du Post"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _sharePost(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostHeader(
              post: post,
              isOwner: false,
              onEdit: () => _editPost(context),
              onDelete: () => _deletePost(context),
              onShare: () => _sharePost(context),
            ),
            const SizedBox(height: 12),
            PostBody(
              post: post,
              onTap: () {},
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Icon(Icons.visibility_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text("${post.viewsCount} vues", style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 10),
            PostActions(
              post: post,
              onLike: () => _toggleLike(context),
              onComment: () => _showComments(context),
              onShare: () => _sharePost(context),
              onSave: () => _savePost(context),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _showComments(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Commentaires (${post.commentsCount})",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}