import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// ============================================================================
// CLASSE: AuthBloc (Bloc<AuthEvent, AuthState>)
// ============================================================================
// DESCRIPTION: Bloc d'authentification gérant les événements de connexion,
//              d'inscription, de déconnexion et de restauration de session.
// ============================================================================

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  // ==========================================================================
  // CONSTRUCTEUR: AuthBloc
  // ==========================================================================
  // DESCRIPTION: Initialise le Bloc avec l'état initial AuthInitial()
  //              et enregistre les handlers pour chaque événement.
  // SUIVI: ✅ Appelé lors de l'instanciation du Bloc.
  // ==========================================================================
  
  AuthBloc(this._authRepository) : super(AuthInitial()) {
    print("🔷 [AuthBloc.constructor] Initialisation du AuthBloc");
    
    // Enregistrement des handlers d'événements
    print("🔹 [AuthBloc.constructor] Enregistrement des handlers d'événements");
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AppStarted>(_onAppStarted);
    
    print("✅ [AuthBloc.constructor] AuthBloc initialisé avec succès");
  }

  // ==========================================================================
  // SECTION 1: GESTION DE LA CONNEXION
  // ==========================================================================
  // MÉTHODE: _onLoginRequested(LoginRequested event, Emitter<AuthState> emit)
  // DESCRIPTION: Traite la demande de connexion d'un utilisateur.
  //              Appelle le repository pour l'authentification.
  // SUIVI: ✅ Appelée via l'événement LoginRequested.
  // ÉTATS: AuthLoading -> AuthAuthenticated (succès) ou AuthError (échec)
  // ==========================================================================
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print("🔷 [AuthBloc._onLoginRequested] Début du traitement de la connexion");
    print("📧 Email: ${event.email}");
    
    // Étape 1: Émission de l'état de chargement
    print("🔹 [AuthBloc._onLoginRequested] Étape 1: Émission de AuthLoading");
    emit(AuthLoading());
    
    try {
      // Étape 2: Appel au repository pour la connexion
      print("🔹 [AuthBloc._onLoginRequested] Étape 2: Appel à _authRepository.login()");
      final user = await _authRepository.login(event.email, event.password);
      print("✅ Utilisateur authentifié: ${user.email} (ID: ${user.id})");
      
      // Étape 3: Émission de l'état authentifié
      print("🔹 [AuthBloc._onLoginRequested] Étape 3: Émission de AuthAuthenticated");
      emit(AuthAuthenticated(user));
      
      print("✅ [AuthBloc._onLoginRequested] Connexion terminée avec succès");
      
    } catch (e) {
      // Gestion des erreurs
      print("❌ [AuthBloc._onLoginRequested] ERREUR: ${e.toString()}");
      print("🔹 [AuthBloc._onLoginRequested] Émission de AuthError");
      emit(AuthError(e.toString()));
    }
    
    print("🔷 [AuthBloc._onLoginRequested] Fin de l'exécution");
  }

  // ==========================================================================
  // SECTION 2: GESTION DE L'INSCRIPTION
  // ==========================================================================
  // MÉTHODE: _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit)
  // DESCRIPTION: Traite la demande d'inscription d'un nouvel utilisateur.
  //              Appelle le repository pour créer le compte et sauvegarder
  //              la photo de profil si fournie.
  // SUIVI: ✅ Appelée via l'événement RegisterRequested.
  // ÉTATS: AuthLoading -> AuthAuthenticated (succès) ou AuthError (échec)
  // ==========================================================================
  
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    print("🔷 [AuthBloc._onRegisterRequested] Début du traitement de l'inscription");
    
    // Étape 1: Affichage des données reçues
    print("🔹 [AuthBloc._onRegisterRequested] Étape 1: Analyse des données reçues");
    print("📊 Données utilisateur:");
    print("   - Prénom: ${event.userData["first_name"]}");
    print("   - Nom: ${event.userData["last_name"]}");
    print("   - Email: ${event.userData["email"]}");
    print("   - Université ID: ${event.userData["university_id"]}");
    print("   - Faculté ID: ${event.userData["faculty_id"]}");
    print("   - Département ID: ${event.userData["department_id"]}");
    print("   - Promotion: ${event.userData["promotion"]}");
    print("📸 Photo de profil fournie: ${event.profilePhoto != null}");
    if (event.profilePhoto != null) {
      print("   - Chemin: ${event.profilePhoto!.path}");
      print("   - Taille: ${await event.profilePhoto!.length()} bytes");
    }
    
    // Étape 2: Émission de l'état de chargement
    print("🔹 [AuthBloc._onRegisterRequested] Étape 2: Émission de AuthLoading");
    emit(AuthLoading());
    
    try {
      // Étape 3: Appel au repository pour la création du compte
      print("🔹 [AuthBloc._onRegisterRequested] Étape 3: Appel à _authRepository.create()");
      print("   - Avec photo: ${event.profilePhoto != null}");
      
      final user = await _authRepository.create(
        event.userData,
        profilePhoto: event.profilePhoto,
      );
      
      print("✅ Utilisateur créé avec succès: ${user.email} (ID: ${user.id})");
      print("   - Nom complet: ${user.firstName} ${user.lastName}");
      
      // Étape 4: Émission de l'état authentifié
      print("🔹 [AuthBloc._onRegisterRequested] Étape 4: Émission de AuthAuthenticated");
      emit(AuthAuthenticated(user));
      
      print("✅ [AuthBloc._onRegisterRequested] Inscription terminée avec succès");
      
    } catch (e) {
      // Gestion des erreurs détaillée
      print("❌ [AuthBloc._onRegisterRequested] ERREUR: ${e.toString()}");
      print("🔍 Type d'erreur: ${e.runtimeType}");
      
      // Affichage du stack trace si disponible
      if (e is StackTrace) {
        print("📚 Stack trace: $e");
      }
      
      print("🔹 [AuthBloc._onRegisterRequested] Émission de AuthError");
      emit(AuthError(e.toString()));
    }
    
    print("🔷 [AuthBloc._onRegisterRequested] Fin de l'exécution");
  }

  // ==========================================================================
  // SECTION 3: GESTION DE LA DÉCONNEXION
  // ==========================================================================
  // MÉTHODE: _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit)
  // DESCRIPTION: Traite la demande de déconnexion.
  //              Appelle le repository pour effacer les tokens et les données.
  // SUIVI: ✅ Appelée via l'événement LogoutRequested.
  // ÉTATS: Émission de AuthUnauthenticated après déconnexion.
  // ==========================================================================
  
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    print("🔷 [AuthBloc._onLogoutRequested] Début du traitement de la déconnexion");
    
    // Étape 1: Appel au repository pour la déconnexion
    print("🔹 [AuthBloc._onLogoutRequested] Étape 1: Appel à _authRepository.logout()");
    
    try {
      await _authRepository.logout();
      print("✅ Déconnexion effectuée avec succès");
      
      // Étape 2: Émission de l'état non authentifié
      print("🔹 [AuthBloc._onLogoutRequested] Étape 2: Émission de AuthUnauthenticated");
      emit(AuthUnauthenticated());
      
      print("✅ [AuthBloc._onLogoutRequested] Déconnexion terminée");
      
    } catch (e) {
      // Gestion des erreurs (même en cas d'erreur, on force la déconnexion)
      print("❌ [AuthBloc._onLogoutRequested] ERREUR lors de la déconnexion: ${e.toString()}");
      print("⚠️ [AuthBloc._onLogoutRequested] Forçage de l'état non authentifié");
      emit(AuthUnauthenticated());
    }
    
    print("🔷 [AuthBloc._onLogoutRequested] Fin de l'exécution");
  }

  // ==========================================================================
  // SECTION 4: GESTION DU DÉMARRAGE DE L'APPLICATION
  // ==========================================================================
  // MÉTHODE: _onAppStarted(AppStarted event, Emitter<AuthState> emit)
  // DESCRIPTION: Vérifie si une session existe au démarrage de l'application.
  //              Tente de restaurer l'utilisateur depuis le cache ou l'API.
  // SUIVI: ✅ Appelée via l'événement AppStarted (généralement dans main.dart).
  // ÉTATS: AuthAuthenticated (session valide) ou AuthUnauthenticated (pas de session)
  // ==========================================================================
  
  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    print("🔷 [AuthBloc._onAppStarted] Début de la restauration de session");
    print("🕐 Timestamp: ${DateTime.now()}");
    
    // ------------------------------------------------------------------------
    // Étape 1: Vérification de l'existence des tokens
    // ------------------------------------------------------------------------
    print("🔹 [AuthBloc._onAppStarted] Étape 1: Vérification des tokens");
    
    String? token;
    bool isLoggedIn = false;
    
    try {
      token = await _authRepository.getAccessToken();
      isLoggedIn = _authRepository.isLoggedIn();
      print("   - Token présent: ${token != null}");
      print("   - isLoggedIn: $isLoggedIn");
    } catch (e) {
      print("❌ [AuthBloc._onAppStarted] ERREUR lors de la vérification des tokens: ${e.toString()}");
    }
    
    // Vérification des conditions d'authentification
    if (!isLoggedIn) {
      print("🔐 [AuthBloc._onAppStarted] Utilisateur non connecté -> état non authentifié");
      emit(AuthUnauthenticated());
      print("🔷 [AuthBloc._onAppStarted] Fin (aucune session)");
      return;
    }
    
    if (token == null) {
      print("⚠️ [AuthBloc._onAppStarted] Token absent malgré isLoggedIn=true -> état non authentifié");
      emit(AuthUnauthenticated());
      print("🔷 [AuthBloc._onAppStarted] Fin (token manquant)");
      return;
    }
    
    print("✅ [AuthBloc._onAppStarted] Tokens valides détectés");
    
    // ------------------------------------------------------------------------
    // Étape 2: Tentative de restauration depuis le cache local
    // ------------------------------------------------------------------------
    print("🔹 [AuthBloc._onAppStarted] Étape 2: Recherche d'un utilisateur en cache");
    
    try {
      final cachedUser = await _authRepository.getCachedUser();
      
      if (cachedUser != null) {
        print("✅ [AuthBloc._onAppStarted] Utilisateur trouvé en cache:");
        print("   - ID: ${cachedUser.id}");
        print("   - Email: ${cachedUser.email}");
        print("   - Nom: ${cachedUser.firstName} ${cachedUser.lastName}");
        
        // Émission de l'état authentifié avec les données du cache
        print("🔹 [AuthBloc._onAppStarted] Étape 3: Émission de AuthAuthenticated (cache)");
        emit(AuthAuthenticated(cachedUser));
        
        // Rafraîchissement silencieux en arrière-plan
        print("🔹 [AuthBloc._onAppStarted] Lancement du rafraîchissement silencieux");
        _refreshUserInBackground();
        
        print("✅ [AuthBloc._onAppStarted] Session restaurée depuis le cache");
        
      } else {
        // ----------------------------------------------------------------------
        // Étape 3: Pas de cache -> appel API pour récupérer l'utilisateur courant
        // ----------------------------------------------------------------------
        print("🔹 [AuthBloc._onAppStarted] Étape 3: Pas de cache - appel API getCurrentUser()");
        
        try {
          final user = await _authRepository.getCurrentUser();
          print("✅ Utilisateur récupéré depuis l'API:");
          print("   - ID: ${user.id}");
          print("   - Email: ${user.email}");
          print("   - Nom: ${user.firstName} ${user.lastName}");
          
          print("🔹 [AuthBloc._onAppStarted] Émission de AuthAuthenticated (API)");
          emit(AuthAuthenticated(user));
          
          print("✅ [AuthBloc._onAppStarted] Session restaurée depuis l'API");
          
        } catch (apiError) {
          print("❌ [AuthBloc._onAppStarted] ERREUR API: ${apiError.toString()}");
          print("⚠️ [AuthBloc._onAppStarted] Nettoyage de la session invalide");
          
          try {
            await _authRepository.logout();
            print("✅ Session invalide nettoyée");
          } catch (logoutError) {
            print("❌ Erreur lors du nettoyage: ${logoutError.toString()}");
          }
          
          print("🔹 [AuthBloc._onAppStarted] Émission de AuthUnauthenticated");
          emit(AuthUnauthenticated());
        }
      }
      
    } catch (e) {
      // Gestion globale des erreurs
      print("❌ [AuthBloc._onAppStarted] ERREUR CRITIQUE: ${e.toString()}");
      print("🔍 Type d'erreur: ${e.runtimeType}");
      
      // Nettoyage de la session en cas d'erreur
      print("🔹 [AuthBloc._onAppStarted] Nettoyage de la session après erreur");
      try {
        await _authRepository.logout();
        print("✅ Session nettoyée");
      } catch (logoutError) {
        print("❌ Erreur lors du nettoyage: ${logoutError.toString()}");
      }
      
      print("🔹 [AuthBloc._onAppStarted] Émission de AuthUnauthenticated");
      emit(AuthUnauthenticated());
    }
    
    print("🔷 [AuthBloc._onAppStarted] Fin de l'exécution");
  }

  // ==========================================================================
  // SECTION 5: RAFRAÎCHISSEMENT SILENCIEUX EN ARRIÈRE-PLAN
  // ==========================================================================
  // MÉTHODE: _refreshUserInBackground()
  // DESCRIPTION: Rafraîchit les données utilisateur en arrière-plan sans
  //              affecter l'état actuel du Bloc.
  // SUIVI: ✅ Appelée automatiquement après restauration depuis le cache.
  // NOTE: Les erreurs sont capturées mais n'affectent pas l'interface utilisateur.
  // ==========================================================================
  
  Future<void> _refreshUserInBackground() async {
    print("🔷 [AuthBloc._refreshUserInBackground] Début du rafraîchissement silencieux");
    
    try {
      print("🔹 [AuthBloc._refreshUserInBackground] Appel à _authRepository.getCurrentUser()");
      final refreshedUser = await _authRepository.getCurrentUser();
      
      if (refreshedUser != null) {
        print("✅ Utilisateur rafraîchi avec succès:");
        print("   - ID: ${refreshedUser.id}");
        print("   - Email: ${refreshedUser.email}");
        print("   - Nom: ${refreshedUser.firstName} ${refreshedUser.lastName}");
        
        // Note: On n'émet pas d'état ici pour ne pas perturber l'UI
        // Les données seront utilisées lors du prochain accès au cache
        print("ℹ️ Données mises à jour dans le cache (sans émission d'état)");
        
      } else {
        print("⚠️ [AuthBloc._refreshUserInBackground] Aucune donnée reçue");
      }
      
      print("✅ [AuthBloc._refreshUserInBackground] Rafraîchissement terminé");
      
    } catch (e) {
      // Les erreurs sont silencieuses - n'affectent pas l'expérience utilisateur
      print("⚠️ [AuthBloc._refreshUserInBackground] Échec du rafraîchissement: ${e.toString()}");
      print("   (L'utilisateur reste connecté avec les données du cache)");
    }
    
    print("🔷 [AuthBloc._refreshUserInBackground] Fin de l'exécution");
  }
}