// lib/presentation/features/space_stadent/widgets/posts/composants/post_like_logic.dart
import 'package:source_academique/features/auth/domain/entities/student_post.dart';

class PostLikeLogic {
  /// Mise à jour optimiste locale
  static List<PostNews> optimisticUpdate(
    List<PostNews> posts,
    String shareableId,
    bool isCurrentlyLiked,
  ) {
    return posts.map((post) {
      if (post.shareableId == shareableId) {
        final newIsLiked = !isCurrentlyLiked;
        final delta = newIsLiked ? 1 : -1;
        return post.copyWith(
          isLiked: newIsLiked,
          likesCount: post.likesCount + delta,
        );
      }
      return post;
    }).toList();
  }
}