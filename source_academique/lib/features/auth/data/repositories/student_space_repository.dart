// lib/features/student_space/data/student_space_repository.dart
import 'package:dio/dio.dart';
import 'package:source_academique/core/constants/api_endpoints.dart';
import 'package:source_academique/core/network/dio_client.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';

class StudentSpaceRepository {
  final DioClient _dioClient;

  StudentSpaceRepository(this._dioClient);

  Future<List<PostNews>> getUserPosts(int userId) async {
    final response = await _dioClient.dio.get(ApiEndpoints.userPosts(userId));
    final List data = response.data;
    print("Posts reçus du serveur");
    return data.map((json) => PostNews.fromJson(json)).toList();
  }

  Future<PostNews> createPost(String content, {List<String>? filePaths}) async {
    print("Création de post avec contenu: $content et fichiers: $filePaths");
      if (filePaths == null || filePaths.isEmpty) {
        final response = await _dioClient.dio.post(
          ApiEndpoints.posts,
          data: {'titre': content},
        );
        print(  "Post créé sans fichier: ${response.data}");
        return PostNews.fromJson(response.data);
      } else {
        final filePath = filePaths.first;
        
        // 1. On extrait le nom du fichier du chemin
        String fileName = filePath.split('/').last;

        // 2. Création du FormData
        final formData = FormData.fromMap({
          'titre': content,
          'fichier': await MultipartFile.fromFile(
            filePath,
            filename: fileName, // TRÈS IMPORTANT pour Django
          ),
        });
        print("FormData préparé pour l'upload: $formData");

        // 3. Envoi SANS spécifier le Content-Type manuellement
        final response = await _dioClient.dio.post(
          ApiEndpoints.posts,
          data: formData,
          // SUPPRESSION DE : options: Options(headers: {...}),
        );
        
        return PostNews.fromJson(response.data);
      }
    }

  Future<PostNews> updatePost(String shareableId, String newContent) async {
    final response = await _dioClient.dio.put(
      ApiEndpoints.postDetail(shareableId),
      data: {'titre': newContent},
    );
    print("Post mis à jour: ${response.data}");
    return PostNews.fromJson(response.data);
  }

  Future<void> deletePost(String shareableId) async {
    await _dioClient.dio.delete(ApiEndpoints.postDetail(shareableId));
    print("Post supprimé: $shareableId");
  }

  Future<void> likePost(String shareableId) async {
    await _dioClient.dio.post(ApiEndpoints.postLike(shareableId));
    print("Post liké: $shareableId");
  }

  Future<void> unlikePost(String shareableId) async {
    await _dioClient.dio.delete(ApiEndpoints.postLike(shareableId));
    print("Post déliké: $shareableId");
  }

  Future<void> addComment(String shareableId, String content) async {
    await _dioClient.dio.post(
      ApiEndpoints.postComment(shareableId),
      data: {'content': content},
    );
    print("Commentaire ajouté: $content");
  }

  // Dans student_space_repository.dart

  Future<List<AcademicDocument>> getUserDocuments(int userId) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.userDocuments(userId),
    );
    final List data = response.data;
    print("Documents reçus du serveur: $data");
    return data
        .map((json) => AcademicDocument.fromJson(json, userId as String))
        .toList();
  }

  Future<AcademicDocument> uploadDocument(
    String filePath,
    String fileName,
  ) async {
    // Multipart upload
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final response = await _dioClient.dio.post(
      ApiEndpoints.uploadDocument,
      data: formData,
    );
    return AcademicDocument.fromJson(response.data, '');
  }

  Future<void> deleteDocument(int documentId) async {
    // DELETE /api/student/documents/:id/
  }

  Future<List<dynamic>> getAcademicResults() async {
    final response = await _dioClient.dio.get(ApiEndpoints.academicResults);
    final List data = response.data;
    return data;
  }

  Future<List<Comment>> getComments(String shareableId) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.postComments(shareableId),
    );
    final List data = response.data;
    return data.map((json) => Comment.fromJson(json)).toList();
  }

  Future<void> recordView(String shareableId) async {
    await _dioClient.dio.post(ApiEndpoints.postView(shareableId));
  }

  Future<void> sharePost(String shareableId) async {
    await _dioClient.dio.post(ApiEndpoints.postShare(shareableId));
  }

// lib/features/auth/data/repositories/student_space_repository.dart

// ... dans la classe StudentSpaceRepository
// lib/features/auth/data/repositories/student_space_repository.dart

// Ajoutez cette méthode
Future<PostNews?> getPostById(String shareableId) async {
  try {
    final response = await _dioClient.dio.get(ApiEndpoints.postDetail(shareableId));
    return PostNews.fromJson(response.data);
  } catch (e) {
    print("❌ Erreur récupération post $shareableId : $e");
    return null;
  }
}
/// Récupère tous les posts de la communauté (endpoint général /posts/)
Future<List<PostNews>> getCommunityPosts() async {
  final response = await _dioClient.dio.get(ApiEndpoints.posts);
  final List data = response.data;
  print("📡 Posts communauté reçus: ${data.length}");
  return data.map((json) => PostNews.fromJson(json)).toList();
}
}
