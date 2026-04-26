import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/env.dart';
import '../constants/api_endpoints.dart';

class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  // Liste des endpoints publics (ne nécessitant pas de token)
  final List<String> _publicEndpoints = [
    ApiEndpoints.login,
    ApiEndpoints.register,
    ApiEndpoints.refreshToken,
  ];

  DioClient(this._dio, this._storage) {
    _dio
      ..options.baseUrl = Env.apiBaseUrl
      ..options.connectTimeout = const Duration(milliseconds: Env.connectionTimeout)
      ..options.receiveTimeout = const Duration(milliseconds: Env.connectionTimeout)
      ..options.headers = {'Content-Type': 'application/json'};

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          const String step = 'DioClient.onRequest';
          print("🔷 [$step] Interception de la requête : ${options.method} ${options.path}");

          // Vérifier si l'endpoint est public
          final isPublic = _publicEndpoints.any((path) => options.path.contains(path));
          print("🔹 [$step] Endpoint public ? $isPublic");

          if (!isPublic) {
            print("🔹 [$step] Récupération du token depuis le stockage sécurisé...");
            final token = await _storage.read(key: 'access_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              print("✅ [$step] Token ajouté aux en-têtes");
            } else {
              print("⚠️ [$step] Aucun token trouvé (requête non authentifiée)");
            }
          } else {
            print("ℹ️ [$step] Endpoint public – aucun token ajouté");
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          const String step = 'DioClient.onError';
          print("❌ [$step] Erreur interceptée : ${e.type} - ${e.message}");
          print("   └─ URL : ${e.requestOptions.path}");
          print("   └─ Status code : ${e.response?.statusCode}");

          // Ne pas tenter de refresh pour les endpoints publics
          final isPublic = _publicEndpoints.any((path) => e.requestOptions.path.contains(path));
          if (isPublic) {
            print("ℹ️ [$step] Endpoint public – pas de tentative de refresh");
            return handler.next(e);
          }

          // Gestion du refresh token (uniquement pour les erreurs 401)
          if (e.response?.statusCode == 401) {
            print("🔹 [$step] Code 401 – tentative de rafraîchissement du token...");
            final refreshToken = await _storage.read(key: 'refresh_token');
            if (refreshToken == null || refreshToken.isEmpty) {
              print("❌ [$step] Aucun refresh token disponible – déconnexion forcée");
              await _storage.deleteAll();
              return handler.next(e);
            }

            try {
              print("🔹 [$step] Appel au endpoint de refresh : ${ApiEndpoints.refreshToken}");
              final refreshRes = await Dio().post(
                '${Env.apiBaseUrl}${ApiEndpoints.refreshToken}',
                data: {'refresh': refreshToken},
                options: Options(
                  headers: {'Content-Type': 'application/json'},
                  sendTimeout: const Duration(seconds: 10),
                  receiveTimeout: const Duration(seconds: 10),
                ),
              );

              final newToken = refreshRes.data['access'];
              if (newToken == null || newToken.isEmpty) {
                throw Exception("Le nouveau token est vide ou null");
              }

              await _storage.write(key: 'access_token', value: newToken);
              print("✅ [$step] Nouveau token obtenu et sauvegardé");

              // Relancer la requête initiale avec le nouveau token
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              print("🔹 [$step] Relance de la requête originale...");
              final response = await _dio.fetch(e.requestOptions);
              print("✅ [$step] Requête relancée avec succès (status ${response.statusCode})");
              return handler.resolve(response);
            } catch (refreshErr) {
              print("❌ [$step] Échec du rafraîchissement du token : $refreshErr");
              // Nettoyage complet des données de session
              await _storage.deleteAll();
              print("🗑️ [$step] Toutes les données de session ont été supprimées");
              return handler.next(e);
            }
          }

          // Pour les autres erreurs (400, 500, etc.), on les propage simplement
          print("ℹ️ [$step] Erreur non 401 – propagation sans traitement");
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}