import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:source_academique/features/auth/data/repositories/library_repository.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';


part 'library_event.dart';
part 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final LibraryRepository _repository;

  LibraryBloc(this._repository) : super(LibraryInitial()) {
    on<FetchLibraryDocuments>(_onFetchDocuments);
    on<FilterByDocumentType>(_onFilterByType);
    on<SearchLibraryDocuments>(_onSearch);
  }

  // Liste complète non filtrée
  List<AcademicDocument> _allDocuments = [];

  Future<void> _onFetchDocuments(FetchLibraryDocuments event, Emitter<LibraryState> emit) async {
    emit(LibraryLoading());
    try {
      _allDocuments = await _repository.getAllDocuments();
      emit(LibraryLoaded(
        documents: _allDocuments,
        selectedType: event.selectedType ?? 'Tous',
        searchQuery: '',
      ));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  void _onFilterByType(FilterByDocumentType event, Emitter<LibraryState> emit) {
    if (state is LibraryLoaded) {
      final currentState = state as LibraryLoaded;
      final newSelectedType = event.documentType;
      List<AcademicDocument> filtered = _applyFilters(_allDocuments, newSelectedType, currentState.searchQuery);
      emit(currentState.copyWith(
        documents: filtered,
        selectedType: newSelectedType,
      ));
    }
  }

  void _onSearch(SearchLibraryDocuments event, Emitter<LibraryState> emit) {
    if (state is LibraryLoaded) {
      final currentState = state as LibraryLoaded;
      final newQuery = event.query;
      List<AcademicDocument> filtered = _applyFilters(_allDocuments, currentState.selectedType, newQuery);
      emit(currentState.copyWith(
        documents: filtered,
        searchQuery: newQuery,
      ));
    }
  }

  List<AcademicDocument> _applyFilters(List<AcademicDocument> source, String type, String query) {
    List<AcademicDocument> result = List.from(source);

    // Filtre par type de document
    if (type != 'Tous') {
      result = result.where((doc) => doc.type.toLowerCase() == type.toLowerCase()).toList();
    }

    // Filtre par recherche textuelle
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      result = result.where((doc) =>
        doc.title.toLowerCase().contains(lowerQuery) ||
        doc.faculty.toLowerCase().contains(lowerQuery) ||
        doc.author.toLowerCase().contains(lowerQuery)
      ).toList();
    }

    return result;
  }
}