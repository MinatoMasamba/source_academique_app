// home_state.dart
part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  HomeInitial() {
    print("🏠 [HomeInitial] État initial créé");
  }
}

class HomeLoading extends HomeState {
  HomeLoading() {
    print("⏳ [HomeLoading] État de chargement - Affichage du loader");
  }
}

class HomeLoaded extends HomeState {
  final List<AcademicDocument> discoveries;
  final List<Article> articles;
  final List<AcademicDocument> recommended;
  final bool isFromCache;

  HomeLoaded({
    required this.discoveries,
    required this.articles,
    required this.recommended,
    this.isFromCache = false,
  }) {
    print("✅ [HomeLoaded] État chargé avec succès:");
    print("   - isFromCache: $isFromCache");
    print("   - Découvertes: ${discoveries.length}");
    print("   - Articles: ${articles.length}");
    print("   - Recommandations: ${recommended.length}");
    if (isFromCache) {
      print("   ⚠️ Mode hors-ligne - Données provenant du cache");
    } else {
      print("   🌐 Mode en ligne - Données fraîches du serveur");
    }
  }

  @override List<Object?> get props => [discoveries, articles, recommended, isFromCache];
}

class HomeError extends HomeState {
  final String message;
  
  HomeError(this.message) {
    print("❌ [HomeError] État d'erreur: $message");
  }
  
  @override List<Object?> get props => [message];
}