part of 'library_bloc.dart';

abstract class LibraryState extends Equatable {
  const LibraryState();
  @override List<Object?> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<AcademicDocument> documents;
  final String selectedType;
  final String searchQuery;

  const LibraryLoaded({
    required this.documents,
    required this.selectedType,
    required this.searchQuery,
  });

  LibraryLoaded copyWith({
    List<AcademicDocument>? documents,
    String? selectedType,
    String? searchQuery,
  }) {
    return LibraryLoaded(
      documents: documents ?? this.documents,
      selectedType: selectedType ?? this.selectedType,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override List<Object?> get props => [documents, selectedType, searchQuery];
}

class LibraryError extends LibraryState {
  final String message;
  const LibraryError(this.message);
  @override List<Object?> get props => [message];
}