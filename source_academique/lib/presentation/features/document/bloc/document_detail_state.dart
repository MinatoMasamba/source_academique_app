// document_detail_state.dart
import 'package:equatable/equatable.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';

abstract class DocumentDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DocumentDetailInitial extends DocumentDetailState {}

class DocumentDetailLoading extends DocumentDetailState {}

class DocumentDetailLoaded extends DocumentDetailState {
  final AcademicDocument document;
  final bool isFromCache; // Pour informer l'utilisateur si la donnée est hors-ligne

  DocumentDetailLoaded(this.document, {this.isFromCache = false});

  @override
  List<Object?> get props => [document, isFromCache];
}

class DocumentDetailError extends DocumentDetailState {
  final String message;
  DocumentDetailError(this.message);

  @override
  List<Object?> get props => [message];
}