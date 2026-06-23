// ignore: unused_import
import 'package:equatable/equatable.dart';
import 'chat_model.dart';

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatError extends ChatState {
  const ChatError(this.message);
  final String message;
}

class ChatLoaded extends ChatState { 

  const ChatLoaded({
    required this.messages,
    required this.isSending,
    this.errorMessage,
    this.sessions = const [],
  });
  final List<ChatMessage> messages;
  final bool isSending;
  final String? errorMessage;
  final List<ChatSession> sessions;

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? errorMessage,
    List<ChatSession>? sessions,
    bool clearError = false,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sessions: sessions ?? this.sessions,
    );
  }
}
