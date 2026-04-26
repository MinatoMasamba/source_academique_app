import 'package:hive_flutter/hive_flutter.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';

/// Classe Helper pour structurer le retour du cache de la page d'accueil
class HomeCacheData {
  final List<AcademicDocument> discoveries;
  final List<Article> articles;
  final List<PostNews> communityPosts;
  final List<AcademicDocument> recommended;

  HomeCacheData({
    required this.discoveries,
    required this.articles,
    required List<PostNews> posts,
    required this.recommended,
  }) : communityPosts = posts;
}

class LocalDbManager {
  static const String offlineDocsBox = 'offline_documents_box';
  static const String userProfileBox = 'user_profile_box';
  static const String notificationsBox = 'notifications_history_box';
  static const String settingsBox = 'app_settings_box';
  static const String studentSpaceBox = 'student_space_box';

  /// Initialise toutes les boîtes nécessaires au démarrage
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(offlineDocsBox);
    await Hive.openBox(userProfileBox);
    await Hive.openBox(notificationsBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox(studentSpaceBox);
  }

  // ==============================
  // SECTION ESPACE ÉTUDIANT
  // ==============================

  /// Récupère les posts de l'étudiant depuis le cache
  List<PostNews> getStudentPosts() {
    final box = Hive.box(studentSpaceBox);
    final List<dynamic>? rawPosts = box.get('student_posts');
    if (rawPosts == null) return [];
    return rawPosts.map((e) => PostNews.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  /// Sauvegarde les posts de l'étudiant
  Future<void> saveStudentPosts(List<PostNews> posts) async {
    final box = Hive.box(studentSpaceBox);
    await box.put('student_posts', posts.map((e) => e.toJson()).toList());
  }

  /// Récupère les documents personnels (AcademicDocument)
  List<AcademicDocument> getSavedFiles() {
    final box = Hive.box(studentSpaceBox);
    final List<dynamic>? rawFiles = box.get('student_files');
    if (rawFiles == null) return [];
    return rawFiles.map((e) => AcademicDocument.fromJson(Map<String, dynamic>.from(e), 'document')).toList();
  }

  /// Sauvegarde les documents personnels
  Future<void> saveStudentFiles(List<AcademicDocument> files) async {
    final box = Hive.box(studentSpaceBox);
    await box.put('student_files', files.map((e) => e.toJson()).toList());
  }

  /// Récupère les résultats académiques en cache
  List<dynamic> getAcademicResults() {
    final box = Hive.box(studentSpaceBox);
    return box.get('academic_results', defaultValue: []);
  }

  /// Sauvegarde les résultats académiques
  Future<void> saveAcademicResults(List<dynamic> results) async {
    final box = Hive.box(studentSpaceBox);
    await box.put('academic_results', results);
  }

  // ==============================
  // SECTION DOCUMENTS HORS-LIGNE (EXISTANT)
  // ==============================

  Future<void> saveDocumentOffline(String id, Map<String, dynamic> docData) async {
    var box = Hive.box(offlineDocsBox);
    docData['cached_at'] = DateTime.now().toIso8601String();
    await box.put(id, docData);
  }

  Map<String, dynamic>? getDocumentById(String id) {
    var box = Hive.box(offlineDocsBox);
    final data = box.get(id);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  bool isDocumentCached(String id) {
    return Hive.box(offlineDocsBox).containsKey(id);
  }

  Future<void> deleteDocumentFromCache(String id) async {
    await Hive.box(offlineDocsBox).delete(id);
  }

  List<dynamic> getAllOfflineDocuments() {
    return Hive.box(offlineDocsBox).values.toList();
  }

  // ==============================
  // SECTION PROFIL & PRÉFÉRENCES
  // ==============================

  Future<void> saveUserProfile(Map<String, dynamic> userData) async {
    await Hive.box(userProfileBox).put('current_user', userData);
  }

  Map<String, dynamic>? getUserProfile() {
    final data = Hive.box(userProfileBox).get('current_user');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  // ==============================
  // SYSTÈME DE CACHE POUR LA HOME
  // ==============================

  HomeCacheData? getHomeCache() {
    var box = Hive.box(offlineDocsBox);
    final List<dynamic>? discoveriesRaw = box.get('home_discoveries');
    final List<dynamic>? articlesRaw = box.get('home_articles');
    final List<dynamic>? postsRaw = box.get('home_posts');
    final List<dynamic>? recommendedRaw = box.get('home_recommended');

    if (discoveriesRaw == null && articlesRaw == null) return null;

    return HomeCacheData(
      discoveries: (discoveriesRaw ?? []).map((e) => AcademicDocument.fromJson(Map<String, dynamic>.from(e), 'document')).toList(),
      articles: (articlesRaw ?? []).map((e) => Article.fromJson(Map<String, dynamic>.from(e))).toList(),
      posts: (postsRaw ?? []).map((e) => PostNews.fromJson(Map<String, dynamic>.from(e))).toList(),
      recommended: (recommendedRaw ?? []).map((e) => AcademicDocument.fromJson(Map<String, dynamic>.from(e), 'document')).toList(),
    );
  }

  Future<void> saveHomeCache({
    required List<AcademicDocument> discoveries,
    required List<Article> articles,
    //required List<PostNews> posts,
    required List<AcademicDocument> recommended,
  }) async {
    var box = Hive.box(offlineDocsBox);
    await box.put('home_discoveries', discoveries.map((e) => e.toJson()).toList());
    await box.put('home_articles', articles.map((e) => e.toJson()).toList());
    //await box.put('home_posts', posts.map((e) => e.toJson()).toList());
    await box.put('home_recommended', recommended.map((e) => e.toJson()).toList());
  }

  // ==============================
  // UTILS & TIMESTAMPS
  // ==============================

  static const String _homeLastUpdateKey = 'home_last_update';

  Future<DateTime?> getHomeLastUpdate() async {
    final box = Hive.box(settingsBox);
    final timestamp = box.get(_homeLastUpdateKey);
    if (timestamp is String) return DateTime.tryParse(timestamp);
    return null;
  }

  Future<void> setHomeLastUpdate(DateTime date) async {
    final box = Hive.box(settingsBox);
    await box.put(_homeLastUpdateKey, date.toIso8601String());
  }

  Future<void> clearAllData() async {
    await Hive.box(offlineDocsBox).clear();
    await Hive.box(userProfileBox).clear();
    await Hive.box(notificationsBox).clear();
    await Hive.box(settingsBox).clear();
    await Hive.box(studentSpaceBox).clear();
  }


List<PostNews> getCommunityPosts() {
  final box = Hive.box(studentSpaceBox);
  final List<dynamic>? rawPosts = box.get('community_posts');
  if (rawPosts == null) return [];
  return rawPosts.map((e) => PostNews.fromJson(Map<String, dynamic>.from(e))).toList();
}

/// Sauvegarde les posts de la communauté
Future<void> saveCommunityPosts(List<PostNews> posts) async {
  final box = Hive.box(studentSpaceBox);
  await box.put('community_posts', posts.map((e) => e.toJson()).toList());
}


  Future<void> closeAll() async {
    await Hive.close();
  }
}