// lib/presentation/features/space_stadent/presentation/bloc/student_space_state.dart
import 'package:equatable/equatable.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
import 'package:source_academique/features/auth/domain/entities/resultat.dart';

// ==============================================
// APPROCHE 1 : Classe unique avec enum (existant)
// ==============================================
enum StudentSpaceStatus { initial, loading, success, refreshing, error }

class StudentSpaceState extends Equatable {
  final StudentSpaceStatus status;
  final List<PostNews> posts;
  final List<AcademicDocument> documents;
  final List<dynamic> academicResults;
  final Map<String, List<Comment>> commentsMap;
  final double globalProgress;
  final String? errorMessage;

  const StudentSpaceState({
    this.status = StudentSpaceStatus.initial,
    this.posts = const [],
    this.documents = const [],
    this.academicResults = const [],
    this.commentsMap = const {},
    this.globalProgress = 0.0,
    this.errorMessage,
  });

  int get totalLikes => posts.fold(0, (sum, p) => sum + p.likesCount);
  int get totalViews => posts.fold(0, (sum, p) => sum + p.viewsCount);
  int get totalComments => posts.fold(0, (sum, p) => sum + p.commentsCount);

  StudentSpaceState copyWith({
    StudentSpaceStatus? status,
    List<PostNews>? posts,
    List<AcademicDocument>? documents,
    List<dynamic>? academicResults,
    Map<String, List<Comment>>? commentsMap,
    double? globalProgress,
    String? errorMessage,
  }) {
    return StudentSpaceState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      documents: documents ?? this.documents,
      academicResults: academicResults ?? this.academicResults,
      commentsMap: commentsMap ?? this.commentsMap,
      globalProgress: globalProgress ?? this.globalProgress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        posts,
        documents,
        academicResults,
        commentsMap,
        globalProgress,
        errorMessage,
      ];
}

// ==============================================
// APPROCHE 2 : Classes dédiées pour chaque état
// ==============================================

/// État initial
class StudentSpaceInitial extends StudentSpaceState {
  StudentSpaceInitial() : super(status: StudentSpaceStatus.initial) {
    print("🎯 [StudentSpaceInitial] État initial créé");
  }
}

/// État de chargement
class StudentSpaceLoading extends StudentSpaceState {
  StudentSpaceLoading() : super(status: StudentSpaceStatus.loading) {
    print("⏳ [StudentSpaceLoading] État de chargement - Affichage du loader");
  }
}

/// État rafraîchissement
class StudentSpaceRefreshing extends StudentSpaceState {
  StudentSpaceRefreshing() : super(status: StudentSpaceStatus.refreshing) {
    print("🔄 [StudentSpaceRefreshing] État de rafraîchissement - Pull to refresh");
  }
}

/// État chargé avec succès (données complètes)
class StudentSpaceLoaded extends StudentSpaceState {
  final List<Resultat> academicResultsTyped;
  
  StudentSpaceLoaded({
    required List<PostNews> posts,
    Map<String, List<Comment>> commentsMap = const {},
    List<AcademicDocument> documents = const [],
    List<Resultat> academicResults = const [],
    double globalProgress = 0.0,
  }) : academicResultsTyped = academicResults,
       super(
          status: StudentSpaceStatus.success,
          posts: posts,
          documents: documents,
          academicResults: academicResults,
          commentsMap: commentsMap,
          globalProgress: globalProgress,
        ) {
    print("✅ [StudentSpaceLoaded] État chargé avec succès:");
    print("   - Posts: ${posts.length}");
    print("   - Documents: ${documents.length}");
    print("   - Résultats académiques: ${academicResults.length}");
    print("   - Progression globale: ${(globalProgress * 100).toStringAsFixed(1)}%");
    print("   - Commentaires chargés pour ${commentsMap.length} posts");
  }
  
  @override
  List<Object?> get props => [...super.props, academicResultsTyped];
}

/// État d'erreur
class StudentSpaceError extends StudentSpaceState {
  final String message;
  
  StudentSpaceError(this.message) : super(
    status: StudentSpaceStatus.error,
    errorMessage: message,
  ) {
    print("❌ [StudentSpaceError] État d'erreur: $message");
  }
  
  @override
  List<Object?> get props => [message, ...super.props];
}