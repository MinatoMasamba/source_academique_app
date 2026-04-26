// lib/features/auth/domain/entities/notification.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum NotificationType {
  document,
  decouverte,
  projet,
  article,
  post,
  studentFile,
}

class AppNotification extends Equatable {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String? imageUrl;
  final String targetId;
  final DateTime createdAt;
  bool isRead;
  final dynamic originalObject;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.imageUrl,
    required this.targetId,
    required this.createdAt,
    this.isRead = false,
    this.originalObject,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    print("🔔 [AppNotification.fromJson] Début parsing du JSON");
    
    try {
      // Vérification des champs obligatoires avec fallbacks
      final String rawId = _safeString(json['id'], defaultValue: 'unknown');
      final String rawType = _safeString(json['type'], defaultValue: 'post');
      final String rawTitle = _safeString(json['title'], defaultValue: 'Notification');
      final String rawMessage = _safeString(json['message'], defaultValue: '');
      final String? rawImageUrl = _safeStringOrNull(json['image_url']);
      final String rawTargetId = _safeString(json['target_id'], defaultValue: rawId);
      final DateTime rawCreatedAt = _safeDateTime(json['date'], fallback: DateTime.now());
      final bool rawIsRead = json['is_read'] == true;
      
      print("   📝 id: $rawId");
      print("   📝 type: $rawType");
      print("   📝 title: $rawTitle");
      print("   📝 message: ${rawMessage.length > 50 ? rawMessage.substring(0, 50) + '...' : rawMessage}");
      print("   📝 targetId: $rawTargetId");
      print("   📝 createdAt: $rawCreatedAt");
      print("   📝 isRead: $rawIsRead");
      
      return AppNotification(
        id: rawId,
        type: _parseType(rawType),
        title: rawTitle,
        message: rawMessage,
        imageUrl: rawImageUrl,
        targetId: rawTargetId,
        createdAt: rawCreatedAt,
        isRead: rawIsRead,
        originalObject: json,
      );
      
    } catch (e, stackTrace) {
      print("❌ [AppNotification.fromJson] Erreur lors du parsing: $e");
      print("📚 StackTrace: $stackTrace");
      print("📄 JSON problématique: $json");
      
      // Retourne une notification par défaut en cas d'erreur
      return AppNotification(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.post,
        title: 'Erreur de chargement',
        message: 'Impossible de charger cette notification',
        targetId: '0',
        createdAt: DateTime.now(),
        isRead: false,
      );
    }
  }

  static String _safeString(dynamic value, {required String defaultValue}) {
    if (value == null) {
      print("   ⚠️ Champ null, utilisation de la valeur par défaut: '$defaultValue'");
      return defaultValue;
    }
    return value.toString();
  }

  static String? _safeStringOrNull(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    return str.isEmpty ? null : str;
  }

  static DateTime _safeDateTime(dynamic value, {required DateTime fallback}) {
    if (value == null) {
      print("   ⚠️ Date null, utilisation de la date actuelle");
      return fallback;
    }
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      print("   ⚠️ Impossible de parser la date '$value', utilisation de la date actuelle");
      return fallback;
    }
  }

  static NotificationType _parseType(String type) {
    print("   🔍 Parsing du type: '$type'");
    final normalizedType = type.toLowerCase().trim();
    
    switch (normalizedType) {
      case 'post':
        return NotificationType.post;
      case 'decouverte':
      case 'discovery':
        return NotificationType.decouverte;
      case 'article':
        return NotificationType.article;
      case 'projet':
      case 'project':
        return NotificationType.projet;
      case 'document':
      case 'cours':
      case 'tp':
      case 'interro':
      case 'examen':
      case 'note':
        return NotificationType.document;
      case 'studentfile':
      case 'student_file':
        return NotificationType.studentFile;
      default:
        print("   ⚠️ Type non reconnu: '$type', utilisation du type par défaut 'post'");
        return NotificationType.post;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'message': message,
    'image_url': imageUrl,
    'target_id': targetId,
    'created_at': createdAt.toIso8601String(),
    'is_read': isRead,
  };

  IconData get icon {
    switch (type) {
      case NotificationType.post: return Icons.chat_bubble_outline;
      case NotificationType.decouverte: return Icons.lightbulb_outline;
      case NotificationType.article: return Icons.article_outlined;
      case NotificationType.projet: return Icons.rocket_launch_outlined;
      case NotificationType.document: return Icons.description_outlined;
      case NotificationType.studentFile: return Icons.cloud_upload_outlined;
    }
  }

  Color get iconColor {
    switch (type) {
      case NotificationType.post: return Colors.blue;
      case NotificationType.decouverte: return Colors.orange;
      case NotificationType.article: return Colors.green;
      case NotificationType.projet: return Colors.purple;
      case NotificationType.document: return Colors.red;
      case NotificationType.studentFile: return Colors.teal;
    }
  }

  String getTypeLabel() {
    switch (type) {
      case NotificationType.post: return "POST";
      case NotificationType.decouverte: return "DÉCOUVERTE";
      case NotificationType.article: return "ARTICLE";
      case NotificationType.projet: return "PROJET";
      case NotificationType.document: return "DOCUMENT";
      case NotificationType.studentFile: return "FICHIER ÉTUDIANT";
    }
  }

  @override
  List<Object?> get props => [id, type, targetId, isRead];
}