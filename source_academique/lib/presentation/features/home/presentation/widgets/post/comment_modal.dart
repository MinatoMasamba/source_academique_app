import 'package:flutter/material.dart';
import 'package:source_academique/core/constants/app_colors.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';
import 'package:source_academique/presentation/features/home/services/comment_service.dart';

class CommentModal extends StatefulWidget {
  final PostNews post;
  final bool isDark;
  final VoidCallback onCommentAdded;

  const CommentModal({
    super.key,
    required this.post,
    required this.isDark,
    required this.onCommentAdded,
  });

  @override
  State<CommentModal> createState() => _CommentModalState();
}

class _CommentModalState extends State<CommentModal> {
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final comments = await _commentService.fetchComments(widget.post.shareableId);
    if (mounted) {
      setState(() {
        _comments = comments;
      });
    }
  }

// lib/presentation/features/home/presentation/widgets/post/comment_modal.dart

@override
Widget build(BuildContext context) {
  return Dialog(
    // MODIFICATION : On redonne de la marge horizontale (ex: 20) pour ne pas toucher les bords
    insetPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
    backgroundColor: Colors.transparent,
    child: Container(
      // MODIFICATION : On retire la hauteur fixe (MediaQuery... * 0.7)
      // On utilise constraints pour définir une hauteur MAX, mais il restera petit si peu de commentaires
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6, 
        maxWidth: 500, // Optionnel : limite la largeur sur tablette
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.zero, // Toujours pas d'arrondis
        border: Border.all(
          color: widget.isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // CRUCIAL : Réduit la taille verticale au minimum
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Commentaires (${widget.post.commentsCount})",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 20, 
                    color: widget.isDark ? Colors.white70 : Colors.black54),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Liste des commentaires
          // On utilise Flexible au lieu de Expanded pour que le Column puisse rétrécir
          Flexible(
            child: ListView.builder(
              shrinkWrap: true, // Aide à diminuer la longueur verticale
              padding: const EdgeInsets.all(16),
              itemCount: _comments.length,
              itemBuilder: (context, index) => _buildCommentItem(_comments[index]),
            ),
          ),

          // Zone de saisie
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: widget.isDark ? Colors.white10 : Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    maxLines: 2,
                    minLines: 1,
                    style: TextStyle(fontSize: 13, color: widget.isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Votre avis...",
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: widget.isDark ? Colors.white10 : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _submitComment,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.rectangle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 18),
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

  Widget _buildCommentItem(dynamic comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              comment.userName[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
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
                        color: widget.isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.formattedDate,
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    try {
      await _commentService.addComment(widget.post.shareableId, content);
      await _loadComments();
      widget.onCommentAdded();
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'ajout du commentaire")),
      );
    }
  }
}