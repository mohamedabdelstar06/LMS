// ignore_for_file: avoid_redundant_argument_values

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/helpers/api_url_helper.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_model.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({Dio? dio}) : _dio = dio ?? Dio(), super(ChatInitial());

  final Dio _dio;

  static const _sessionsKey = 'chat_sessions_v1';

 

  Future<Map<String, String>> get _authHeaders async {
    final token = await TokenStorageHelper.getTokenSecure();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  List<ChatMessage> get _currentMessages =>
      state is ChatLoaded ? (state as ChatLoaded).messages : [];

  List<ChatSession> get _currentSessions =>
      state is ChatLoaded ? (state as ChatLoaded).sessions : [];



  Future<List<ChatSession>> _loadSessionsLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionsKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveSessionsLocal(List<ChatSession> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
      await prefs.setString(_sessionsKey, encoded);
    } catch (_) {}
  }

 
  Future<void> _archiveCurrentSession() async {
    final msgs = _currentMessages;
    if (msgs.isEmpty) return;

    final firstUser = msgs.firstWhere(
      (m) => m.isUser,
      orElse: () => msgs.first,
    );
    final title = firstUser.content.length > 40
        ? '${firstUser.content.substring(0, 40)}…'
        : firstUser.content;

    final session = ChatSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      messages: List.from(msgs),
      createdAt: DateTime.now(),
    );

    final updated = [session, ..._currentSessions];
    await _saveSessionsLocal(updated);

    if (state is ChatLoaded) {
      emit((state as ChatLoaded).copyWith(sessions: updated));
    }
  }



  Future<void> loadChatHistory() async {
    emit(ChatLoading());
    try {
      final headers = await _authHeaders;

      final response = await _dio.get(
        '${ApiUrlHelper.apiBase}Chat',
        queryParameters: {'page': 1, 'pageSize': 50},
        options: Options(headers: headers),
      );

      final raw = response.data;
      final List<dynamic> list = raw is List ? raw : [];
      final messages = list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();

      // Load locally saved sessions
      final sessions = await _loadSessionsLocal();

      emit(
        ChatLoaded(messages: messages, isSending: false, sessions: sessions),
      );
    } on DioException catch (e) {
      emit(ChatError(e.message ?? 'Failed to load chat history'));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final previousMessages = List<ChatMessage>.from(_currentMessages);

    final userMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    emit(
      ChatLoaded(
        messages: [...previousMessages, userMessage],
        isSending: true,
        sessions: _currentSessions,
      ),
    );

    try {
      final response = await _dio.post(
        '${ApiUrlHelper.apiBase}Chat',
        data: {'message': content.trim()},
        options: Options(headers: await _authHeaders),
      );

      final raw = response.data;
      ChatMessage? botMessage;

      if (raw is Map<String, dynamic>) {
        final hasRole = raw.containsKey('role');
        final hasId = raw.containsKey('id');

        if (hasRole || hasId) {
          botMessage = ChatMessage.fromJson(raw);
        } else {
          final text =
              (raw['response'] as String?) ??
              (raw['reply'] as String?) ??
              (raw['content'] as String?) ??
              (raw['message'] as String?);

          if (text != null && text.isNotEmpty) {
            botMessage = ChatMessage(
              id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
              content: text,
              isUser: false,
              timestamp: DateTime.now(),
            );
          }
        }
      } else if (raw is List && raw.isNotEmpty) {
        final all = raw
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList();
        final assistants = all.where((m) => !m.isUser).toList();
        botMessage = assistants.isNotEmpty ? assistants.last : null;
      } else if (raw is String && raw.isNotEmpty) {
        botMessage = ChatMessage(
          id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
          content: raw,
          isUser: false,
          timestamp: DateTime.now(),
        );
      }

      emit(
        ChatLoaded(
          messages: [
            ...previousMessages,
            userMessage,
            if (botMessage != null && !botMessage.isUser) botMessage,
          ],
          isSending: false,
          sessions: _currentSessions,
        ),
      );
    } on DioException catch (e) {
      emit(
        ChatLoaded(
          messages: previousMessages,
          isSending: false,
          sessions: _currentSessions,
          errorMessage: e.message ?? 'Failed to send message',
        ),
      );
    } catch (e) {
      emit(
        ChatLoaded(
          messages: previousMessages,
          isSending: false,
          sessions: _currentSessions,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  

  Future<void> newSession() async {
    await _archiveCurrentSession();

    try {
      await _dio.post(
        '${ApiUrlHelper.apiBase}Chat/new-session',
        options: Options(headers: await _authHeaders),
      );
    } catch (_) {
    }

    emit(
      ChatLoaded(
        messages: const [],
        isSending: false,
        sessions: _currentSessions,
      ),
    );
  }



  void loadSession(ChatSession session) {
    emit(
      ChatLoaded(
        messages: List.from(session.messages),
        isSending: false,
        sessions: _currentSessions,
      ),
    );
  }



  Future<void> deleteSession(String sessionId) async {
    final updated = _currentSessions.where((s) => s.id != sessionId).toList();
    await _saveSessionsLocal(updated);
    emit((state as ChatLoaded).copyWith(sessions: updated));
  }



  Future<void> clearChat() async {
    final previous = List<ChatMessage>.from(_currentMessages);
    final previousSessions = List<ChatSession>.from(_currentSessions);

    // Optimistic clear
    emit(const ChatLoaded(messages: [], isSending: false, sessions: []));

    try {
      await _dio.delete(
        '${ApiUrlHelper.apiBase}Chat/clear',
        options: Options(headers: await _authHeaders),
      );
      // Also wipe local sessions
      await _saveSessionsLocal([]);
    } on DioException catch (_) {
      // Restore on failure
      emit(
        ChatLoaded(
          messages: previous,
          isSending: false,
          sessions: previousSessions,
        ),
      );
    }
  }



  void dismissError() {
    if (state is ChatLoaded) {
      emit((state as ChatLoaded).copyWith(clearError: true));
    }
  }
}
