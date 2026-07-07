import 'package:equatable/equatable.dart';
import 'package:clanship_mobile_tradesman/features/chat/domain/entities/chat_message.dart';

abstract class ChatMessagesState extends Equatable {
  const ChatMessagesState();

  @override
  List<Object?> get props => [];
}

class ChatMessagesInitial extends ChatMessagesState {}

class ChatMessagesLoading extends ChatMessagesState {}

class ChatMessagesLoaded extends ChatMessagesState {
  final List<ChatMessage> messages;

  const ChatMessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatMessagesError extends ChatMessagesState {
  final String message;

  const ChatMessagesError(this.message);

  @override
  List<Object?> get props => [message];
}
