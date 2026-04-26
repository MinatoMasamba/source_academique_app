// lib/features/home/data/home_repository.dart
import 'dart:convert';

import 'package:source_academique/core/network/dio_client.dart';
import 'package:source_academique/core/constants/api_endpoints.dart';
import 'package:source_academique/core/utils/image_utils.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';


class HomeRepository {
  final DioClient _dioClient;

  HomeRepository(this._dioClient);

  // 1. Découvertes -> transformées en AcademicDocument pour DiscoveryCard
  Future<List<AcademicDocument>> getDiscoveries() async {
    final response = await _dioClient.dio.get(ApiEndpoints.decouvertes);
    final List data = response.data;
    return data.map((json) => _decouverteToAcademicDocument(Decouverte.fromJson(json))).toList();
  }

  // 2. Articles -> transformés en AcademicDocument pour ArticleTrendItem
// lib/features/home/data/home_repository.dart

// Modifier la méthode getArticles pour retourner List<Article>
  Future<List<Article>> getArticles() async {
    print("📰 [HomeRepository.getArticles] Récupération des articles");
    final response = await _dioClient.dio.get(ApiEndpoints.articles);
    final List data = response.data;
    print("📰 [HomeRepository.getArticles] ${data.length} articles reçus");
    return data.map((json) => Article.fromJson(json)).toList();
  }
  // Dans home_repository.dart
Future<Article?> getArticleById(int id) async {
  try {
    final response = await _dioClient.dio.get(ApiEndpoints.articleDetail(id));
    return Article.fromJson(response.data);
  } catch (e) {
    print("❌ Erreur récupération article $id : $e");
    return null;
  }
}
Future<PostNews?> getPostById(String shareableId) async {
  try {
    final response = await _dioClient.dio.get(ApiEndpoints.postDetail(shareableId));
    return PostNews.fromJson(response.data);
  } catch (e) { return null; }
}
// lib/features/home/data/home_repository.dart

Future<List<Decouverte>> getAllDiscoveries() async {
  print("🔍 [HomeRepository.getAllDiscoveries] Récupération de toutes les découvertes");
  final response = await _dioClient.dio.get(ApiEndpoints.decouvertes);
  final List data = response.data;
  print("🔍 [HomeRepository.getAllDiscoveries] ${data.length} découvertes reçues");
  return data.map((json) => Decouverte.fromJson(json)).toList();
}

Future<Projet?> getProjectById(int id) async {
  print("🚀 [HomeRepository.getProjectById] Récupération projet ID: $id");
  try {
    final response = await _dioClient.dio.get(ApiEndpoints.projetDetail(id));
    if (response.statusCode == 200) {
      print("✅ [HomeRepository.getProjectById] Projet trouvé");
      return Projet.fromJson(response.data);
    } else {
      print("⚠️ [HomeRepository.getProjectById] StatusCode: ${response.statusCode}");
      return null;
    }
  } catch (e, stackTrace) {
    print("❌ [HomeRepository.getProjectById] Erreur: $e");
    print("📚 StackTrace: $stackTrace");
    return null;
  }
}

  // 3. Posts communautaires (pour la section Community)
  Future<List<PostNews>> getCommunityPosts() async {
    final response = await _dioClient.dio.get(ApiEndpoints.posts);
    final List data = response.data;
    return data.map((json) => PostNews.fromJson(json)).toList();
  }

  // 4. Documents recommandés (fusion de cours, TP, examens, interros, notes)
  Future<List<AcademicDocument>> getRecommendedDocuments() async {
    print("📚 [HomeRepository.getRecommendedDocuments] Récupération des documents recommandés");
    final List<Future<List<AcademicDocument>>> futures = [
      _fetchByType(ApiEndpoints.userCours, 'cours'),
      _fetchByType(ApiEndpoints.userTp, 'tp'),
      _fetchByType(ApiEndpoints.userExamens, 'examen'),
      _fetchByType(ApiEndpoints.userInterros, 'interro'), 
      _fetchByType(ApiEndpoints.userNotes, 'note'),
    ];
    final List<List<AcademicDocument>> results = await Future.wait(futures);
    
    print("📚 [HomeRepository.getRecommendedDocuments] Récupération terminée : ${results.fold(0, (sum, list) => sum + list.length)} documents recommandés au total");
    return results.expand((list) => list).toList();
  }

  Future<List<AcademicDocument>> _fetchByType(String endpoint, String type) async {
    print("📄 [HomeRepository._fetchByType] Récupération des documents de type '$type' depuis $endpoint");
    try {
      final response = await _dioClient.dio.get(endpoint);
      
      // VERIFICATION : Est-ce une Map (nouveau format) ou une List (ancien format) ?
      if (response.data is Map<String, dynamic>) {
        // On récupère la liste située dans la clé 'documents'
        final List rawData = response.data['documents'] ?? [];
        return rawData.map((json) => _genericDocumentToAcademicDocument(json, type)).toList();
      } else if (response.data is List) {
        // Au cas où tu reviendrais à l'ancien format
        final List data = response.data;
        return data.map((json) => _genericDocumentToAcademicDocument(json, type)).toList();
      }
      
      return [];
    } catch (e) {
      print("❌ Erreur de parsing pour $type: $e");
      return [];
    }
  }

  // Mappers
  AcademicDocument _decouverteToAcademicDocument(Decouverte d) {
    print("📄 [HomeRepository._decouverteToAcademicDocument] Mapping Decouverte ID: ${d.id}");
    return AcademicDocument(
      id: d.id.toString(),
      title: d.description,
      faculty: d.domaineNom,
      badge: 'Découverte',
      coverImageUrl:   ImageUtils.getDefaultImage('decouverte', seed: d.id.hashCode),
      rating: 0.0,
      reviewsCount: 0,
      description: d.description,
      fileFormat: '',
      fileSize: '',
      pagesCount: 0,
      author: '',
      totalViews: 0,
      promotion: '',
      dateAjout: d.dateCreation,
      type: 'decouverte',
    );
  }

  AcademicDocument _articleToAcademicDocument(Article a) {
    print("📄 [HomeRepository._articleToAcademicDocument] Mapping Article ID: ${a.id}");
    return AcademicDocument(
      id: a.id.toString(),
      title: a.titre,
      faculty: a.domaineNom,
      badge: 'Article',
      coverImageUrl: a.imageUrl ??  ImageUtils.getDefaultImage('article', seed: a.id.hashCode),
      rating: 0.0,
      reviewsCount: 0,
      description: a.description,
      fileFormat: '',
      fileSize: '',
      pagesCount: 0,
      author: '',
      totalViews: 0,
      promotion: '',
      dateAjout: a.datePublication,
      type: 'article',
    );
  }

   // Dans HomeRepository
static const String _baseUrl = 'https://minatomasamba.pythonanywhere.com';

AcademicDocument _genericDocumentToAcademicDocument(Map<String, dynamic> json, String type) {
  // --- URL du fichier (absolue) ---
  final rawFileUrl = json['fichier'] ?? json['fichier_url'];
  final String? fileUrl = rawFileUrl != null
      ? (rawFileUrl.toString().startsWith('http')
          ? rawFileUrl.toString()
          : '$_baseUrl$rawFileUrl')
      : null;

  final fileFormat = fileUrl != null
      ? fileUrl.split('.').last.toUpperCase().split('?').first
      : 'PDF';

  // --- Titre ---
  String title = json['title']?.toString() ?? '';
  if (title.isEmpty) {
    title = json['titre']?.toString() ?? '';
  }
  if (title.isEmpty) {
    title = 'Document sans titre';
  }

  // --- Image de couverture ---
  final coverImage = json['image'] != null
      ? (json['image'].toString().startsWith('http')
          ? json['image']
          : '$_baseUrl${json['image']}')
      : ImageUtils.getDefaultImage(type, seed: json['id'].hashCode);

  return AcademicDocument(
    id: json['id'].toString(),
    title: title,
    faculty: json['faculter_nom'] ?? '',
    badge: type.toUpperCase(),
    coverImageUrl: coverImage,
    rating: 0.0,
    reviewsCount: 0,
    description: json['description'] ?? '',
    fileFormat: fileFormat,
    fileSize: _formatFileSize(json['file_size']),
    pagesCount: json['pages'] ?? 0,
    author: json['auteur'] ?? '',
    totalViews: 0,
    promotion: json['promotion'] ?? '',
    dateAjout: json['date_ajout'] != null
        ? DateTime.parse(json['date_ajout'])
        : DateTime.now(),
    fichierUrl: fileUrl,  // ← maintenant absolue
    type: type,
  );
}
    String _formatFileSize(dynamic size) {
    if (size == null) return '--';
    if (size is int) {
      if (size < 1024) return '$size B';
      if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return size.toString();
  }
}