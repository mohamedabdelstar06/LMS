import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/courses/course_details/comments/state_mangmnet/reporsitery.dart';

import '../model/model.dart';
import 'comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {

  CommentsCubit({required CommentsRepository repo, required this.lectureId})
      : _repo = repo,
        super(CommentsInitial());
  final CommentsRepository _repo;
  final int lectureId;

  Future<void> loadComments() async {
    emit(CommentsLoading());
    try {
      final comments = await _repo.getComments(lectureId);
      emit(CommentsLoaded(comments: comments));
    } catch (e) {
      emit(CommentsError(e.toString()));
    }
  }

  void setReplying(int? commentId) {
    final s = state;
    if (s is CommentsLoaded) {
      emit(s.copyWith(replyingToId: commentId, clearReplying: commentId == null));
    }
  }

  void setEditing(int? commentId) {
    final s = state;
    if (s is CommentsLoaded) {
      emit(s.copyWith(editingCommentId: commentId, clearEditing: commentId == null));
    }
  }

  Future<void> addComment(String content, {int? parentCommentId}) async {
    final s = state;
    if (s is! CommentsLoaded) return;
    try {
      final newComment = await _repo.createComment(lectureId, content, parentCommentId);
      List<CommentModel> updated;
      if (parentCommentId == null) {
        updated = [newComment, ...s.comments];
      } else {
        updated = _addReply(s.comments, parentCommentId, newComment);
      }
      emit(s.copyWith(comments: updated, clearReplying: true));
    } catch (_) {}
  }

  Future<void> editComment(int commentId, String content) async {
    final s = state;
    if (s is! CommentsLoaded) return;
    try {
      final updated = await _repo.updateComment(commentId, content);
      final newList = _updateComment(s.comments, updated);
      emit(s.copyWith(comments: newList, clearEditing: true));
    } catch (_) {}
  }

  Future<void> deleteComment(int commentId) async {
    final s = state;
    if (s is! CommentsLoaded) return;
    try {
      await _repo.deleteComment(commentId);
      final newList = _markDeleted(s.comments, commentId);
      emit(s.copyWith(comments: newList));
    } catch (_) {}
  }

  Future<void> toggleLike(int commentId) async {
    final s = state;
    if (s is! CommentsLoaded) return;
    final submitting = Set<int>.from(s.submitting)..add(commentId);
    emit(s.copyWith(submitting: submitting));
    try {
      final liked = await _repo.toggleLike(commentId);
      final newList = _toggleLikeInList(s.comments, commentId, liked);
      final done = Set<int>.from((state as CommentsLoaded).submitting)..remove(commentId);
      emit((state as CommentsLoaded).copyWith(comments: newList, submitting: done));
    } catch (_) {
      final done = Set<int>.from((state as CommentsLoaded).submitting)..remove(commentId);
      emit((state as CommentsLoaded).copyWith(submitting: done));
    }
  }

  List<CommentModel> _addReply(List<CommentModel> list, int parentId, CommentModel reply) =>
      list.map((c) {
        if (c.id == parentId) return c.copyWith(replies: [...c.replies, reply]);
        if (c.replies.isNotEmpty) return c.copyWith(replies: _addReply(c.replies, parentId, reply));
        return c;
      }).toList();

  List<CommentModel> _updateComment(List<CommentModel> list, CommentModel updated) =>
      list.map((c) {
        if (c.id == updated.id) return updated.copyWith(replies: c.replies);
        if (c.replies.isNotEmpty) return c.copyWith(replies: _updateComment(c.replies, updated));
        return c;
      }).toList();

  List<CommentModel> _markDeleted(List<CommentModel> list, int id) =>
      list.map((c) {
        if (c.id == id) {
          return CommentModel(
            id: c.id, activityId: c.activityId, userId: c.userId,
            userFullName: '[deleted]', userProfileImageUrl: c.userProfileImageUrl,
            userRole: c.userRole, content: '[deleted]', parentCommentId: c.parentCommentId,
            likeCount: 0, isLikedByCurrentUser: false, isOwner: c.isOwner,
            createdAt: c.createdAt, updatedAt: DateTime.now(), isDeleted: true,
            replies: c.replies,
          );
        }
        if (c.replies.isNotEmpty) return c.copyWith(replies: _markDeleted(c.replies, id));
        return c;
      }).toList();

  List<CommentModel> _toggleLikeInList(List<CommentModel> list, int id, bool liked) =>
      list.map((c) {
        if (c.id == id) {
          return c.copyWith(
            isLikedByCurrentUser: liked,
            likeCount: liked ? c.likeCount + 1 : (c.likeCount - 1).clamp(0, 9999),
          );
        }
        if (c.replies.isNotEmpty) return c.copyWith(replies: _toggleLikeInList(c.replies, id, liked));
        return c;
      }).toList();
}