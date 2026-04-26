// TODO Implement this library.
// lib/presentation/features/home/services/comment_service.dart
import 'package:flutter/foundation.dart';
import 'package:source_academique/core/config/service_locator.dart';
import 'package:source_academique/core/constants/api_endpoints.dart';
import 'package:source_academique/core/network/dio_client.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';

class CommentService {
  final DioClient _dioClient = sl<DioClient>();

  Future<List<Comment>> fetchComments(String postId) async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.postComments(postId));
      final List data = response.data;
      return data.map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Erreur chargement commentaires: $e");
      return [];
    }
  }

  Future<void> addComment(String postId, String content) async {
    try {
      await _dioClient.dio.post(
        ApiEndpoints.postComment(postId),
        data: {'content': content},
      );
    } catch (e) {
      debugPrint("Erreur ajout commentaire: $e");
      rethrow;
    }
  }
}