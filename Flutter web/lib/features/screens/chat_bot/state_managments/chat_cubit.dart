import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/helpers/api_url_helper.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';
import 'chat_model.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({Dio? dio}) : _dio = dio ?? Dio(), super(ChatInitial());

  final Dio _dio;

  // ── helpers ──────────────────────────────────────────────────────────────

  Future<Map<String, String>> get _authHeaders async {
    final token = await TokenStorageHelper.getTokenSecure();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  List<ChatMessage> get _currentMessages =>
      state is ChatLoaded ? (state as ChatLoaded).messages : [];

  // ── load history ──────────────────────────────────────────────────────────

  Future<void> loadChatHistory() async {
    emit(ChatLoading());
    try {
      final response = await _dio.get(
        '${ApiUrlHelper.apiBase}Chat',
        queryParameters: {'page': 1, 'pageSize': 50},
        options: Options(headers: await _authHeaders),
      );

      final raw = response.data;
      final List<dynamic> list = raw is List ? raw : [];

      final messages = list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();

      emit(ChatLoaded(messages: messages, isSending: false));
    } on DioException catch (e) {
      emit(ChatError(e.message ?? 'Failed to load chat history'));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  // ── send message ──────────────────────────────────────────────────────────

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Snapshot BEFORE optimistic update
    final previousMessages = List<ChatMessage>.from(_currentMessages);

    final userMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    emit(
      ChatLoaded(messages: [...previousMessages, userMessage], isSending: true),
    );

    try {
      final response = await _dio.post(
        '${ApiUrlHelper.apiBase}Chat',
        data: {'message': content.trim()},
        options: Options(headers: await _authHeaders),
      );

      final raw = response.data;

      // DEBUG — remove after confirming fix
      // ignore: avoid_print
      print('=== CHAT SEND RESPONSE ===');
      // ignore: avoid_print
      print('type: ${raw.runtimeType}  data: $raw');

      ChatMessage? botMessage;

      if (raw is Map<String, dynamic>) {
        // Check if it's a wrapper like { "message": "...", "role": "..." }
        // or { "reply": "..." } or { "response": "..." }
        final hasRole = raw.containsKey('role');
        final hasId = raw.containsKey('id');

        if (hasRole || hasId) {
          // Looks like a full ChatMessage object
          botMessage = ChatMessage.fromJson(raw);
        } else {
          // It's a wrapper — extract the text from any common key
          final text =
              (raw['reply'] as String?) ??
              (raw['response'] as String?) ??
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

      final newMessages = [
        ...previousMessages,
        userMessage,
        if (botMessage != null && !botMessage.isUser) botMessage,
      ];

      emit(ChatLoaded(messages: newMessages, isSending: false));
    } on DioException catch (e) {
      emit(
        ChatLoaded(
          messages: previousMessages,
          isSending: false,
          errorMessage: e.message ?? 'Failed to send message',
        ),
      );
    } catch (e) {
      emit(
        ChatLoaded(
          messages: previousMessages,
          isSending: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ── new session ───────────────────────────────────────────────────────────

  Future<void> newSession() async {
    emit(ChatLoading());
    try {
      await _dio.post(
        '${ApiUrlHelper.apiBase}Chat/new-session',
        options: Options(headers: await _authHeaders),
      );
      // After creating a new session, start with empty messages
      emit(const ChatLoaded(messages: [], isSending: false));
    } on DioException catch (e) {
      emit(ChatError(e.message ?? 'Failed to create new session'));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  // ── dismiss error banner ──────────────────────────────────────────────────

  void dismissError() {
    if (state is ChatLoaded) {
      final s = state as ChatLoaded;
      emit(ChatLoaded(messages: s.messages, isSending: s.isSending));
    }
  }

  // ── clear (DELETE /api/Chat/clear) ────────────────────────────────────────

  Future<void> clearChat() async {
    final previous = List<ChatMessage>.from(_currentMessages);
    emit(const ChatLoaded(messages: [], isSending: false));
    try {
      await _dio.delete(
        '${ApiUrlHelper.apiBase}Chat/clear',
        options: Options(headers: await _authHeaders),
      );
    } on DioException catch (_) {
      // Restore messages if API call fails
      emit(ChatLoaded(messages: previous, isSending: false));
    }
  }
}
