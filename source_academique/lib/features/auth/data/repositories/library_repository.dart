import 'package:source_academique/core/network/dio_client.dart';
import 'package:source_academique/core/constants/api_endpoints.dart';
import 'package:source_academique/core/utils/image_utils.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';

class LibraryRepository {
  final DioClient _dioClient;

  LibraryRepository(this._dioClient);

  /// Récupère tous les documents (cours, TP, examens, interros, notes)
  Future<List<AcademicDocument>> getAllDocuments() async {
    print("📚 [LibraryRepository.getAllDocuments] Début récupération de tous les documents académiques pour l'utilisateur connecté");
    final List<Future<List<AcademicDocument>>> futures = [
      _fetchByType(ApiEndpoints.cours, 'cours'),
      _fetchByType(ApiEndpoints.tp, 'tp'),
      _fetchByType(ApiEndpoints.examens, 'examen'),
      _fetchByType(ApiEndpoints.interros, 'interro'),
      _fetchByType(ApiEndpoints.notes, 'note'),
    ];
    final List<List<AcademicDocument>> results = await Future.wait(futures);
    print("📚 [LibraryRepository.getAllDocuments] Récupération terminée : ${results.fold(0, (sum, list) => sum + list.length)} documents au total");
    return results.expand((list) => list).toList();
  }


  Future<List<AcademicDocument>> _fetchByType(String endpoint, String type) async {
    print("📄 [LibraryRepository._fetchByType] Récupération des documents de type '$type' depuis $endpoint");
    try {
      final response = await _dioClient.dio.get(endpoint);
      final List data = response.data;
      return data.map((json) => _mapToAcademicDocument(json, type)).toList();
    } catch (e) {
      return [];
    }
  }

  AcademicDocument _mapToAcademicDocument(Map<String, dynamic> json, String type) {
    print("📄 [LibraryRepository._mapToAcademicDocument] Mapping document ID: ${json['id']} de type '$type'");
    final String? effectiveUrl = json['fichier_url'] ?? json['fichier'];
    print("🔍 [LibraryRepository._mapToAcademicDocument] Création de AcademicDocument à partir du JSON:");
    print("📄 [LibraryRepository._mapToAcademicDocument] JSON reçu: $json");
    print("🔗 [LibraryRepository._mapToAcademicDocument] URL effective: $effectiveUrl");
    return AcademicDocument(
      id: json['id'].toString(),
      title: json['statut'] ?? 'Sans titre',
      faculty: json['faculter_nom'] ?? '',
      badge: type.toUpperCase(),
      coverImageUrl: ImageUtils.getDefaultImage(type, seed: json['id'] ?? 0), // À remplacer par une vraie image si disponible
      rating: 0.0,
      reviewsCount: 0,
      description: json['description'] ?? '',
      fileFormat: 'PDF',
      fileSize: _formatFileSize(json['fileSize']) ,
      pagesCount: 0,
      author: json['auteur'] ?? 'Admin',
      totalViews: 0,
      promotion: json['promotion'] ?? '',
      dateAjout: DateTime.parse(json['date_ajout']),
      type: type,
      fichierUrl: effectiveUrl,
    );
  }

  static String _formatFileSize(dynamic size) {
    if (size == null) return '--';
    if (size is int) {
      if (size < 1024) return '$size B';
      if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return size.toString();
  }
}