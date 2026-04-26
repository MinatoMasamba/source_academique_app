// lib/core/services/notification_service.dart
import 'package:dio/dio.dart';
import 'package:source_academique/core/constants/api_endpoints.dart';
import 'package:source_academique/core/network/dio_client.dart';
import 'package:source_academique/features/auth/domain/entities/notification.dart';

class NotificationService {
  final DioClient _dioClient;

  NotificationService(this._dioClient);

  Future<List<AppNotification>> fetchNotifications() async {
    print("🔔 [NotificationService] ===== DÉBUT RÉCUPÉRATION NOTIFICATIONS =====");
    print("🔔 [NotificationService] URL: ${ApiEndpoints.notifications}");
    
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.notifications);
      
      print("🔔 [NotificationService] Statut HTTP: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data == null) {
          print("❌ [NotificationService] La réponse est null");
          throw Exception("La réponse du serveur est vide");
        }
        
        if (data is! List) {
          print("❌ [NotificationService] La réponse n'est pas une liste. Type reçu: ${data.runtimeType}");
          throw Exception("Format de réponse invalide: attendu une liste");
        }
        
        print("🔔 [NotificationService] Nombre d'éléments bruts: ${data.length}");
        
        final List<AppNotification> notifications = [];
        
        for (int i = 0; i < data.length; i++) {
          print("🔔 [NotificationService] --- Traitement de l'élément $i ---");
          try {
            final json = data[i];
            if (json is Map<String, dynamic>) {
              final notification = AppNotification.fromJson(json);
              notifications.add(notification);
              print("✅ [NotificationService] Élément $i ajouté avec succès");
            } else {
              print("⚠️ [NotificationService] Élément $i n'est pas un Map: ${json.runtimeType}");
            }
          } catch (e) {
            print("❌ [NotificationService] Erreur sur l'élément $i: $e");
            // Continuer avec l'élément suivant
          }
        }
        
        print("✅ [NotificationService] ${notifications.length} notifications valides chargées sur ${data.length}");
        return notifications;
        
      } else {
        print("❌ [NotificationService] Erreur HTTP: ${response.statusCode}");
        throw Exception("Erreur HTTP: ${response.statusCode}");
      }
      
    } on DioException catch (e) {
      print("❌ [NotificationService] Erreur Dio: ${e.type}");
      print("   Message: ${e.message}");
      if (e.response != null) {
        print("   StatusCode: ${e.response?.statusCode}");
        print("   Data: ${e.response?.data}");
      }
      throw Exception("Erreur réseau: ${e.message}");
    } catch (e, stackTrace) {
      print("❌ [NotificationService] Erreur inattendue: $e");
      print("📚 StackTrace: $stackTrace");
      throw Exception("Erreur: $e");
    }
  }

  Future<void> markAsRead(String notificationId) async {
    print("🔔 [NotificationService] Marquage notification $notificationId comme lue");
    try {
      await _dioClient.dio.post('${ApiEndpoints.notifications}$notificationId/read/');
      print("✅ [NotificationService] Notification $notificationId marquée comme lue");
    } catch (e) {
      print("❌ [NotificationService] Erreur lors du marquage: $e");
    }
  }

  Future<void> markAllAsRead() async {
    print("🔔 [NotificationService] Marquage de toutes les notifications comme lues");
    try {
      await _dioClient.dio.post('${ApiEndpoints.notifications}mark-all-read/');
      print("✅ [NotificationService] Toutes les notifications marquées comme lues");
    } catch (e) {
      print("❌ [NotificationService] Erreur: $e");
    }
  }
}