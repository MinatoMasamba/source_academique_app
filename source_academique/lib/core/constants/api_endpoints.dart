// lib/core/constants/api_endpoints.dart

class ApiEndpoints {
  
  static const String baseUrl = 'https://minatomasamba.pythonanywhere.com/api';

  // ==================== AUTHENTIFICATION ====================
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String refreshToken = '/auth/token/refresh/';
  static const String currentUser = '/auth/me/';  // adaptez selon votre backend

  // ==================== PROFIL ====================
  static String userProfile(int userId) => '/profile/me/';

  // ==================== SÉLECTEURS DYNAMIQUES ====================
  static const String universities = '/universities/';
  static String faculties(int uniId) => '/universities/$uniId/faculties/';
  static String departments(int facId) => '/faculties/$facId/departments/';

  // ==================== DOCUMENTS ACADÉMIQUES ====================

 // documents recommandés pour l'utilisateur connecté
  // Cours
  static const String cours = '/cours/';
  static String coursDetail(int id) => '/cours/$id/';

  // Travaux Pratiques (TP)
  static const String tp = '/tp/';
  static String tpDetail(int id) => '/tp/$id/';

  // Examens
  static const String examens = '/examens/';
  static String examenDetail(int id) => '/examens/$id/';

  // Interrogations
  static const String interros = '/interros/';
  static String interroDetail(int id) => '/interros/$id/';

  // Notes de cours
  static const String notes = '/notes/';
  static String noteDetail(int id) => '/notes/$id/';

  // ==================== DOCUMENTS ACADÉMIQUES FILTRÉS PAR PROFIL ====================
  // Ces endpoints retournent les documents filtrés automatiquement selon :
  // - la promotion de l'utilisateur connecté
  // - son université
  // - sa faculté
  // - son département
  
  // Cours
  static const String userCours = '/user/cours/';
  static String userCoursDetail(int id) => '/user/cours/$id/';
  
  // Travaux Pratiques (TP)
  static const String userTp = '/user/tp/';
  static String userTpDetail(int id) => '/user/tp/$id/';
  
  // Examens
  static const String userExamens = '/user/examens/';
  static String userExamenDetail(int id) => '/user/examens/$id/';
  
  // Interrogations
  static const String userInterros = '/user/interros/';
  static String userInterroDetail(int id) => '/user/interros/$id/';
  
  // Notes de cours
  static const String userNotes = '/user/notes/';
  static String userNoteDetail(int id) => '/user/notes/$id/';


  // ==================== DÉCOUVERTES, PROJETS, ARTICLES ====================
  // Découvertes
  static const String decouvertes = '/decouvertes/';
  static String decouverteDetail(int id) => '/decouvertes/$id/';

  // Projets
  static const String projets = '/projets/';
  static String projetDetail(int id) => '/projets/$id/';

  // Articles
  static const String articles = '/articles/';
  static String articleDetail(int id) => '/articles/$id/';

  // ==================== POSTS DE LA COMMUNAUTÉ ====================
  // Posts (CRUD)
  static const String posts = '/posts/';
  static String postDetail(String shareableId) => '/posts/$shareableId/';
  static String userPosts(int userId) => '/posts/user/$userId/';

  // Interactions
  static String postLike(String shareableId) => '/posts/$shareableId/like/'; // aimer ou retirer le like
  static String postComment(String shareableId) => '/posts/$shareableId/comment/'; // creer un commentaire
  static String postComments(String shareableId) => '/posts/$shareableId/comments/';// récupérer les commentaires
  static String postView(String shareableId) => '/posts/$shareableId/view/'; // enregistrer une vue
  static String postShare(String shareableId) => '/posts/$shareableId/share/'; // enregistrer un partage

  // ==================== ESPACE ÉTUDIANT ====================
  static String userDocuments(int userId) => '/student/documents/'; // GET les documents de l'utilisateur
  static const String uploadDocument = '/student/documents/upload/'; // POST pour uploader un document
  static String deleteDocument(int documentId) => '/student/documents/$documentId/';

  // Résultats académiques
  static const String academicResults = '/student/results/';

  // Notifications
  static const String notifications = '/notifications/feed/';
}