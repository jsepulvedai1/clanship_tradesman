import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onMic;
  final VoidCallback onAttachment;
  final bool isRecording;
  final VoidCallback onStopRecording;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onMic,
    required this.onAttachment,
    this.isRecording = false,
    required this.onStopRecording,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAttachment,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(10) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primaryBlue,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(10) : Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: isRecording
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.centerLeft,
                      child: const Row(
                        children: [
                          Icon(Icons.mic, color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Grabando audio...',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: 'Escribe un mensaje...',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.mic_none_rounded,
                            color: AppColors.primaryBlue,
                          ),
                          onPressed: onMic,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: isRecording ? onStopRecording : onSend,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRecording ? Colors.red : AppColors.primaryBlue,
              ),
              child: Icon(
                isRecording
                    ? Icons.stop_rounded
                    : (controller.text.isNotEmpty
                          ? Icons.send_rounded
                          : Icons.arrow_upward_rounded),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
