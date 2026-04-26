// lib/presentation/features/space_stadent/widgets/posts/student_post_item.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';
import 'package:source_academique/presentation/features/space_stadent/presentation/bloc/student_space_bloc.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/posts/composants/post_header.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/posts/composants/post_body.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/posts/composants/post_actions.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/shared/student_glass_card.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/posts/comment_sheet.dart';

class StudentPostItem extends StatelessWidget {
  final PostNews post;
  final bool isOwner;

  const StudentPostItem({
    super.key,
    required this.post,
    required this.isOwner,
  });

  void _showPostDetail(BuildContext context) {
    print("🔍 [PostDetail] Ouverture détail du post: ${post.shareableId}");
    try {
      // Enregistrer la vue
      context.read<StudentSpaceBloc>().add(RecordViewEvent(post.shareableId));
      print("✅ [PostDetail] Vue enregistrée pour: ${post.shareableId}");
      // Naviguer vers l'écran de détail (si implémenté)
      // context.push('/post/${post.shareableId}', extra: post);
    } catch (e) {
      print("❌ [PostDetail] Erreur: $e");
    }
  }

  void _showComments(BuildContext context) {
      // Récupère le bloc existant
    final bloc = context.read<StudentSpaceBloc>();
    print("💬 [Comments] Ouverture des commentaires pour post: ${post.shareableId}");
    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (bottomSheetContext) => BlocProvider.value(
      value: bloc,  // ← transmet le même bloc
      child: CommentSheet(post: post),
    ),
      );
      print("✅ [Comments] BottomSheet ouverte");
    } catch (e) {
      print("❌ [Comments] Erreur ouverture: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'ouverture des commentaires")),
      );
    }
  }

  void _toggleLike(BuildContext context) {
    print("❤️ [Like] Toggle like - Post: ${post.shareableId}, isLiked: ${post.isLiked}");
    try {
      context.read<StudentSpaceBloc>().add(ToggleLikeEvent(post.shareableId, post.isLiked));
      print("✅ [Like] Événement envoyé au Bloc");
    } catch (e) {
      print("❌ [Like] Erreur: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors du like")),
      );
    }
  }

void _sharePost(BuildContext context) async {  // ← AJOUTER async
  print("📤 [Share] Partage du post: ${post.shareableId}");
  try {
    // 1. Envoyer l'événement au Bloc pour enregistrer le partage sur le serveur
    context.read<StudentSpaceBloc>().add(SharePostEvent(post.shareableId));
    print("✅ [Share] Événement de partage envoyé");
    
    // 2. Ouvrir la feuille de partage système
    await Share.share(
      post.shareableLink,
      subject: post.titre,  // Optionnel : sujet pour les emails
    );
    print("✅ [Share] Feuille de partage ouverte");
    
  } catch (e) {
    print("❌ [Share] Erreur: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur lors du partage: $e")),
    );
  }
}

  void _savePost(BuildContext context) {
    print("🔖 [Save] Sauvegarde du post: ${post.shareableId}");
    // Fonctionnalité à venir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sauvegarde bientôt disponible"), duration: Duration(seconds: 1)),
    );
  }

  void _editPost(BuildContext context) {
    print("✏️ [Edit] Modification du post: ${post.shareableId}");
    // TODO: Ouvre le dialogue d'édition (délégué à l'écran parent)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Modification bientôt disponible"), duration: Duration(seconds: 1)),
    );
  }

  void _deletePost(BuildContext context) {
    print("🗑️ [Delete] Suppression du post: ${post.shareableId}");
    // Confirmation avant suppression
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Supprimer le post"),
        content: const Text("Voulez-vous vraiment supprimer cette publication ?"),
        actions: [
          TextButton(
            onPressed: () {
              print("❌ [Delete] Annulation suppression");
              Navigator.pop(dialogContext);
            },
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              try {
                print("✅ [Delete] Confirmation suppression - Envoi événement");
                context.read<StudentSpaceBloc>().add(DeletePostEvent(post.shareableId));
                Navigator.pop(dialogContext);
                print("✅ [Delete] Post supprimé avec succès");
              } catch (e) {
                print("❌ [Delete] Erreur suppression: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erreur lors de la suppression: $e")),
                );
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("🎨 [Build] Construction du widget StudentPostItem - id: ${post.id}, titre: ${post.titre.substring(0, post.titre.length > 50 ? 50 : post.titre.length)}...");
    
    return StudentGlassCard(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostHeader(
            post: post,
            isOwner: isOwner,
            onEdit: () => _editPost(context),
            onDelete: () => _deletePost(context),
            onShare: () => _sharePost(context),
          ),
          const SizedBox(height: 12),
          PostBody(
            post: post,
            onTap: () => _showPostDetail(context),
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
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}