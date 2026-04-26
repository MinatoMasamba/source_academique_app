// lib/features/home/presentation/bloc/home_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:source_academique/core/storage/local_db_manager.dart';
import 'package:source_academique/features/auth/data/repositories/home_repository.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;
  final LocalDbManager _localDb;

  HomeBloc({
    required HomeRepository homeRepository,
    required LocalDbManager localDb,
  })  : _homeRepository = homeRepository,
        _localDb = localDb,
        super(HomeInitial()) {
    on<FetchHomeData>(_onFetchHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
  }

  Future<void> _onFetchHomeData(FetchHomeData event, Emitter<HomeState> emit) async {
    print("🏠 [HomeBloc._onFetchHomeData] Début chargement données accueil");
    emit(HomeLoading());
    print("🏠 [HomeBloc._onFetchHomeData] État HomeLoading émis");

    try {
      print("🌐 [HomeBloc._onFetchHomeData] Tentative de synchronisation avec le serveur...");
      await _syncWithServer(emit);
      print("✅ [HomeBloc._onFetchHomeData] Synchronisation réussie");
    } catch (e, stackTrace) {
      print("❌ [HomeBloc._onFetchHomeData] Erreur serveur: $e");
      print("📚 [HomeBloc._onFetchHomeData] StackTrace: $stackTrace");
      
      // 2. Si le serveur échoue, on cherche dans le CACHE
      print("💾 [HomeBloc._onFetchHomeData] Tentative de lecture du cache...");
      try {
        final cachedData = await _localDb.getHomeCache();
        
        if (cachedData != null) {
          print("📦 [HomeBloc._onFetchHomeData] Cache trouvé: ${cachedData.discoveries.length} découvertes, ${cachedData.articles.length} articles, ${cachedData.recommended.length} recommandations");
          emit(HomeLoaded(
            discoveries: cachedData.discoveries,
            articles: cachedData.articles,
            recommended: cachedData.recommended,
            isFromCache: true,
          ));
          print("✅ [HomeBloc._onFetchHomeData] Données du cache émises avec succès");
        } else {
          print("⚠️ [HomeBloc._onFetchHomeData] Cache vide");
          emit( HomeError("Impossible de charger les données. Vérifiez votre connexion."));
          print("❌ [HomeBloc._onFetchHomeData] État d'erreur émis (cache vide)");
        }
      } catch (cacheError) {
        print("❌ [HomeBloc._onFetchHomeData] Erreur lecture cache: $cacheError");
        emit(HomeError("Erreur de lecture du cache"));
      }
    }
  }

Future<void> _syncWithServer(Emitter<HomeState> emit) async {
  print("🔄 [HomeBloc._syncWithServer] Début synchronisation avec le serveur");
  print("📡 [HomeBloc._syncWithServer] Appel API en parallèle...");
  
  try {
    final results = await Future.wait([
      _homeRepository.getDiscoveries(),
      _homeRepository.getArticles(),
      _homeRepository.getRecommendedDocuments(),
    ]).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        print("⏰ [HomeBloc._syncWithServer] Timeout après 30 secondes");
        throw Exception("Délai d'attente dépassé");
      },
    );

    print("📊 [HomeBloc._syncWithServer] Résultats reçus:");
    print("   - Découvertes: ${(results[0] as List).length}");
    print("   - Articles: ${(results[1] as List).length}");
    print("   - Recommandations: ${(results[2] as List).length}");

    final discoveries = results[0] as List<AcademicDocument>;
    final articles = results[1] as List<Article>;
    final recommended = results[2] as List<AcademicDocument>;  // ← INDEX 2

    // Mise à jour du cache
    print("💾 [HomeBloc._syncWithServer] Sauvegarde dans le cache...");
    try {
      await _localDb.saveHomeCache(
        discoveries: discoveries,
        articles: articles,
        recommended: recommended,
      );
      await _localDb.setHomeLastUpdate(DateTime.now());
      print("✅ [HomeBloc._syncWithServer] Cache mis à jour avec succès");
    } catch (cacheError) {
      print("⚠️ [HomeBloc._syncWithServer] Erreur sauvegarde cache: $cacheError");
    }

    print("📤 [HomeBloc._syncWithServer] Émission état HomeLoaded");
    emit(HomeLoaded(
      discoveries: discoveries,
      articles: articles,
      recommended: recommended,
      isFromCache: false,
    ));
    print("✅ [HomeBloc._syncWithServer] Synchronisation terminée");
    
  } on Exception catch (e) {
    print("❌ [HomeBloc._syncWithServer] Exception: $e");
    rethrow;
  } catch (e) {
    print("❌ [HomeBloc._syncWithServer] Erreur inattendue: $e");
    rethrow;
  }
}
  Future<void> _onRefreshHomeData(RefreshHomeData event, Emitter<HomeState> emit) async {
    print("🔄 [HomeBloc._onRefreshHomeData] Rafraîchissement manuel demandé");
    try {
      print("🌐 [HomeBloc._onRefreshHomeData] Synchronisation forcée avec le serveur...");
      await _syncWithServer(emit);
      print("✅ [HomeBloc._onRefreshHomeData] Rafraîchissement réussi");
    } catch (e, stackTrace) {
      print("❌ [HomeBloc._onRefreshHomeData] Échec du rafraîchissement: $e");
      print("📚 [HomeBloc._onRefreshHomeData] StackTrace: $stackTrace");
      emit(HomeError("Échec de la mise à jour. Vérifiez votre connexion."));
    }
  }
}