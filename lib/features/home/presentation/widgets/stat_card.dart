import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final VoidCallback? onTap;
  final bool hasHighlight;
  final String svgIconPath;
  final Color iconColor;
  final bool showChevron;
  final Color chevronColor;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
    this.onTap,
    this.hasHighlight = false,
    this.svgIconPath = 'assets/icon/icons_ F28C28/document-add.svg',
    required this.iconColor,
    this.showChevron = false,
    required this.chevronColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    if (hasHighlight) {
      cardColor = isDark
          ? const Color(0xFF0D2B45).withValues(alpha: 0.2)
          : const Color(0xFF0D2B45).withValues(alpha: 0.05);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasHighlight
                ? const Color(0xFF0D2B45).withValues(alpha: 0.2)
                : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            // Icono con círculo de fondo
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                svgIconPath,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 12),
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF2E3135),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            if (showChevron) ...[
              Icon(Icons.arrow_forward_ios, size: 12, color: chevronColor),
            ],
          ],
        ),
      ),
    );
  }
}
