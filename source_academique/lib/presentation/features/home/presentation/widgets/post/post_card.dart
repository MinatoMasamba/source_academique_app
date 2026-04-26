import 'package:flutter/material.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';
import 'package:source_academique/presentation/features/home/presentation/widgets/post/comment_modal.dart';
import 'package:source_academique/presentation/features/home/presentation/widgets/post/post_content.dart';
import 'package:source_academique/presentation/features/home/presentation/widgets/post_actions.dart';


class PostCard extends StatefulWidget {
  final PostNews post;
  final bool isDark;

  const PostCard({super.key, required this.post, required this.isDark});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool isLiked;
  late int likeCount;
  late int commentCount;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.isLiked;
    likeCount = widget.post.likesCount;
    commentCount = widget.post.commentsCount;
  }

  void _handleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
    // TODO: Appel API like/unlike via HomeBloc ou service dédié
  }

  void _handleCommentAdded() {
    setState(() {
      commentCount++;
    });
    // Optionnel : notifier l'écran parent pour rafraîchir les données globales
  }

  void _showFullImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  void _showCommentModal() {
    showDialog(
      context: context,
      //isScrollControlled: true,
      //backgroundColor: Colors.transparent,
      builder: (context) => CommentModal(
        post: widget.post,
        isDark: widget.isDark,
        onCommentAdded: _handleCommentAdded,
      ),
    );
  }

 void _showPostOptions() {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        // On retire les marges par défaut du Dialog pour contrôler la taille
        insetPadding: const EdgeInsets.symmetric(horizontal: 40), 
        backgroundColor: Colors.transparent,
        child: Container(
          // Pas d'arrondis, comme demandé
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.zero, 
            border: Border.all(
              color: widget.isDark ? Colors.white10 : Colors.grey.shade200,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // S'adapte à la taille du contenu
            children: [
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.red),
                title: const Text("Signaler"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Post signalé")),
                  );
                },
              ),
              Divider(
                height: 1, 
                color: widget.isDark ? Colors.white10 : Colors.grey.shade200,
              ),
              ListTile(
                leading: const Icon(Icons.copy_outlined, color: Colors.grey),
                title: const Text("Copier le lien"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lien copié")),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

  void _sharePost() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Partage en cours...")),
    );
    // TODO: Implémenter partage réel
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: widget.isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: widget.post.userAvatar != null ? NetworkImage(widget.post.userAvatar!) : null,
                child: widget.post.userAvatar == null
                    ? Text(widget.post.userFullName.isNotEmpty ? widget.post.userFullName[0].toUpperCase() : 'U')
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.userFullName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      "${widget.post.formattedDate} • ${widget.post.faculter ?? 'Faculté inconnue'}",
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showPostOptions,
                icon: const Icon(Icons.more_vert, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Contenu (Markdown + image)
         PostContent(
            htmlContent: widget.post.titreHtml ?? widget.post.titre, // titreHtml contient le HTML
            imageUrl: widget.post.fichierUrl,
            isDark: widget.isDark,
            onImageTap: () => _showFullImage(widget.post.fichierUrl!),
          ),

          const SizedBox(height:5),

          // Actions
          PostActions(
            isLiked: isLiked,
            likeCount: likeCount,
            commentCount: commentCount,
            isDark: widget.isDark,
            onLike: _handleLike,
            onComment: _showCommentModal,
            onShare: _sharePost,
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}