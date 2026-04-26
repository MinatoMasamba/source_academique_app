// lib/features/auth/domain/entities/academic_document.dart
import 'package:equatable/equatable.dart';
import 'package:source_academique/core/utils/image_utils.dart';

class AcademicDocument extends Equatable {
  final String id;
  final String title;
  final String faculty;
  final String badge;
  final String coverImageUrl;
  final double rating;
  final int reviewsCount;
  final String description;
  final String fileFormat;
  final String fileSize;
  final int pagesCount;
  final String author;
  final int totalViews;
  final String promotion;
  final DateTime dateAjout;
  final String? fichierUrl;
  final String type; // "cours", "tp", "examen", "interro", "note"

  const AcademicDocument({
    required this.id,
    required this.title,
    required this.faculty,
    required this.badge,
    required this.coverImageUrl,
    required this.rating,
    required this.reviewsCount,
    required this.description,
    required this.fileFormat,
    required this.fileSize,
    required this.pagesCount,
    required this.author,
    required this.totalViews,
    required this.promotion,
    required this.dateAjout,
    this.fichierUrl,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'faculty': faculty,
      'author': author,
      'cover_image': coverImageUrl,
      'file_url': fichierUrl,
      'file_size': fileSize,
      'file_format': fileFormat,
      'pages_count': pagesCount,
      'type': type,
      'description': description,
      'promotion': promotion,
      'date_ajout': dateAjout.toIso8601String(),  
      'badge': badge,
      'rating': rating,
      'reviews_count': reviewsCount,
      'total_views': totalViews,
      
    };
  }

factory AcademicDocument.fromJson(Map<String, dynamic> json, String docType) {
  // On récupère d'abord l'URL propre (priorité à fichier_url généré par Django)
  final String? effectiveUrl = json['fichier_url'] ?? json['fichier'];
  print("🔍 [AcademicDocument.fromJson] Création de AcademicDocument à partir du JSON:");
  print("📄 [AcademicDocument.fromJson] JSON reçu: $json");
  print("🔗 [AcademicDocument.fromJson] URL effective: $effectiveUrl");

  return AcademicDocument(
    id: json['id'].toString(),
    type: docType,
    // On utilise 'statut' pour le titre comme tu l'as fait
    title: json['statut'] != null && json['statut'].toString().length > 10 
        ? json['statut'] 
        : (json['statut'] ?? 'Sans titre'),
    faculty: json['faculter_nom'] ?? '',
    badge: docType.toUpperCase(),
    coverImageUrl: json['cover_image'] ?? 'https://via.placeholder.com/300x200?text=Document',
    rating: 0.0,
    reviewsCount: 0,
    description: json['description'] ?? '',
    // Correction ici : on vérifie l'extension sur l'URL effective
    fileFormat: effectiveUrl != null ? effectiveUrl.split('.').last.toUpperCase().split('?').first : 'PDF',
    fileSize: _formatFileSize(json['fileSize']),
    pagesCount: 0,
    author: json['auteur'] ?? 'Admin',
    totalViews: 0,
    promotion: json['promotion'] ?? 'N/A',
    dateAjout: json['date_ajout'] != null ? DateTime.parse(json['date_ajout']) : DateTime.now(),
    fichierUrl: effectiveUrl, // <--- UTILISE L'URL EFFECTIVE ICI
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

  @override
  List<Object?> get props => [id, type, title, faculty];
}


class Decouverte extends Equatable {
  final int id;
  final String lien;
  final String? image;
  final String? document;
  final String description;
  final DateTime dateCreation;
  final int? domaine;
  final String domaineNom;

  const Decouverte({
    required this.id,
    required this.lien,
    this.image,
    this.document,
    required this.description,
    required this.dateCreation,
    this.domaine,
    required this.domaineNom,
  });

  factory Decouverte.fromJson(Map<String, dynamic> json) => Decouverte(
    id: json['id'],
    lien: json['lien'] ?? '',
    image: json['image'] ??  ImageUtils.getDefaultImage('decouverte', seed: json['id'] ?? 0),
    document: json['document'],
    description: json['description'] ?? '',
    dateCreation: DateTime.parse(json['date_creation']),
    domaine: json['domaine'],
    domaineNom: json['domaine_nom'] ?? '',
  );

  @override
  List<Object?> get props => [id, lien, description];
}



class Projet extends Equatable {
  final int id;
  final String titre;
  final String description;
  final String? imageUrl;
  final String? auteur;
  final String? universite;
  final String? categorie;
  final DateTime dateCreation;
  final int? domaine;
  final String domaineNom;

  const Projet({
    required this.id,
    required this.titre,
    required this.description,
    this.imageUrl,
    this.auteur,
    this.universite,
    this.categorie,
    required this.dateCreation,
    this.domaine,
    required this.domaineNom,
  });

  factory Projet.fromJson(Map<String, dynamic> json) => Projet(
    id: json['id'],
    titre: json['titre'] ?? 'Sans titre',
    description: json['description'] ?? '',
    imageUrl: json['image_url'],
    auteur: json['auteur'],
    universite: json['universite'],
    categorie: json['categorie'],
    dateCreation: DateTime.parse(json['date_creation']),
    domaine: json['domaine'],
    domaineNom: json['domaine_nom'] ?? '',
  );

  @override
  List<Object?> get props => [id, titre];
}



class Article extends Equatable {
  final int id;
  final String titre;
  final String description;
  final String? imageUrl;
  final String categorie;
  final DateTime datePublication;
  final String? lien;
  final int? domaine;
  final String domaineNom;

  const Article({
    required this.id,
    required this.titre,
    required this.description,
    this.imageUrl,
    required this.categorie,
    required this.datePublication,
    this.lien,
    this.domaine,
    required this.domaineNom,
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    id: json['id'],
    titre: json['titre'] ?? 'Sans titre',
    description: json['description'] ?? '',
    imageUrl: json['image_url'],
    categorie: json['categorie'] ?? 'Général',
    datePublication: DateTime.parse(json['date_publication']),
    lien: json['lien'],
    domaine: json['domaine'],
    domaineNom: json['domaine_nom'] ?? '',
  );

  @override
  List<Object?> get props => [id, titre];

  Object? toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'image_url': imageUrl,
      'categorie': categorie,
      'date_publication': datePublication.toIso8601String(),
      'lien': lien,
      'domaine': domaine,
      'domaine_nom': domaineNom,
    };
  }
}




class StudentFile {
  final int? id;
  final int userId;
  final String? userName; // Optionnel : pour afficher qui l'a posté
  final String fileUrl;   // L'URL retournée par Django (ex: /media/student_files/mon_cours.pdf)
  final DateTime uploadedAt;
  final int sizeInBytes;  // Correspond à ta property file_size
  final int countfile; // Nombre de fichiers postés par l'utilisateur (optionnel, pour affichage)

  StudentFile({
    this.id,
    required this.userId,
    this.userName,
    required this.fileUrl,
    required this.uploadedAt,
    required this.sizeInBytes,
    this.countfile = 0,
  });

  /// Factory pour transformer le JSON de Django en objet Dart
  factory StudentFile.fromJson(Map<String, dynamic> json) {
    return StudentFile(
      id: json['id'],
      userId: json['user'], // Django renvoie souvent l'ID de l'user
      userName: json['user_name'], // Si ton serializer inclut le nom
      fileUrl: json['file'] ?? '',
      uploadedAt: DateTime.parse(json['uploaded_at']),
      sizeInBytes: json['file_size'] ?? 0,
      countfile: json['documents_count'] ?? 0,
    );
  }

  /// Convertir l'objet en JSON pour les envois (POST)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'file': fileUrl,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }

  // --- Helpers pour l'UI ---

  /// Retourne le nom du fichier extrait de l'URL
  String get fileName => fileUrl.split('/').last;

  /// Retourne l'extension (PDF, PNG, etc.) en majuscules
  String get fileExtension => fileName.split('.').last.toUpperCase();

  /// Formate la taille du fichier pour l'affichage (ex: 1.2 MB ou 45 KB)
  String get formattedSize {
    if (sizeInBytes <= 0) return "0 B";
    if (sizeInBytes < 1024) return "$sizeInBytes B";
    if (sizeInBytes < 1024 * 1024) {
      return "${(sizeInBytes / 1024).toStringAsFixed(1)} KB";
    }
    return "${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }
}