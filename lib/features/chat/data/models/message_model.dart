import 'package:clanship_mobile_tradesman/features/chat/domain/entities/chat_message.dart';
import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  final String id;
  final String text;
  final DateTime createdAt;
  final int senderId;
  final String senderUsername;
  final bool isSystem;

  const MessageModel({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.senderId,
    required this.senderUsername,
    this.isSystem = false,
  });

  factory MessageModel.fromJsonGraphql(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'].toString(),
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      senderId: int.parse(json['sender']['id'].toString()),
      senderUsername: json['sender']['username'] as String,
      isSystem: false, // GraphQL doesn't seem to expose this in the query based on the info
    );
  }

  factory MessageModel.fromJsonWebSocket(Map<String, dynamic> json) {
    return MessageModel(
      // The websocket might not send a message ID for new messages immediately, or it might.
      // We generate a temporary one if it doesn't exist.
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['message'] as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      senderId: int.parse(json['sender_id'].toString()),
      senderUsername: json['sender_username'] as String,
      isSystem: json['system'] as bool? ?? false,
    );
  }

  ChatMessage toEntity(int currentUserId) {
    return ChatMessage(
      id: id,
      text: text,
      timestamp: createdAt,
      isMe: senderId == currentUserId,
      profileImageUrl: 'https://i.pravatar.cc/150?u=$senderId', // Temporary placeholder
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        createdAt,
        senderId,
        senderUsername,
        isSystem,
      ];
}
