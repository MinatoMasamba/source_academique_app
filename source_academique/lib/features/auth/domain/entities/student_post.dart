import 'dart:convert';

import 'package:intl/intl.dart';

// ==========================================
// MODÈLE : POST NEWS
// ==========================================
class PostNews {
  // --- Propriétés ---
  final int id;
  final String shareableId;
  final Map<String, dynamic> user;
  final String titre;
  final String? titreHtml;
  final String? fichier;
  final String? fichierUrl;
  final DateTime dateAjout;
  final String? promotion;
  final String? universiter;
  final String? faculter;
  final String? departement;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final int sharesCount;
  final bool isLiked;
  final bool isSaved;
  final String shareableLink;

  // --- Constructeur ---
  PostNews({
    required this.id,
    required this.shareableId,
    required this.user,
    required this.titre,
    this.titreHtml,
    this.fichier,
    this.fichierUrl,
    required this.dateAjout,
    this.promotion,
    this.universiter,
    this.faculter,
    this.departement,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
    this.sharesCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    required this.shareableLink,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': shareableId,
      'titre': titre,
      'titre_html': titreHtml,
      'fichier': fichierUrl,
      'faculte': faculter,
      'universiter': universiter,
      'departement': departement,
      'vues_count': viewsCount,
      'shares_count': sharesCount,
      'is_saved': isSaved,
      'shareable_link': shareableLink,
      'date': formattedDate,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked': isLiked,
    };
  }

  // --- Deserialization (JSON) ---
  factory PostNews.fromJson(Map<String, dynamic> json) {
    return PostNews(
      id: json['id'],
      shareableId: json['shareable_id'].toString(),
      user: json['user'] ?? {},
      titre: json['titre'] ?? '',
      titreHtml: json['titre_html'],
      fichier: json['fichier'],
      fichierUrl: json['fichier_url'],
      dateAjout: DateTime.parse(json['date_ajout']),
      promotion: json['promotion'],
      universiter: json['universiter'],
      faculter: json['faculter'],
      departement: json['departement'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      viewsCount: json['views_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isSaved: json['is_saved'] ?? false,
      shareableLink: json['shareable_link'] ?? '',
    );
  }

  // --- Getters pour l'UI ---
  String get userFullName {
    final firstName = user['first_name'] ?? '';
    final lastName = user['last_name'] ?? '';
    final userName = user['username'] ?? '';

    if (firstName.isEmpty && lastName.isEmpty) {
      return userName.isNotEmpty ? userName : 'Utilisateur';
    }
    return '$firstName $lastName'.trim();
  }

  String? get userAvatar => json['user_photo'] ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userFullName)}&background=random';

  String get formattedDate {
    final diff = DateTime.now().difference(dateAjout);
    if (diff.inDays > 7) return DateFormat('dd/MM/yyyy').format(dateAjout);
    if (diff.inDays > 0) return "Il y a ${diff.inDays}j";
    if (diff.inHours > 0) return "Il y a ${diff.inHours}h";
    if (diff.inMinutes > 0) return "Il y a ${diff.inMinutes}min";
    return "À l'instant";
  }

  // --- Méthodes ---
  PostNews copyWith({
    int? id,
    String? shareableId,
    Map<String, dynamic>? user,
    String? titre,
    String? titreHtml,
    String? fichier,
    String? fichierUrl,
    DateTime? dateAjout,
    String? promotion,
    String? universiter,
    String? faculter,
    String? departement,
    int? likesCount,
    int? commentsCount,
    int? viewsCount,
    int? sharesCount,
    bool? isLiked,
    bool? isSaved,
    String? shareableLink,
  }) {
    return PostNews(
      id: id ?? this.id,
      shareableId: shareableId ?? this.shareableId,
      user: user ?? this.user,
      titre: titre ?? this.titre,
      titreHtml: titreHtml ?? this.titreHtml,
      fichier: fichier ?? this.fichier,
      fichierUrl: fichierUrl ?? this.fichierUrl,
      dateAjout: dateAjout ?? this.dateAjout,
      promotion: promotion ?? this.promotion,
      universiter: universiter ?? this.universiter,
      faculter: faculter ?? this.faculter,
      departement: departement ?? this.departement,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      shareableLink: shareableLink ?? this.shareableLink,
    );
  }
}

extension on JsonCodec {
  String? operator [](String other) {}
}

// ==========================================
// MODÈLE : COMMENT
// ==========================================
class Comment {
  // --- Propriétés ---
  final int id;
  final int userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final DateTime createdAt;

  // --- Constructeur ---
  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.createdAt,
  });

  // --- Deserialization (JSON) ---
factory Comment.fromJson(Map<String, dynamic> json) {
  // On récupère la donnée brute du champ user
  final userRaw = json['user'];
  
  int extractedUserId;
  
  // Si c'est déjà un int, on le prend. 
  // Si c'est un Map (objet), on prend le champ 'id' à l'intérieur.
  if (userRaw is int) {
    extractedUserId = userRaw;
  } else if (userRaw is Map) {
    extractedUserId = userRaw['id'] ?? 0;
  } else {
    extractedUserId = 0;
  }

  return Comment(
    id: json['id'],
    userId: extractedUserId, // Utilise la valeur extraite
    userName: json['user']['username'] ?? 'Utilisateur',
    userAvatar: json['user_avatar'] ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(json['user']['username'] ?? 'Utilisateur')}&background=random',
    content: json['content'] ?? '',
    createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
  );
}

  // --- Getters ---
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    if (difference.inDays > 7) return DateFormat('dd/MM/yyyy').format(createdAt);
    if (difference.inDays > 0) return "Il y a ${difference.inDays}j";
    if (difference.inHours > 0) return "Il y a ${difference.inHours}h";
    if (difference.inMinutes > 0) return "Il y a ${difference.inMinutes}min";
    return "Maintenant";
  }
}