// lib/features/profile/data/repositories/profile_repository.dart

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:source_academique/core/network/dio_client.dart';
import 'package:source_academique/core/constants/api_endpoints.dart';
import 'package:source_academique/features/auth/domain/entities/profile_model.dart';

class ProfileRepository {
  final DioClient _dioClient;
  final SharedPreferences _prefs;
  static const String _cacheKey = 'cached_user_profile';

  ProfileRepository(this._dioClient, this._prefs);

  UserProfile? getCachedProfile() {
    final String? jsonString = _prefs.getString(_cacheKey);
    if (jsonString != null) {
      try {
        return UserProfile.fromJson(json.decode(jsonString));
      } catch (e) {
        print("Cache parsing error: $e");
        return null;
      }
    }
    return null;
  }

  Future<void> _saveToCache(UserProfile profile) async {
    final String jsonString = json.encode(profile.toJson());
    await _prefs.setString(_cacheKey, jsonString);
  }

  Future<UserProfile?> getMyProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.userProfile(0));
      if (response.statusCode == 200) {
        final profile = UserProfile.fromJson(response.data);
        await _saveToCache(profile);
        return profile;
      }
      return null;
    } catch (e) {
      print("getMyProfile error: $e");
      return null;
    }
  }

  // ✅ Mise à jour avec PATCH
  Future<UserProfile?> updateProfile(Map<String, dynamic> data) async {
    try {
      print("📤 Envoi PATCH vers ${ApiEndpoints.userProfile(0)}");
      print("📦 Données: $data");

      final response = await _dioClient.dio.patch(
        ApiEndpoints.userProfile(0),
        data: data,
      );

      print("✅ Réponse status: ${response.statusCode}");
      print("📄 Réponse body: ${response.data}");

      if (response.statusCode == 200) {
        final updatedProfile = UserProfile.fromJson(response.data);
        await _saveToCache(updatedProfile);
        return updatedProfile;
      }
      return null;
    } on DioException catch (e) {
      print("❌ DioException: ${e.response?.statusCode}");
      print("❌ Erreur: ${e.response?.data}");
      return null;
    } catch (e) {
      print("❌ Erreur inattendue: $e");
      return null;
    }
  }

 Future<UserProfile?> updateProfilePhoto(String filePath) async {
  try {
    // Vérification critique : le fichier existe-t-il ?
    final file = File(filePath);
    final exists = await file.exists();
    print("📸 Chemin : $filePath");
    print("📸 Fichier existe : $exists");
    if (!exists) {
      print("❌ Le fichier n'existe pas");
      return null;
    }

    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    print("📤 Envoi PATCH multipart vers ${ApiEndpoints.userProfile(0)}");

    final response = await _dioClient.dio.patch(
      ApiEndpoints.userProfile(0),
      data: formData,
      options: Options(
        headers: {
          // Ne pas forcer Content-Type, Dio le fera automatiquement
        },
      ),
    );

    if (response.statusCode == 200) {
      final updatedProfile = UserProfile.fromJson(response.data);
      await _saveToCache(updatedProfile);
      return updatedProfile;
    }
    return null;
  } on DioException catch (e) {
    print("❌ DioException: ${e.response?.statusCode}");
    print("❌ Détail: ${e.response?.data}");
    if (e.response?.statusCode == 415) {
      print("👉 Le backend n'accepte pas le multipart. Vérifie MultiPartParser.");
    }
    return null;
  } catch (e) {
    print("❌ Autre erreur: $e");
    return null;
  }
}
}