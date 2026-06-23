import 'package:equatable/equatable.dart';
import 'chat_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

/// Single source of truth — messages live HERE, not in the cubit field.
class ChatLoaded extends ChatState {
  const ChatLoaded({
    required this.messages,
    required this.isSending,
    this.errorMessage,
  });

  final List<ChatMessage> messages;

  /// True while waiting for the assistant response (shows typing indicator).
  final bool isSending;

  /// Non-null when the last send failed (show a banner but keep messages).
  final String? errorMessage;

  @override
  List<Object?> get props => [messages, isSending, errorMessage];

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? errorMessage,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage, // null clears the banner
    );
  }
}

class ChatError extends ChatState {
  const ChatError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
