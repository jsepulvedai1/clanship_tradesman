import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';

class ActionButtonsSection extends StatelessWidget {
  final VoidCallback onChatTap;
  final VoidCallback onGoogleMapsTap;
  final VoidCallback onWazeTap;

  const ActionButtonsSection({
    super.key,
    required this.onChatTap,
    required this.onGoogleMapsTap,
    required this.onWazeTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ir al chat (Large Square)
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: onChatTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 40),
                ),
                child: Text(
                  l10n.requestGoToChat,
                  // In the image it says "Ir al chat".
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Maps & Waze (Internal column)
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _NavButton(
                    label: l10n.requestGoToMaps,
                    onTap: onGoogleMapsTap,
                  ),
                  const SizedBox(height: 12),
                  _NavButton(
                    label: l10n.requestGoToWaze,
                    onTap: onWazeTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
