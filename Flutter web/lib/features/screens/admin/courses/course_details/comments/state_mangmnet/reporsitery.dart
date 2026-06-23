import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../model/model.dart';


class CommentsRepository {
  static const String _base = 'https://skylearn.runasp.net/api';

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorageHelper.getTokenSecure();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<CommentModel>> getComments(int lectureId) async {
    final res = await http.get(
      Uri.parse('$_base/lectures/$lectureId/comments'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => CommentModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load comments (${res.statusCode})');
  }

  Future<CommentModel> createComment(int lectureId, String content, int? parentCommentId) async {
    final res = await http.post(
      Uri.parse('$_base/lectures/$lectureId/comments'),
      headers: await _headers(),
      body: jsonEncode({'content': content, 'parentCommentId': parentCommentId}),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return CommentModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to create comment (${res.statusCode})');
  }

  Future<CommentModel> updateComment(int commentId, String content) async {
    final res = await http.put(
      Uri.parse('$_base/comments/$commentId'),
      headers: await _headers(),
      body: jsonEncode({'content': content}),
    );
    if (res.statusCode == 200) {
      return CommentModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to update comment (${res.statusCode})');
  }

  Future<void> deleteComment(int commentId) async {
    final res = await http.delete(
      Uri.parse('$_base/comments/$commentId'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete comment (${res.statusCode})');
    }
  }

  Future<bool> toggleLike(int commentId) async {
    final res = await http.post(
      Uri.parse('$_base/comments/$commentId/like'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['liked'] as bool;
    }
    throw Exception('Failed to toggle like (${res.statusCode})');
  }
}