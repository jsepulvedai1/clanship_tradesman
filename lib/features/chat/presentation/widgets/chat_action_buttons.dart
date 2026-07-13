import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';

class ChatActionButtons extends StatelessWidget {
  final VoidCallback onSchedule;
  final VoidCallback onBack;
  final VoidCallback onReject;
  final VoidCallback? onAccept;

  const ChatActionButtons({
    super.key,
    required this.onSchedule,
    required this.onBack,
    required this.onReject,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              text: onAccept != null ? 'Agendar' : 'Regresar',
              color: onAccept != null ? AppColors.primaryBlue : Colors.white,
              textColor: onAccept != null
                  ? Colors.white
                  : AppColors.primaryBlue,
              isOutline: onAccept != null ? false : true,
              onTap: onAccept != null ? onSchedule : onBack,
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
          color: isOutline
              ? (isDark ? Colors.transparent : Colors.white)
              : color,
          borderRadius: BorderRadius.circular(24),
          border: isOutline
              ? Border.all(color: AppColors.primaryBlue.withAlpha(50))
              : null,
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
