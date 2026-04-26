import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:source_academique/core/config/service_locator.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';
import 'package:source_academique/presentation/features/IA/assistant_ia.dart';
import 'package:source_academique/presentation/features/article/screens/all_articles_screen.dart';
import 'package:source_academique/presentation/features/article/screens/article_detail_screen.dart';
import 'package:source_academique/presentation/features/discovery/screens/all_discoveries_screen.dart';
import 'package:source_academique/presentation/features/document/screens/document_detail_screen.dart';
import 'package:source_academique/presentation/features/home/screens/home_screen.dart';
import 'package:source_academique/presentation/features/notification/notification/notifications_screen.dart';
import 'package:source_academique/presentation/features/profile/bloc/profile_bloc.dart';
import 'package:source_academique/presentation/features/projet/screens/project_detail_screen.dart';
import 'package:source_academique/presentation/features/space_stadent/create_post_screen.dart';
import 'package:source_academique/presentation/features/space_stadent/espace.dart';
import 'package:source_academique/presentation/features/space_stadent/presentation/bloc/student_space_bloc.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/posts/post_detail_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../presentation/features/auth/screens/login_screen.dart';
import '../../presentation/features/home/screens/home_wrapper.dart';
import '../../presentation/features/library/screens/library_screen.dart';
import '../../presentation/features/profile/screens/profile_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(AuthBloc authBloc) => GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    routes: [
      // --- Écran de Login (Hors du Wrapper) ---
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/ai-assistant',
        name: 'ai_assistant',
        builder: (context, state) => const AIAssistantScreen(),
      ),
      GoRoute(
        path: '/articles',
        name: 'all_articles',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AllArticlesScreen(),
      ),
      GoRoute(
        path: '/discoveries',
        name: 'all_discoveries',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AllDiscoveriesScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/discovery/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final discovery = state.extra as Decouverte?;
          if (discovery != null) {
            return DiscoveryDetailScreen(discovery: discovery);
          }
          return const Scaffold(body: Center(child: Text("Découverte non trouvée")));
        },
      ),
      GoRoute(
        path: '/project/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final project = state.extra as Projet?;
          if (project != null) {
            return ProjectDetailScreen(project: project); // à créer
          }
          return const Scaffold(body: Center(child: Text("Projet non trouvé")));
        },
      ),

      GoRoute(
        path: '/document/:id',
        builder: (context, state) {
          final doc = state.extra as AcademicDocument;
          // Vérification des champs
          print('Navigation vers document: ${doc.title}, URL: ${doc.fichierUrl}');
          return DocumentDetailScreen(document: doc);
        },
            ),
      GoRoute(
        path: '/post/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final post = state.extra as PostNews?;
          if (post != null) {
            // Fournir le StudentSpaceBloc à l'écran de détail
            return BlocProvider(
              create: (context) => sl<StudentSpaceBloc>(),
              child: PostDetailScreen(post: post),
            );
          } else {
            return const Scaffold(body: Center(child: Text("Post non trouvé")));
          }
        },
      ),

      // --- ShellRoute : Toutes ces pages auront la barre Glassmorphism ---
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return HomeWrapper(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'Home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/Library',
            name: 'Library',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/space-student',
            name: 'space-student',
            builder: (context, state) => const StudentSpaceScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => BlocProvider.value(
              value: context.read<ProfileBloc>(),
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),
      
      // --- Route de détails (Plein écran, sans la barre de navigation) ---
      GoRoute(
        path: '/article/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final article = state.extra as Article?;
          if (article != null) {
            return ArticleDetailScreen(article: article);
          } else {
            // Fallback : afficher un message d'erreur
            return const Scaffold(
              body: Center(child: Text("Article non trouvé")),
            );
          }
        },
      ),
      GoRoute(
        path: '/post/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final docId = state.pathParameters['id']!;
          return Center(child: Text("Détails du post $docId"));
        },
      ),
      GoRoute(
        path: '/decouverte/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final docId = state.pathParameters['id']!;
          return Center(child: Text("Détails de la découverte $docId"));
        },
      ),
      GoRoute(
        path: '/user_profil/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final docId = state.pathParameters['id']!;
          return Center(child: Text("Profil utilisateur $docId"));
        },
      ),
      GoRoute(
        path: '/create-post',
        name: 'create-post',
        pageBuilder: (context, state) {
          final post = state.extra as PostNews?;
          return MaterialPage(
            child: CreatePostScreen(post: post),
          );
        },
      ),
    ],
    
    // ⭐ Logique de redirection avec vérification SharedPreferences
    redirect: (context, state) async {
      final authState = authBloc.state;
      final bool isLoggingIn = state.matchedLocation == '/login';
      final bool isAuthenticated = authState is AuthAuthenticated;
      
      // Récupération du repository pour vérifier SharedPreferences
      final authRepo = sl<AuthRepository>();
      final hasSavedSession = authRepo.isLoggedIn();
      
      print("🔍 [Router] authState: ${authState.runtimeType}, hasSavedSession: $hasSavedSession, isLoggingIn: $isLoggingIn");
      
      // Cas 1 : Session sauvegardée mais bloc non authentifié → restaurer
      if (!isAuthenticated && hasSavedSession && !isLoggingIn) {
        print("🔄 [Router] Session détectée, déclenchement AppStarted()");
        authBloc.add(AppStarted());
        return null; // Attendre la restauration
      }
      
      // Cas 2 : Non authentifié et pas sur login → rediriger vers login
      if (!isAuthenticated && !isLoggingIn) {
        print("🚪 [Router] Non authentifié → redirection vers login");
        return '/login';
      }
      
      // Cas 3 : Authentifié et sur login → rediriger vers home
      if (isAuthenticated && isLoggingIn) {
        print("🏠 [Router] Authentifié sur login → redirection vers home");
        return '/';
      }
      
      // Cas 4 : Authentifié ailleurs → rester
      return null;
    },
  );
}

/// Transforme le Stream du Bloc en Listenable pour GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}