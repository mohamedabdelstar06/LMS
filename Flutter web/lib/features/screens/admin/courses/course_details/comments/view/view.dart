import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:ui_web' as ui;
import 'dart:html' as html;

import '../model/model.dart';
import '../state_mangmnet/comments_cubit.dart';
import '../state_mangmnet/comments_state.dart';
import '../state_mangmnet/reporsitery.dart';

class CommentsScreen extends StatelessWidget {
  const CommentsScreen({super.key, this.lectureId = 27});

  final int lectureId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CommentsCubit(repo: CommentsRepository(), lectureId: lectureId)
            ..loadComments(),
      child: const _CommentsView(),
    );
  }
}

class _CommentsView extends StatefulWidget {
  const _CommentsView();

  @override
  State<_CommentsView> createState() => _CommentsViewState();
}

class _CommentsViewState extends State<_CommentsView> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Column(
        children: [
          const _Header(),
          Expanded(
            child: BlocBuilder<CommentsCubit, CommentsState>(
              builder: (context, state) {
                if (state is CommentsLoading) return const _LoadingView();
                if (state is CommentsError) return _ErrorView(state.message);
                if (state is CommentsLoaded) {
                  return _LoadedView(state: state, scrollCtrl: _scrollCtrl);
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF175CD3), Color(0xFF53B1FD)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.forum_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comments',
                style: TextStyle(
                  color: Color(0xFFF1F5F9),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Lecture discussion',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          BlocBuilder<CommentsCubit, CommentsState>(
            builder: (context, state) {
              if (state is CommentsLoaded) {
                final visibleComments = state.comments
                    .where((c) => !c.isDeleted || c.replies.isNotEmpty)
                    .toList();
                final totalReplies = visibleComments.fold(
                  0,
                  (sum, c) => sum + c.replies.length,
                );
                final total = visibleComments.length + totalReplies;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D4ED8).withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withValues(alpha: .3),
                    ),
                  ),
                  child: Text(
                    '$total comments',
                    style: const TextStyle(
                      color: Color(0xFF60A5FA),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF175CD3), Color(0xFF53B1FD)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading comments...',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Color(0xFF94A3B8))),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => context.read<CommentsCubit>().loadComments(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF60A5FA),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.state, required this.scrollCtrl});

  final CommentsLoaded state;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final visible = state.comments
        .where((c) => !c.isDeleted || c.replies.isNotEmpty)
        .toList();

    return Column(
      children: [
        Expanded(
          child: visible.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  itemCount: visible.length,
                  itemBuilder: (_, i) => _CommentTile(
                    key: ValueKey(visible[i].id),
                    comment: visible[i],
                    state: state,
                    isReply: false,
                  ),
                ),
        ),
        const _MainInput(),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2D3748)),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Color(0xFF475569),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No comments yet',
            style: TextStyle(
              color: Color(0xFFF1F5F9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Be the first to start a discussion!',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ],
      ),
    );
  }
}


class _CommentTile extends StatefulWidget {
  const _CommentTile({
    super.key,
    required this.comment,
    required this.state,
    required this.isReply,
  });

  final CommentModel comment;
  final CommentsLoaded state;
  final bool isReply;

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  late final TextEditingController _editCtrl;
  late final TextEditingController _replyCtrl;

  @override
  void initState() {
    super.initState();
    _editCtrl = TextEditingController();
    _replyCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _editCtrl.dispose();
    _replyCtrl.dispose();
    super.dispose();
  }

  String _timeAgo(DateTime dt) => timeago.format(dt, allowFromNow: true);


  String buildImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    if (path.startsWith('http')) return path;

    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    return 'https://skylearn.runasp.net/$cleanPath';
  }


  @override
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CommentsCubit>();
    final comment = widget.comment;

    final isEditing = widget.state.editingCommentId == comment.id;
    final isReplying = widget.state.replyingToId == comment.id;
    final isSubmitting = widget.state.submitting.contains(comment.id);
    final replyCount = comment.replies.length;

    if (isEditing && _editCtrl.text != comment.content) {
      _editCtrl.text = comment.content;
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: widget.isReply ? 6 : 12,
        left: widget.isReply ? 20 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isReply)
            Padding(
              padding: const EdgeInsets.only(top: 12, right: 8),
              child: CustomPaint(
                size: const Size(16, 24),
                painter: _ReplyLinePainter(),
              ),
            ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: comment.isDeleted
                    ? const Color(0xFF1A2535)
                    : widget.isReply
                    ? const Color(0xFF243347)
                    : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEditing
                      ? const Color(0xFF3B82F6).withValues(alpha: .5)
                      : widget.isReply
                      ? const Color(0xFF2D3F55)
                      : const Color(0xFF263245),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCommentHeader(
                    context,
                    cubit,
                    comment,
                    isEditing,
                    replyCount,
                  ),

                  isEditing
                      ? _EditField(
                          ctrl: _editCtrl,
                          onSave: () => cubit.editComment(
                            comment.id,
                            _editCtrl.text.trim(),
                          ),
                          onCancel: () => cubit.setEditing(null),
                        )
                      : _buildCommentContent(comment),

                  if (!comment.isDeleted)
                    _buildCommentActions(
                      cubit,
                      comment,
                      isReplying,
                      isSubmitting,
                      replyCount,
                    ),

                  if (isReplying)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                      child: _InlineReplyInput(
                        ctrl: _replyCtrl,
                        parentCommentId: comment.id,
                      ),
                    ),

                  if (comment.replies.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                      child: Column(
                        children: comment.replies
                            .map(
                              (r) => _CommentTile(
                                key: ValueKey('reply_${r.id}'),
                                comment: r,
                                state: widget.state,
                                isReply: true,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentHeader(
    BuildContext context,
    CommentsCubit cubit,
    dynamic comment,
    bool isEditing,
    int replyCount,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Row(
        children: [
          _Avatar(url: buildImageUrl(comment.userProfileImageUrl)),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.isDeleted ? '[deleted]' : comment.userFullName,
                      style: TextStyle(
                        color: comment.isDeleted
                            ? const Color(0xFF64748B)
                            : const Color(0xFFF1F5F9),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!comment.isDeleted && comment.userRole.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _RoleBadge(role: comment.userRole),
                    ],
                  ],
                ),
                Text(
                  _timeAgo(comment.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          if (!widget.isReply && replyCount > 0)
            _ReplyCounter(count: replyCount),

          if (!comment.isDeleted && comment.isOwner)
            _OwnerActions(
              onEdit: () => cubit.setEditing(isEditing ? null : comment.id),
              onDelete: () => _showDeleteDialog(context, cubit, comment.id),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentContent(dynamic comment) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      child: Text(
        comment.content,
        style: TextStyle(
          color: comment.isDeleted
              ? const Color(0xFF64748B)
              : const Color(0xFF94A3B8),
          fontSize: 13.5,
          fontStyle: comment.isDeleted ? FontStyle.italic : FontStyle.normal,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildCommentActions(
    CommentsCubit cubit,
    dynamic comment,
    bool isReplying,
    bool isSubmitting,
    int replyCount,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Row(
        children: [
          _LikeButton(
            liked: comment.isLikedByCurrentUser,
            count: comment.likeCount,
            loading: isSubmitting,
            onTap: () => cubit.toggleLike(comment.id),
          ),
          const SizedBox(width: 6),

          if (!widget.isReply)
            _ActionChip(
              icon: Icons.reply_rounded,
              label: 'Reply',
              active: isReplying,
              onTap: () => cubit.setReplying(isReplying ? null : comment.id),
            ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CommentsCubit cubit, int id) {
    final TextEditingController confirmController = TextEditingController();
    const String confirmText = 'Comment';
    bool isConfirmed = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                ),
              ),
              contentPadding: EdgeInsets.zero,
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_forever_rounded,
                              color: Color(0xFFEF4444),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delete Comment',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFF1F5F9),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'This action cannot be undone',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFEF4444).withOpacity(0.25),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 16,
                                  color: Color(0xFFFCA5A5),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Deleting this comment will also remove all its replies permanently.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFFCA5A5),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          const Text(
                            'To confirm deletion, type:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF334155),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.keyboard_rounded,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  confirmText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFEF4444),
                                    fontFamily: 'monospace',
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextField(
                            controller: confirmController,
                            autofocus: true,
                            style: const TextStyle(
                              color: Color(0xFFF1F5F9),
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Type "$confirmText" to confirm...',
                              hintStyle: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF0F172A),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Color(0xFF334155)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Color(0xFFEF4444), width: 1.5),
                              ),
                              suffixIcon: confirmController.text.isNotEmpty
                                  ? Icon(
                                isConfirmed
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: isConfirmed
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFEF4444),
                                size: 18,
                              )
                                  : null,
                            ),
                            onChanged: (value) {
                              setDialogState(() {
                                isConfirmed = value.trim() == confirmText;
                              });
                            },
                          ),

                          // Validation feedback
                          if (confirmController.text.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  isConfirmed
                                      ? Icons.check_rounded
                                      : Icons.close_rounded,
                                  size: 13,
                                  color: isConfirmed
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isConfirmed
                                      ? 'Confirmed — you can now delete'
                                      : 'Text does not match',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isConfirmed
                                        ? const Color(0xFF22C55E)
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                confirmController.dispose();
                                Navigator.pop(dialogContext);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF94A3B8),
                                side: const BorderSide(
                                    color: Color(0xFF334155)),
                                padding:
                                const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isConfirmed
                                  ? () {
                                Navigator.pop(dialogContext);
                                cubit.deleteComment(id);
                              }
                                  : null,
                              icon: const Icon(Icons.delete_forever_rounded,
                                  size: 16),
                              label: const Text(
                                'Delete',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                const Color(0xFF334155),
                                disabledForegroundColor:
                                const Color(0xFF64748B),
                                padding:
                                const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}



class _EditField extends StatefulWidget {
  const _EditField({
    required this.ctrl,
    required this.onSave,
    required this.onCancel,
  });

  final TextEditingController ctrl;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  State<_EditField> createState() => _EditFieldState();
}

class _EditFieldState extends State<_EditField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      child: Column(
        children: [
          TextField(
            controller: widget.ctrl,
            focusNode: _focus,
            maxLines: 3,
            style: const TextStyle(color: Color(0xFFF1F5F9), fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF3B82F6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: const Color(0xFF3B82F6).withValues(alpha: .4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF3B82F6)),
              ),
              contentPadding: const EdgeInsets.all(12),
              hintText: 'Edit your comment...',
              hintStyle: const TextStyle(color: Color(0xFF475569)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _SmallButton(
                label: 'Cancel',
                onTap: widget.onCancel,
                primary: false,
              ),
              const SizedBox(width: 8),
              _SmallButton(label: 'Save', onTap: widget.onSave, primary: true),
            ],
          ),
        ],
      ),
    );
  }
}


class _InlineReplyInput extends StatefulWidget {
  const _InlineReplyInput({required this.ctrl, required this.parentCommentId});

  final TextEditingController ctrl;
  final int parentCommentId;

  @override
  State<_InlineReplyInput> createState() => _InlineReplyInputState();
}

class _InlineReplyInputState extends State<_InlineReplyInput> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CommentsCubit>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const CircleAvatar(
          radius: 13,
          backgroundColor: Color(0xFF175CD3),
          child: Text(
            'A',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: widget.ctrl,
            focusNode: _focus,
            maxLines: 2,
            style: const TextStyle(color: Color(0xFFF1F5F9), fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: const Color(0xFF3B82F6).withValues(alpha: .5),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              hintText: 'Write a reply...',
              hintStyle: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _SendButton(
          onTap: () {
            final text = widget.ctrl.text.trim();
            if (text.isEmpty) return;
            cubit.addComment(text, parentCommentId: widget.parentCommentId);
            widget.ctrl.clear();
            _focus.unfocus();
          },
        ),
      ],
    );
  }
}


class _MainInput extends StatefulWidget {
  const _MainInput();

  @override
  State<_MainInput> createState() => _MainInputState();
}

class _MainInputState extends State<_MainInput> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CommentsCubit>();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFF175CD3),
            child: Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              maxLines: 3,
              minLines: 1,
              style: const TextStyle(color: Color(0xFFF1F5F9), fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color(0xFF3B82F6).withValues(alpha: .5),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                hintText: 'Add a comment...',
                hintStyle: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _SendButton(
            onTap: () {
              final text = _ctrl.text.trim();
              if (text.isEmpty) return;
              cubit.addComment(text);
              _ctrl.clear();
              _focus.unfocus();
            },
          ),
        ],
      ),
    );
  }
}



class _ReplyCounter extends StatelessWidget {
  const _ReplyCounter({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF0EA5E9).withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0EA5E9).withValues(alpha: .25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.reply_rounded, size: 11, color: Color(0xFF38BDF8)),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: const TextStyle(
              color: Color(0xFF38BDF8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFF175CD3),
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, __) {},
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF175CD3).withValues(alpha: .2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: .3),
        ),
      ),
      child: Text(
        role,
        style: const TextStyle(
          color: Color(0xFF60A5FA),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _OwnerActions extends StatelessWidget {
  const _OwnerActions({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF334155)),
      ),
      icon: const Icon(
        Icons.more_horiz_rounded,
        color: Color(0xFF64748B),
        size: 18,
      ),
      onSelected: (v) {
        if (v == 'edit') onEdit();
        if (v == 'delete') onDelete();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, color: Color(0xFF60A5FA), size: 16),
              SizedBox(width: 8),
              Text(
                'Edit',
                style: TextStyle(color: Color(0xFFF1F5F9), fontSize: 13),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFEF4444),
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Delete',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({
    required this.liked,
    required this.count,
    required this.loading,
    required this.onTap,
  });

  final bool liked;
  final int count;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: liked
              ? const Color(0xFF1D4ED8).withValues(alpha: .15)
              : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: liked
                ? const Color(0xFF3B82F6).withValues(alpha: .4)
                : const Color(0xFF2D3748),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Color(0xFF60A5FA),
                ),
              )
            else
              Icon(
                liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 13,
                color: liked
                    ? const Color(0xFF60A5FA)
                    : const Color(0xFF64748B),
              ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                color: liked
                    ? const Color(0xFF60A5FA)
                    : const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatefulWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: widget.active
                ? const Color(0xFF1D4ED8).withValues(alpha: .15)
                : _hov
                ? const Color(0xFF1E293B)
                : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.active
                  ? const Color(0xFF3B82F6).withValues(alpha: .4)
                  : _hov
                  ? const Color(0xFF3B82F6).withValues(alpha: .2)
                  : const Color(0xFF2D3748),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 13,
                color: widget.active
                    ? const Color(0xFF60A5FA)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.active
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatefulWidget {
  const _SendButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hov
                  ? [const Color(0xFF2563EB), const Color(0xFF60A5FA)]
                  : [const Color(0xFF175CD3), const Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: _hov
                ? [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: .4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.label,
    required this.onTap,
    required this.primary,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: primary ? const Color(0xFF175CD3) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: primary ? const Color(0xFF3B82F6) : const Color(0xFF334155),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: primary ? Colors.white : const Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ReplyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2D3F55)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.5)
      ..lineTo(size.width, size.height * 0.5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
class WebImage extends StatelessWidget {

  const WebImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  });
  final String url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final viewId = url;

    ui.platformViewRegistry.registerViewFactory(viewId, (int _) {
      final img = html.ImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      return img;
    });

    return SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: viewId),
    );
  }
}

