import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';

class AvailabilityWidget extends StatelessWidget {
  final bool isAvailable;
  final ValueChanged<bool> onToggle;

  const AvailabilityWidget({
    super.key,
    required this.isAvailable,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 750;
    final Color activeColor = const Color(0xFF0B6E4F); // Verde esmeralda
    final Color inactiveColor = Colors.grey;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isSmallScreen ? 10 : 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icono circular a la izquierda
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
              decoration: BoxDecoration(
                color: (isAvailable ? activeColor : inactiveColor).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/icon/icons_ F28C28/dialog.svg',
                width: isSmallScreen ? 16 : 20,
                height: isSmallScreen ? 16 : 20,
                colorFilter: ColorFilter.mode(
                  isAvailable ? activeColor : inactiveColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            // Texto descriptivo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.homeAvailabilityTitle,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E3135),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    l10n.homeAvailabilitySubtitle,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 11,
                      color: const Color(0xFF2E3135).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Switch adaptativo
            Switch.adaptive(
              value: isAvailable,
              onChanged: onToggle,
              activeColor: activeColor,
              activeTrackColor: activeColor.withValues(alpha: 0.3),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
