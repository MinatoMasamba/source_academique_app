import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:source_academique/core/constants/api_endpoints.dart';
import 'package:source_academique/core/network/dio_client.dart';
import '../../domain/entities/user.dart';

class AuthRepository {
  final DioClient _dioClient;
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  AuthRepository(this._dioClient, this._secureStorage, this._prefs);
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserData = 'user_data';

  /// Connexion acceptant email ou nom d'utilisateur
  Future<User> login(String identifier, String password) async {
    print("🔷 [AuthRepository.login] Tentative de connexion avec identifier: $identifier");
    const String methodName = 'AuthRepository.login';
    print("🔷 [$methodName] Début avec identifier: $identifier");

    try {
      final isEmail = identifier.contains('@');
      final requestData = isEmail
          ? {'email': identifier, 'password': password}
          : {'username': identifier, 'password': password};
      print("🔹 [$methodName] Type d'identifiant: ${isEmail ? 'email' : 'username'}");

      print("🔹 [$methodName] Envoi requête POST à ${ApiEndpoints.login}");
      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: requestData,
      );

      final data = response.data;
      final accessToken = data['access'];
      final refreshToken = data['refresh'];
      final userData = data['user'];

      if (accessToken == null || refreshToken == null || userData == null) {
        throw Exception("Réponse du serveur invalide : tokens ou user manquants.");
      }
      print("✅ [$methodName] Tokens reçus avec succès");

      await _secureStorage.write(key: 'access_token', value: accessToken);
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);
      await _prefs.setString(_keyUserData, jsonEncode(userData));
      await _prefs.setBool(_keyIsLoggedIn, true);
      await _secureStorage.write(key: 'user_data', value: jsonEncode(userData));

      final savedToken = await _secureStorage.read(key: 'access_token');
      final savedUser = await _secureStorage.read(key: 'user_data');

      if (savedToken == null || savedUser == null) {
        throw Exception("Échec critique : Les données de session n'ont pas pu être sauvegardées.");
      }

      print("✅ [$methodName] Session sauvegardée avec succès");
      final user = User.fromJson(userData);
      print("✅ [$methodName] Connexion réussie pour ${user.email}");
      return user;
    } on DioException catch (e) {
      print("❌ [$methodName] DioException attrapée");
      final errorMsg = await _handleNetworkError(e, context: 'login');
      print("❌ [$methodName] $errorMsg");
      throw errorMsg;
    } on SocketException catch (e) {
      print("❌ [$methodName] Erreur socket: $e");
      throw "Impossible de se connecter au serveur. Vérifiez votre connexion internet.";
    } on FormatException catch (e) {
      print("❌ [$methodName] Erreur de format: $e");
      throw "Erreur de communication avec le serveur.";
    } catch (e) {
      print("❌ [$methodName] Erreur inattendue: $e");
      throw "Une erreur inattendue s'est produite. Veuillez réessayer.";
    }
  }

  /// Crée un compte utilisateur avec photo de profil (multipart)
  Future<User> create(Map<String, dynamic> userData, {File? profilePhoto}) async {
    const String methodName = 'AuthRepository.create';
    print("🔷 [$methodName] Début du processus d'inscription");

    if (userData.isEmpty) {
      throw "Les données utilisateur sont vides.";
    }

    final requiredFields = ['first_name', 'last_name', 'email', 'password'];
    for (final field in requiredFields) {
      if (!userData.containsKey(field) || userData[field] == null || userData[field].toString().isEmpty) {
        throw "Champ obligatoire manquant : $field";
      }
    }
    print("✅ [$methodName] Données utilisateur valides");

    FormData formData;
    try {
      if (profilePhoto != null) {
        print("📸 [$methodName] Photo fournie : ${profilePhoto.path}");
        if (!await profilePhoto.exists()) {
          throw "Le fichier photo n'existe pas.";
        }
        final multipartFile = await MultipartFile.fromFile(
          profilePhoto.path,
          filename: profilePhoto.path.split('/').last,
        );
        formData = FormData.fromMap({
          ...userData,
          'profile_photo': multipartFile,
        });
        print("✅ [$methodName] FormData avec photo créé");
      } else {
        formData = FormData.fromMap(userData);
        print("✅ [$methodName] FormData sans photo créé");
      }
    } catch (e) {
      throw "Erreur lors de la préparation du fichier : $e";
    }

    try {
      print("🔹 [$methodName] Envoi POST vers ${ApiEndpoints.register}");
      final response = await _dioClient.dio.post(
        ApiEndpoints.register,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );

      if (response.statusCode == null || (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw "Réponse HTTP inattendue : ${response.statusCode}";
      }
      print("✅ [$methodName] Requête réussie (status ${response.statusCode})");

      final accessToken = response.data['access'];
      final refreshToken = response.data['refresh'];
      final userDataResponse = response.data['user'];

      if (accessToken == null || refreshToken == null || userDataResponse == null) {
        throw "Réponse serveur invalide (tokens ou user manquants).";
      }

      await _secureStorage.write(key: 'access_token', value: accessToken);
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);
      await _secureStorage.write(key: 'user_data', value: jsonEncode(userDataResponse));
      await _prefs.setString(_keyUserData, jsonEncode(userDataResponse));
      await _prefs.setBool(_keyIsLoggedIn, true);
      print("✅ [$methodName] Inscription terminée avec succès");
      return User.fromJson(userDataResponse);
    } on DioException catch (e) {
      print("❌ [$methodName] DioException attrapée");
      final errorMsg = await _handleNetworkError(e, context: 'register');
      throw errorMsg;
    } catch (e) {
      throw "Erreur lors de l'inscription : $e";
    }
  }

  Future<void> logout() async {
    const String methodName = 'AuthRepository.logout';
    print("🔷 [$methodName] Début de la déconnexion");
    try {
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');
      await _secureStorage.delete(key: 'user_data');
      await _prefs.remove(_keyUserData);
      await _prefs.setBool(_keyIsLoggedIn, false);
      print("✅ [$methodName] Déconnexion réussie");
    } catch (e) {
      print("❌ [$methodName] Erreur: $e");
      rethrow;
    }
  }

  /// Gestionnaire d'erreurs réseau unifié (ROBUSTE)
  Future<String> _handleNetworkError(DioException error, {required String context}) async {
    print("⚠️ Gestion erreur réseau pour contexte: $context");

    // 1. Erreurs de connexion (les plus fréquentes en production)
    if (error.type == DioExceptionType.connectionTimeout) {
      return "Le serveur met trop de temps à répondre. Vérifiez votre connexion internet.";
    }
    if (error.type == DioExceptionType.receiveTimeout) {
      return "Le serveur ne répond pas. Veuillez réessayer.";
    }
    if (error.type == DioExceptionType.sendTimeout) {
      return "Envoi trop long. Vérifiez votre connexion.";
    }
    if (error.type == DioExceptionType.connectionError) {
      return "Impossible de se connecter au serveur. Vérifiez votre connexion internet.";
    }
    if (error.type == DioExceptionType.cancel) {
      return "La requête a été annulée.";
    }

    // 2. Erreurs HTTP avec réponse du serveur
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;
      print("Status code: $statusCode, Data: $data");

      // 400 - Bad Request (erreur de validation)
      if (statusCode == 400) {
        if (data is Map) {
          // Format Django REST Framework
          if (data.containsKey('detail')) {
            return data['detail'];
          }
          if (data.containsKey('non_field_errors')) {
            final errors = data['non_field_errors'];
            if (errors is List && errors.isNotEmpty) {
              return errors[0];
            }
          }
          // Collecte des erreurs par champ
          final List<String> allErrors = [];
          data.forEach((field, errors) {
            if (errors is List) {
              allErrors.add("${_getFieldLabel(field)} : ${errors.join(', ')}");
            } else if (errors is String) {
              allErrors.add("${_getFieldLabel(field)} : $errors");
            }
          });
          if (allErrors.isNotEmpty) {
            return allErrors.join('\n');
          }
        }
        return "Données invalides. Vérifiez les informations saisies.";
      }

      // 401 - Non autorisé
      if (statusCode == 401) {
        if (data is Map && data.containsKey('detail')) {
          return data['detail'];
        }
        return "Email ou mot de passe incorrect.";
      }

      // 403 - Accès interdit
      if (statusCode == 403) {
        return "Vous n'avez pas l'autorisation d'accéder à cette ressource.";
      }

      // 404 - Non trouvé
      if (statusCode == 404) {
        return "Service introuvable. Vérifiez l'URL du serveur.";
      }

      // 409 - Conflit (email déjà utilisé)
      if (statusCode == 409) {
        return "Un compte avec cet email existe déjà.";
      }

      // 413 - Fichier trop volumineux
      if (statusCode == 413) {
        return "Le fichier est trop volumineux (max 5 Mo).";
      }

      // 415 - Type de fichier non supporté
      if (statusCode == 415) {
        return "Format de fichier non supporté.";
      }

      // 429 - Trop de requêtes
      if (statusCode == 429) {
        return "Trop de tentatives. Veuillez patienter quelques secondes.";
      }

      // 500+ - Erreur serveur
      if (statusCode != null && statusCode >= 500) {
        return "Erreur interne du serveur. Veuillez réessayer plus tard.";
      }

      // Messages d'erreur génériques
      if (data is String) return data;
      if (data is Map && data.containsKey('error')) return data['error'];
      if (data is Map && data.containsKey('message')) return data['message'];
    }

    // 3. Erreurs SSL/Certificat (fréquentes sur PythonAnywhere avec HTTPS)
    if (error.type == DioExceptionType.badCertificate) {
      return "Problème de certificat de sécurité. Vérifiez que l'URL utilise bien HTTPS.";
    }

    // 4. Autres erreurs
    if (error.message != null && error.message!.contains('SocketException')) {
      return "Problème de connexion réseau. Vérifiez votre accès internet.";
    }

    return context == 'login' 
        ? "Erreur de connexion. Veuillez réessayer."
        : "Erreur lors de l'inscription. Veuillez réessayer.";
  }

  /// Traduction des noms de champs pour les messages d'erreur
  String _getFieldLabel(String field) {
    const labels = {
      'email': 'Email',
      'password': 'Mot de passe',
      'first_name': 'Prénom',
      'last_name': 'Nom',
      'username': 'Nom d\'utilisateur',
      'university_id': 'Université',
      'faculty_id': 'Faculté',
      'department_id': 'Département',
      'promotion': 'Promotion',
      'profile_photo': 'Photo de profil',
    };
    return labels[field] ?? field;
  }

  /// Récupère l'Access Token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  /// Récupère le Refresh Token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  /// Vérifie si l'utilisateur est authentifié
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Récupère l'utilisateur en cache
  Future<User?> getCachedUser() async {
    final userStr = await _secureStorage.read(key: 'user_data');
    if (userStr != null) {
      try {
        return User.fromJson(jsonDecode(userStr));
      } catch (e) {
        print("❌ Erreur parsing user_data: $e");
        return null;
      }
    }
    return null;
  }

  /// Récupère l'utilisateur courant depuis l'API
  Future<User> getCurrentUser() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.currentUser);
      final userData = response.data;
      await _secureStorage.write(key: 'user_data', value: jsonEncode(userData));
      return User.fromJson(userData);
    } on DioException catch (e) {
      throw await _handleNetworkError(e, context: 'currentUser');
    } catch (e) {
      throw "Erreur lors de la récupération de l'utilisateur.";
    }
  }

  /// Vérifie rapidement si l'utilisateur est connecté
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }
}