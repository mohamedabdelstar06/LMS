class CommentModel {

  CommentModel({
    required this.id,
    required this.activityId,
    required this.userId,
    required this.userFullName,
    required this.userProfileImageUrl,
    required this.userRole,
    required this.content,
    this.parentCommentId,
    required this.likeCount,
    required this.isLikedByCurrentUser,
    required this.isOwner,
    required this.createdAt,
    this.updatedAt,
    required this.isDeleted,
    required this.replies,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    id: json['id'],
    activityId: json['activityId'],
    userId: json['userId'],
    userFullName: json['userFullName'] ?? '',
    userProfileImageUrl: json['userProfileImageUrl'] ?? '',
    userRole: json['userRole'] ?? '',
    content: json['content'] ?? '',
    parentCommentId: json['parentCommentId'],
    likeCount: json['likeCount'] ?? 0,
    isLikedByCurrentUser: json['isLikedByCurrentUser'] ?? false,
    isOwner: json['isOwner'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    isDeleted: json['isDeleted'] ?? false,
    replies: (json['replies'] as List<dynamic>?)
        ?.map((e) => CommentModel.fromJson(e))
        .toList() ??
        [],
  );
  final int id;
  final int activityId;
  final int userId;
  final String userFullName;
  final String userProfileImageUrl;
  final String userRole;
  final String content;
  final int? parentCommentId;
  final int likeCount;
  final bool isLikedByCurrentUser;
  final bool isOwner;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final List<CommentModel> replies;

  CommentModel copyWith({
    int? likeCount,
    bool? isLikedByCurrentUser,
    String? content,
    List<CommentModel>? replies,
  }) =>
      CommentModel(
        id: id,
        activityId: activityId,
        userId: userId,
        userFullName: userFullName,
        userProfileImageUrl: userProfileImageUrl,
        userRole: userRole,
        content: content ?? this.content,
        parentCommentId: parentCommentId,
        likeCount: likeCount ?? this.likeCount,
        isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
        isOwner: isOwner,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isDeleted: isDeleted,
        replies: replies ?? this.replies,
      );
}