import '../model/model.dart';

abstract class CommentsState {}

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {}

class CommentsLoaded extends CommentsState {
  final List<CommentModel> comments;
  final int? replyingToId;
  final int? editingCommentId;
  final Set<int> submitting;

  CommentsLoaded({
    required this.comments,
    this.replyingToId,
    this.editingCommentId,
    this.submitting = const {},
  });

  CommentsLoaded copyWith({
    List<CommentModel>? comments,
    int? replyingToId,
    bool clearReplying = false,
    int? editingCommentId,
    bool clearEditing = false,
    Set<int>? submitting,
  }) =>
      CommentsLoaded(
        comments: comments ?? this.comments,
        replyingToId: clearReplying ? null : replyingToId ?? this.replyingToId,
        editingCommentId: clearEditing ? null : editingCommentId ?? this.editingCommentId,
        submitting: submitting ?? this.submitting,
      );
}

class CommentsError extends CommentsState {
  final String message;
  CommentsError(this.message);
}