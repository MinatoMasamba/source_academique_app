// document_detail_event.dart
import 'package:equatable/equatable.dart';

abstract class DocumentDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDocumentDetail extends DocumentDetailEvent {
  final String docId;
  LoadDocumentDetail(this.docId);

  @override
  List<Object?> get props => [docId];
}