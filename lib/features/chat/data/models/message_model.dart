import 'package:clanship_mobile_tradesman/features/chat/domain/entities/chat_message.dart';
import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  final String id;
  final String text;
  final DateTime createdAt;
  final int senderId;
  final String senderUsername;
  final String? senderAvatarUrl;
  final bool isSystem;
  final String? fileUrl;
  final String messageType;

  const MessageModel({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.senderId,
    required this.senderUsername,
    this.senderAvatarUrl,
    this.isSystem = false,
    this.fileUrl,
    this.messageType = 'TEXT',
  });

  factory MessageModel.fromJsonGraphql(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'].toString(),
      text: json['text'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      senderId: int.parse(json['sender']['id'].toString()),
      senderUsername: json['sender']['username'] as String,
      senderAvatarUrl: json['sender']['avatarUrl'] as String?,
      isSystem: false,
      fileUrl: _sanitizeFileUrl(json['fileUrl'] as String?),
      messageType: json['messageType'] as String? ?? 'TEXT',
    );
  }

  factory MessageModel.fromJsonWebSocket(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['message'] as String? ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      senderId: int.parse(json['sender_id'].toString()),
      senderUsername: json['sender_username'] as String,
      senderAvatarUrl: json['sender_avatar_url'] as String?,
      isSystem: json['system'] as bool? ?? false,
      fileUrl: _sanitizeFileUrl(json['file_url'] as String?),
      messageType: json['message_type'] as String? ?? 'TEXT',
    );
  }

  ChatMessage toEntity(int currentUserId) {
    ChatMessageType type = ChatMessageType.text;
    if (messageType == 'IMAGE') {
      type = ChatMessageType.image;
    } else if (messageType == 'AUDIO') {
      type = ChatMessageType.audio;
    }

    return ChatMessage(
      id: id,
      text: text,
      timestamp: createdAt,
      isMe: senderId == currentUserId,
      profileImageUrl: senderAvatarUrl,
      type: type,
      fileUrl: fileUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        createdAt,
        senderId,
        senderUsername,
        senderAvatarUrl,
        isSystem,
        fileUrl,
        messageType,
      ];
}

String? _sanitizeFileUrl(String? url) {
  if (url == null) return null;
  if (url.startsWith('http://') && 
      !url.contains('127.0.0.1') && 
      !url.contains('localhost') && 
      !url.contains('10.0.2.2')) {
    return url.replaceFirst('http://', 'https://');
  }
  return url;
}
