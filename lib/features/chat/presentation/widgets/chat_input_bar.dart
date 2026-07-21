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

    const Color brandGreen = AppColors.primaryAzure; 
    final Color plusBgColor = isDark
        ? const Color(0xFF1E2D27)
        : const Color(0xFFF1F7F4);
    final Color barBgColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF8FAF9);

    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 10,
        bottom: 10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: barBgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 10),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            // Left (+) Attachment Button
            GestureDetector(
              onTap: onAttachment,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: plusBgColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: brandGreen,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Center Input Field or Recording Text
            Expanded(
              child: isRecording
                  ? Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      child: const Row(
                        children: [
                          Icon(Icons.fiber_manual_record, color: Colors.red, size: 14),
                          SizedBox(width: 8),
                          Text(
                            'Grabando audio...',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: controller,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 4,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white38 : const Color(0xFFB0B0B0),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
            ),

            const SizedBox(width: 10),

            // Right Action Button (Mic / Send / Stop)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                final bool hasText = value.text.trim().isNotEmpty;

                return GestureDetector(
                  onTap: () {
                    if (isRecording) {
                      onStopRecording();
                    } else if (hasText) {
                      onSend();
                    } else {
                      onMic();
                    }
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecording ? Colors.red : brandGreen,
                    ),
                    child: Icon(
                      isRecording
                          ? Icons.stop_rounded
                          : (hasText ? Icons.send_rounded : Icons.mic_rounded),
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

