// document_detail_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'document_detail_event.dart';
import 'document_detail_state.dart';
import 'package:source_academique/core/storage/local_db_manager.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';

class DocumentDetailBloc extends Bloc<DocumentDetailEvent, DocumentDetailState> {
  final LocalDbManager localDb; 
  // Ajoute ici ton repository pour les appels API

  DocumentDetailBloc({required this.localDb}) : super(DocumentDetailInitial()) {
    on<LoadDocumentDetail>(_onLoadDocument);
  }

  Future<void> _onLoadDocument(
    LoadDocumentDetail event, 
    Emitter<DocumentDetailState> emit
  ) async {
    emit(DocumentDetailLoading());

    try {
      // 1. TENTER DE RÉCUPÉRER DEPUIS LE CACHE LOCAL (Persistance permanente)
      final cachedDoc = localDb.getDocumentById(event.docId);
      
      if (cachedDoc != null) {
        emit(DocumentDetailLoaded(cachedDoc as AcademicDocument, isFromCache: true));
      }

      // 2. TENTER DE METTRE À JOUR VIA L'API (Si connexion disponible)
      // On fait l'appel API ici... 
      // Si succès -> on sauvegarde dans localDb et on émet le nouvel état
      // final updatedDoc = await repository.fetchDocument(event.docId);
      // await localDb.saveDocument(updatedDoc);
      // emit(DocumentDetailLoaded(updatedDoc, isFromCache: false));

    } catch (e) {
      // Si erreur réseau et qu'on n'a rien en cache
      if (state is! DocumentDetailLoaded) {
        emit(DocumentDetailError("Impossible de charger le document hors-ligne."));
      }
    }
  }
}