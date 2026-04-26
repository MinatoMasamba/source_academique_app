import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:source_academique/core/storage/local_db_manager.dart';
import 'package:source_academique/features/auth/data/repositories/student_space_repository.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
import 'package:source_academique/features/auth/domain/entities/resultat.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';
import 'package:source_academique/presentation/features/space_stadent/presentation/bloc/student_space_state.dart';

import 'student_space_state.dart';

part 'student_space_event.dart';

class StudentSpaceBloc extends Bloc<StudentSpaceEvent, StudentSpaceState> {
  final StudentSpaceRepository _repository;
  final LocalDbManager _localDb;
  final int userId;

  StudentSpaceBloc({
    required StudentSpaceRepository repository,
    required LocalDbManager localDb,
    required this.userId,
  }) : _repository = repository,
       _localDb = localDb,
       super(const StudentSpaceState()) {
    on<FetchUserPosts>(_onFetchUserPosts);
    on<CreateStudentPost>(_onCreatePost);
    on<UpdatePostEvent>(_onUpdatePost);
    on<DeletePostEvent>(_onDeletePost);
    on<ToggleLikeEvent>(_onToggleLike);
    on<AddCommentEvent>(_onAddComment);
    on<FetchCommentsEvent>(_onFetchComments);
    on<RecordViewEvent>(_onRecordView);
    on<SharePostEvent>(_onSharePost);
    on<FetchUserDocuments>(_onFetchUserDocuments);
    on<UploadDocumentEvent>(_onUploadDocument);
    on<DeleteDocumentEvent>(_onDeleteDocument);
    on<FetchAcademicStats>(_onFetchAcademicStats);
    on<FetchCommunityPosts>(_onFetchCommunityPosts);
  }

  // ---------- POSTS (cache + réseau) ----------
  Future<void> _onFetchUserPosts(FetchUserPosts event, Emitter<StudentSpaceState> emit) async {
    print("🔵 [1/5] Début _onFetchUserPosts - userId: $userId, refreshRemote: ${event.refreshRemote}");
    
    // 1. Cache immédiat
    try {
      print("🔵 [2/5] Lecture du cache Hive...");
      final cachedPosts = _localDb.getStudentPosts();
      print("📦 Cache: ${cachedPosts.length} posts trouvés");
      
      if (cachedPosts.isNotEmpty) {
        print("✅ Affichage depuis le cache (${cachedPosts.length} posts)");
        emit(state.copyWith(status: StudentSpaceStatus.success, posts: cachedPosts));
      } else {
        print("⏳ Cache vide, affichage du loader");
        emit(state.copyWith(status: StudentSpaceStatus.loading));
      }
    } catch (cacheError) {
      print("❌ ERREUR LECTURE CACHE: $cacheError");
      emit(state.copyWith(status: StudentSpaceStatus.loading));
    }

    if (!event.refreshRemote) {
      print("🔚 Pas de rafraîchissement réseau demandé, fin du traitement");
      return;
    }

    // 2. Synchronisation réseau
    try {
      print("🌐 [3/5] Appel API getUserPosts($userId)...");
      final remotePosts = await _repository.getUserPosts(userId);
      print("📡 API: ${remotePosts.length} posts reçus du serveur");
      
      if (remotePosts.isEmpty) {
        print("⚠️ Aucun post retourné par l'API");
      } else {
        print("📝 Premier post reçu - id: ${remotePosts.first.id}, titre: ${remotePosts.first.titre.substring(0, remotePosts.first.titre.length > 50 ? 50 : remotePosts.first.titre.length)}...");
      }
      
      print("💾 [4/5] Sauvegarde dans Hive...");
      await _localDb.saveStudentPosts(remotePosts);
      print("✅ Cache mis à jour avec ${remotePosts.length} posts");
      
      print("📤 [5/5] Émission de l'état success avec les posts du réseau");
      emit(state.copyWith(status: StudentSpaceStatus.success, posts: remotePosts));
      print("🎉 Posts synchronisés avec le serveur - SUCCÈS");
      
    } catch (networkError, stackTrace) {
      print("❌ ERREUR RÉSEAU: $networkError");
      print("📚 StackTrace: $stackTrace");
      
      // Si on a déjà des données en cache, on reste en success
      if (state.status == StudentSpaceStatus.success) {
        print("⚠️ Erreur réseau mais données cache existantes - on reste en success");
      } else {
        print("💀 Émission de l'état d'erreur");
        emit(state.copyWith(
          status: StudentSpaceStatus.error, 
          errorMessage: "Erreur réseau: ${networkError.toString()}"
        ));
      }
    } catch (e, stackTrace) {
      print("❌ ERREUR GÉNÉRALE: $e");
      print("📚 StackTrace: $stackTrace");
      if (state.status != StudentSpaceStatus.success) {
        emit(state.copyWith(
          status: StudentSpaceStatus.error, 
          errorMessage: e.toString()
        ));
      }
    }
  }

  Future<void> _onCreatePost(CreateStudentPost event, Emitter<StudentSpaceState> emit) async {
    print("📝 Création d'un nouveau post: ${event.content.substring(0, event.content.length > 50 ? 50 : event.content.length)}...");
    try {
      // Appel unique avec ou sans fichiers
      final newPost = await _repository.createPost(
        event.content,
        filePaths: event.mediaPaths.isEmpty ? null : event.mediaPaths,
      );
      print("✅ Post créé avec succès, id: ${newPost.id}");
      final updatedPosts = [newPost, ...state.posts];
      await _localDb.saveStudentPosts(updatedPosts);
      emit(state.copyWith(posts: updatedPosts));
      print("📊 Total posts après création: ${updatedPosts.length}");
    } catch (e) {
      print("❌ Erreur création post: $e");
      emit(state.copyWith(errorMessage: "Erreur création post: $e"));
    }
  }

  Future<void> _onUpdatePost(UpdatePostEvent event, Emitter<StudentSpaceState> emit) async {
    print("✏️ Modification du post: ${event.shareableId}");
    try {
      final updated = await _repository.updatePost(event.shareableId, event.newContent);
      final updatedPosts = state.posts.map((p) => p.shareableId == event.shareableId ? updated : p).toList();
      await _localDb.saveStudentPosts(updatedPosts);
      emit(state.copyWith(posts: updatedPosts));
      print("✅ Post modifié avec succès");
    } catch (e) {
      print("❌ Erreur modification: $e");
      emit(state.copyWith(errorMessage: "Erreur modification: $e"));
    }
  }

  Future<void> _onDeletePost(DeletePostEvent event, Emitter<StudentSpaceState> emit) async {
    print("🗑️ Suppression du post: ${event.shareableId}");
    final previousPosts = state.posts;
    try {
      final updatedPosts = state.posts.where((p) => p.shareableId != event.shareableId).toList();
      emit(state.copyWith(posts: updatedPosts));
      await _repository.deletePost(event.shareableId);
      await _localDb.saveStudentPosts(updatedPosts);
      print("✅ Post supprimé avec succès. Reste: ${updatedPosts.length} posts");
    } catch (e) {
      print("❌ Erreur suppression: $e - Rollback effectué");
      emit(state.copyWith(posts: previousPosts, errorMessage: "Erreur suppression: $e"));
    }
  }

  Future<void> _onToggleLike(ToggleLikeEvent event, Emitter<StudentSpaceState> emit) async {
    print("❤️ Toggle like sur post: ${event.shareableId}, currentlyLiked: ${event.currentlyLiked}");
    final currentState = state;
    // Optimistic update
    final updatedPosts = currentState.posts.map((p) {
      if (p.shareableId == event.shareableId) {
        final newIsLiked = !event.currentlyLiked;
        return p.copyWith(
          isLiked: newIsLiked,
          likesCount: newIsLiked ? p.likesCount + 1 : p.likesCount - 1,
        );
      }
      return p;
    }).toList();
    emit(state.copyWith(posts: updatedPosts));
    await _localDb.saveStudentPosts(updatedPosts);

    try {
      if (event.currentlyLiked) {
        await _repository.unlikePost(event.shareableId);
        print("👍 Like retiré avec succès");
      } else {
        await _repository.likePost(event.shareableId);
        print("❤️ Like ajouté avec succès");
      }
    } catch (e) {
      print("❌ Erreur like: $e - Rollback effectué");
      emit(state.copyWith(posts: currentState.posts, errorMessage: "Erreur like: $e"));
    }
  }

  Future<void> _onAddComment(AddCommentEvent event, Emitter<StudentSpaceState> emit) async {
    print("💬 Ajout commentaire sur post: ${event.shareableId}");
    try {
      await _repository.addComment(event.shareableId, event.content);
      add(FetchCommentsEvent(event.shareableId));
      final updatedPosts = state.posts.map((p) {
        if (p.shareableId == event.shareableId) {
          return p.copyWith(commentsCount: p.commentsCount + 1);
        }
        return p;
      }).toList();
      await _localDb.saveStudentPosts(updatedPosts);
      emit(state.copyWith(posts: updatedPosts));
      print("✅ Commentaire ajouté avec succès");
    } catch (e) {
      print("❌ Erreur commentaire: $e");
      emit(state.copyWith(errorMessage: "Erreur commentaire: $e"));
    }
  }

  Future<void> _onFetchComments(FetchCommentsEvent event, Emitter<StudentSpaceState> emit) async {
    print("📖 Chargement commentaires pour post: ${event.shareableId}");
    try {
      final comments = await _repository.getComments(event.shareableId);
      final newMap = Map<String, List<Comment>>.from(state.commentsMap);
      newMap[event.shareableId] = comments;
      emit(state.copyWith(commentsMap: newMap));
      print("✅ ${comments.length} commentaires chargés");
    } catch (e) {
      print("❌ Erreur chargement commentaires: $e");
    }
  }

  Future<void> _onRecordView(RecordViewEvent event, Emitter<StudentSpaceState> emit) async {
    print("👁️ Enregistrement vue pour post: ${event.shareableId}");
    try {
      await _repository.recordView(event.shareableId);
    } catch (e) {
      print("❌ Erreur enregistrement vue: $e");
    }
  }

  Future<void> _onSharePost(SharePostEvent event, Emitter<StudentSpaceState> emit) async {
    print("📤 Partage du post: ${event.shareableId}");
    try {
      await _repository.sharePost(event.shareableId);
      final updatedPosts = state.posts.map((p) {
        if (p.shareableId == event.shareableId) {
          return p.copyWith(sharesCount: p.sharesCount + 1);
        }
        return p;
      }).toList();
      await _localDb.saveStudentPosts(updatedPosts);
      emit(state.copyWith(posts: updatedPosts));
      print("✅ Post partagé avec succès");
    } catch (e) {
      print("❌ Erreur partage: $e");
    }
  }

  // ---------- DOCUMENTS ----------
  Future<void> _onFetchUserDocuments(FetchUserDocuments event, Emitter<StudentSpaceState> emit) async {
    print("📄 Chargement documents utilisateur...");
    final cachedDocs = _localDb.getSavedFiles();
    if (cachedDocs.isNotEmpty) {
      print("📦 ${cachedDocs.length} documents du cache");
      emit(state.copyWith(documents: cachedDocs));
    }

    if (!event.refreshRemote) return;

    try {
      final remoteDocs = await _repository.getUserDocuments(userId);
      await _localDb.saveStudentFiles(remoteDocs);
      emit(state.copyWith(documents: remoteDocs));
      print("✅ ${remoteDocs.length} documents synchronisés");
    } catch (e) {
      print("❌ Erreur synchronisation documents: $e");
    }
  }

  Future<void> _onUploadDocument(UploadDocumentEvent event, Emitter<StudentSpaceState> emit) async {
    print("📤 Upload document: ${event.fileName}");
    try {
      final newDoc = await _repository.uploadDocument(event.filePath, event.fileName);
      final updatedDocs = [newDoc, ...state.documents];
      await _localDb.saveStudentFiles(updatedDocs);
      emit(state.copyWith(documents: updatedDocs));
      print("✅ Document uploadé avec succès");
    } catch (e) {
      print("❌ Erreur upload: $e");
      emit(state.copyWith(errorMessage: "Erreur upload: $e"));
    }
  }

  Future<void> _onDeleteDocument(DeleteDocumentEvent event, Emitter<StudentSpaceState> emit) async {
    print("🗑️ Suppression document id: ${event.documentId}");
    try {
      await _repository.deleteDocument(event.documentId);
      final updatedDocs = state.documents.where((d) => d.id != event.documentId.toString()).toList();
      await _localDb.saveStudentFiles(updatedDocs);
      emit(state.copyWith(documents: updatedDocs));
      print("✅ Document supprimé avec succès");
    } catch (e) {
      print("❌ Erreur suppression document: $e");
      emit(state.copyWith(errorMessage: "Erreur suppression document: $e"));
    }
  }

  // ---------- STATS ACADÉMIQUES ----------
  Future<void> _onFetchAcademicStats(FetchAcademicStats event, Emitter<StudentSpaceState> emit) async {
    print("📊 Chargement statistiques académiques...");
    final cachedResults = _localDb.getAcademicResults();
    if (cachedResults.isNotEmpty) {
      final progress = _computeProgress(cachedResults);
      emit(state.copyWith(academicResults: cachedResults, globalProgress: progress));
      print("📦 ${cachedResults.length} résultats du cache, progression: $progress");
    }

    if (!event.refreshRemote) return;

    try {
      final remoteResults = await _repository.getAcademicResults();
      await _localDb.saveAcademicResults(remoteResults);
      final progress = _computeProgress(remoteResults);
      emit(state.copyWith(academicResults: remoteResults, globalProgress: progress));
      print("✅ ${remoteResults.length} résultats synchronisés, progression: $progress");
    } catch (e) {
      print("❌ Erreur synchronisation stats: $e");
    }
  }

  double _computeProgress(List<dynamic> results) {
    if (results.isEmpty) return 0.0;
    double total = 0.0;
    for (var r in results) {
      if (r is Resultat) {
        total += r.note / r.noteMaxima;
      }
    }
    return total / results.length;
  }


  Future<void> _onFetchCommunityPosts(FetchCommunityPosts event, Emitter<StudentSpaceState> emit) async {
  print("🌍 [Community] Chargement des posts communauté, refreshRemote: ${event.refreshRemote}");

  // 1. Cache immédiat
  try {
    final cachedPosts = _localDb.getCommunityPosts();
    if (cachedPosts.isNotEmpty) {
      print("📦 [Community] Cache: ${cachedPosts.length} posts");
      emit(state.copyWith(status: StudentSpaceStatus.success, posts: cachedPosts));
    } else {
      emit(state.copyWith(status: StudentSpaceStatus.loading));
    }
  } catch (e) {
    emit(state.copyWith(status: StudentSpaceStatus.loading));
  }

  if (!event.refreshRemote) return;

  // 2. Synchronisation réseau
  try {
    final remotePosts = await _repository.getCommunityPosts();
    await _localDb.saveCommunityPosts(remotePosts);
    emit(state.copyWith(status: StudentSpaceStatus.success, posts: remotePosts));
    print("✅ [Community] ${remotePosts.length} posts synchronisés");
  } catch (e) {
    print("❌ [Community] Erreur réseau: $e");
    if (state.status != StudentSpaceStatus.success) {
      emit(state.copyWith(status: StudentSpaceStatus.error, errorMessage: e.toString()));
    }
  }
}
}