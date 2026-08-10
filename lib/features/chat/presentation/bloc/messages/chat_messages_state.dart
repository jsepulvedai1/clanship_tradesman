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
  final String? jobStatus;
  final String? cancellationReason;

  const ChatMessagesLoaded(this.messages, {this.jobStatus, this.cancellationReason});

  @override
  List<Object?> get props => [messages, jobStatus, cancellationReason];
}

class ChatMessagesError extends ChatMessagesState {
  final String message;

  const ChatMessagesError(this.message);

  @override
  List<Object?> get props => [message];
}
