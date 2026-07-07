import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';

class ChatActionButtons extends StatelessWidget {
  final VoidCallback onSchedule;
  final VoidCallback onBack;
  final VoidCallback onReject;

  const ChatActionButtons({
    super.key,
    required this.onSchedule,
    required this.onBack,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              text: 'Agendar',
              color: AppColors.primaryBlue,
              textColor: Colors.white,
              onTap: onSchedule,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              text: 'Regresar',
              color: Colors.white,
              textColor: AppColors.primaryBlue,
              isOutline: true,
              onTap: onBack,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              text: 'Rechazar',
              color: const Color(0xFFFF4B6E),
              textColor: Colors.white,
              onTap: onReject,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final bool isOutline;

  const _ActionButton({
    required this.text,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isOutline ? (isDark ? Colors.transparent : Colors.white) : color,
          borderRadius: BorderRadius.circular(24),
          border: isOutline ? Border.all(color: AppColors.primaryBlue.withAlpha(50)) : null,
          boxShadow: [
            if (!isOutline && !isDark)
              BoxShadow(
                color: color.withAlpha(40),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
