// lib/presentation/features/space_stadent/widgets/posts/comment_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';
import 'package:source_academique/presentation/features/space_stadent/presentation/bloc/student_space_bloc.dart';
import 'package:source_academique/presentation/features/space_stadent/presentation/bloc/student_space_state.dart';

class CommentSheet extends StatefulWidget {
  final PostNews post;

  const CommentSheet({super.key, required this.post});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<StudentSpaceBloc>().add(FetchCommentsEvent(widget.post.shareableId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isLoading = true);
    context.read<StudentSpaceBloc>().add(AddCommentEvent(widget.post.shareableId, content));
    _commentController.clear();
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isLoading = false);
    context.read<StudentSpaceBloc>().add(FetchCommentsEvent(widget.post.shareableId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
       backgroundColor: isDark ? Colors.grey[900] : Colors.white, // Couleur de fond adaptée au thème
       insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: FractionallySizedBox(
        heightFactor: 0.55,
         widthFactor: 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Commentaires (${widget.post.commentsCount})",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Liste des commentaires
            Expanded(
              child: BlocBuilder<StudentSpaceBloc, StudentSpaceState>(
                builder: (context, state) {
                  List<Comment> comments = [];
                  if (state.status == StudentSpaceStatus.success) {
                    comments = state.commentsMap[widget.post.shareableId] ?? [];
                  }
                  if (comments.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text("Aucun commentaire pour l'instant"),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return _buildCommentTile(comment, isDark);
                    },
                  );
                },
              ),
            ),
            // Zone de saisie
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
                border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      maxLines: 3,
                      minLines: 1,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: "Écrire un commentaire...",
                        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.white10 : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isLoading ? null : _addComment,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentTile(Comment comment, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.withOpacity(0.2),
            child: Text(
              comment.userName[0].toUpperCase(),
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.formattedDate,
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}