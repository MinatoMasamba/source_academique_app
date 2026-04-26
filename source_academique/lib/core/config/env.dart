// lib/core/config/env.dart
// Ce fichier contient les configurations globales de l'application, notamment les URLs d'API et les clés d'API.


class Env {
  // En production, ces valeurs seraient chargées via --dart-define
  static const String apiBaseUrl = "https://minatomasamba.pythonanywhere.com/api";
  static const String wsUrl = "wss://192.168.56.1:8080//ws/notifications/";
  
  // Clé pour l'Assistant IA (Gemini)
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  
  // Délais de connexion
  static const int connectionTimeout = 15000; // 15 seconds
}