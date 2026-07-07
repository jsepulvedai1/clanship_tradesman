import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import '../../domain/entities/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isMe = message.isMe;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: message.type == ChatMessageType.appointment
                ? _buildAppointmentCard(context, isDark)
                : _buildTextBubble(isDark),
          ),
          const SizedBox(width: 8),
          if (isMe) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildTextBubble(bool isDark) {
    final bool isMe = message.isMe;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe 
            ? (isDark ? Colors.white.withAlpha(20) : Colors.white)
            : (isDark ? Colors.blueGrey[800] : Colors.grey[200]),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 0),
          bottomRight: Radius.circular(isMe ? 0 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 0 : 5),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, bool isDark) {
    final bool isMe = message.isMe;
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.blueGrey[900] : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 0),
          bottomRight: Radius.circular(isMe ? 0 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                message.appointmentDate ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                message.appointmentTime ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Text(
             '${message.appointmentPrice ?? ''} CLP',
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: message.profileImageUrl != null
            ? DecorationImage(
                image: NetworkImage(message.profileImageUrl!),
                fit: BoxFit.cover,
              )
            : null,
        color: Colors.grey[300],
      ),
      child: message.profileImageUrl == null 
          ? const Icon(Icons.person, size: 24, color: Colors.white)
          : null,
    );
  }
}
