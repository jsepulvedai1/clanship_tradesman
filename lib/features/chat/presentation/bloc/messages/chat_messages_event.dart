import 'package:equatable/equatable.dart';
import 'package:clanship_mobile_tradesman/features/chat/domain/entities/chat_message.dart';

abstract class ChatMessagesEvent extends Equatable {
  const ChatMessagesEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatMessages extends ChatMessagesEvent {
  final String roomId;
  final int currentUserId;

  const LoadChatMessages(this.roomId, this.currentUserId);

  @override
  List<Object?> get props => [roomId, currentUserId];
}

class SendMessage extends ChatMessagesEvent {
  final String roomId;
  final String text;
  final String? fileBase64;
  final String? fileName;
  final String? messageType;

  const SendMessage(
    this.roomId, 
    this.text, {
    this.fileBase64,
    this.fileName,
    this.messageType,
  });

  @override
  List<Object?> get props => [roomId, text, fileBase64, fileName, messageType];
}

class MessageReceived extends ChatMessagesEvent {
  final ChatMessage message;

  const MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class CloseChatConnection extends ChatMessagesEvent {}
