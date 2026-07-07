import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onMic;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onMic,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(10) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: '',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic_none_rounded, color: AppColors.primaryBlue),
                      onPressed: onMic,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue,
                ),
                child: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
