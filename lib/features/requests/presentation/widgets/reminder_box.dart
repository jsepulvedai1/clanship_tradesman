import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';

class ReminderBox extends StatelessWidget {
  const ReminderBox({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final tips = [
      l10n.requestReminderTip1,
      l10n.requestReminderTip2,
      l10n.requestReminderTip3,
      l10n.requestReminderTip4,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF332B1A) : const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.orange.withAlpha(50) : Colors.orange.withAlpha(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
              const SizedBox(width: 12),
              Text(
                l10n.requestReminderTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.orange[200] : Colors.orange[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  tip,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
