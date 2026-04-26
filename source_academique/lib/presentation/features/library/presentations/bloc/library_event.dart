part of 'library_bloc.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();
  @override List<Object?> get props => [];
}

class FetchLibraryDocuments extends LibraryEvent {
  final String? selectedType;
  const FetchLibraryDocuments({this.selectedType});
}

class FilterByDocumentType extends LibraryEvent {
  final String documentType;
  const FilterByDocumentType(this.documentType);
  @override List<Object?> get props => [documentType];
}

class SearchLibraryDocuments extends LibraryEvent {
  final String query;
  const SearchLibraryDocuments(this.query);
  @override List<Object?> get props => [query];
}