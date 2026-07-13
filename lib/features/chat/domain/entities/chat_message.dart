import 'package:equatable/equatable.dart';

enum ChatMessageType { text, appointment, image, audio }

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final String? profileImageUrl;
  final ChatMessageType type;
  final String? appointmentDate;
  final String? appointmentTime;
  final String? appointmentPrice;
  final String? fileUrl;

  const ChatMessage({
    required this.id,
    this.text = '',
    required this.timestamp,
    required this.isMe,
    this.profileImageUrl,
    this.type = ChatMessageType.text,
    this.appointmentDate,
    this.appointmentTime,
    this.appointmentPrice,
    this.fileUrl,
  });

  @override
  List<Object?> get props => [
        id,
        text,
        timestamp,
        isMe,
        profileImageUrl,
        type,
        appointmentDate,
        appointmentTime,
        appointmentPrice,
        fileUrl,
      ];
}
