part of 'student_space_bloc.dart';

abstract class StudentSpaceEvent extends Equatable {
  const StudentSpaceEvent();
  @override
  List<Object?> get props => [];
}

// ---------- POSTS ----------
class FetchUserPosts extends StudentSpaceEvent {
  final bool refreshRemote;
  const FetchUserPosts({this.refreshRemote = true});
  @override
  List<Object> get props => [refreshRemote];
}

class CreateStudentPost extends StudentSpaceEvent {
  final String content;
  final List<String> mediaPaths;
  const CreateStudentPost({required this.content, this.mediaPaths = const []});
  @override
  List<Object> get props => [content, mediaPaths];
}

class UpdatePostEvent extends StudentSpaceEvent {
  final String shareableId;
  final String newContent;
  const UpdatePostEvent(this.shareableId, this.newContent);
  @override
  List<Object> get props => [shareableId, newContent];
}

class DeletePostEvent extends StudentSpaceEvent {
  final String shareableId;
  const DeletePostEvent(this.shareableId);
  @override
  List<Object> get props => [shareableId];
}

class ToggleLikeEvent extends StudentSpaceEvent {
  final String shareableId;
  final bool currentlyLiked;
  const ToggleLikeEvent(this.shareableId, this.currentlyLiked);
  @override
  List<Object> get props => [shareableId, currentlyLiked];
}

class AddCommentEvent extends StudentSpaceEvent {
  final String shareableId;
  final String content;
  const AddCommentEvent(this.shareableId, this.content);
  @override
  List<Object> get props => [shareableId, content];
}

class FetchCommentsEvent extends StudentSpaceEvent {
  final String shareableId;
  const FetchCommentsEvent(this.shareableId);
  @override
  List<Object> get props => [shareableId];
}

class RecordViewEvent extends StudentSpaceEvent {
  final String shareableId;
  const RecordViewEvent(this.shareableId);
  @override
  List<Object> get props => [shareableId];
}

class SharePostEvent extends StudentSpaceEvent {
  final String shareableId;
  const SharePostEvent(this.shareableId);
  @override
  List<Object> get props => [shareableId];
}

// ---------- DOCUMENTS ----------
class FetchUserDocuments extends StudentSpaceEvent {
  final bool refreshRemote;
  const FetchUserDocuments({this.refreshRemote = true});
  @override
  List<Object> get props => [refreshRemote];
}

class UploadDocumentEvent extends StudentSpaceEvent {
  final String filePath;
  final String fileName;
  const UploadDocumentEvent(this.filePath, this.fileName);
  @override
  List<Object> get props => [filePath, fileName];
}

class DeleteDocumentEvent extends StudentSpaceEvent {
  final int documentId;
  const DeleteDocumentEvent(this.documentId);
  @override
  List<Object> get props => [documentId];
}

// ---------- STATS ACADÉMIQUES ----------
class FetchAcademicStats extends StudentSpaceEvent {
  final bool refreshRemote;
  const FetchAcademicStats({this.refreshRemote = true});
  @override
  List<Object> get props => [refreshRemote];
}

// lib/presentation/features/space_stadent/presentation/bloc/student_space_event.dart

// À la fin du fichier, après les autres événements
class FetchCommunityPosts extends StudentSpaceEvent {
  final bool refreshRemote;
  const FetchCommunityPosts({this.refreshRemote = true});
  @override
  List<Object> get props => [refreshRemote];
}