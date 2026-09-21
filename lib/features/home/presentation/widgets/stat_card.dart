import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  final Color? backgroundColor;
  final String? bgImageUrl;
  final Color? labelColor;
  final double? imageOpacity;

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
    this.backgroundColor,
    this.bgImageUrl,
    this.labelColor,
    this.imageOpacity,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 750;

    Color cardColor = backgroundColor ?? (isDark ? const Color(0xFF1E293B) : Colors.white);
    if (hasHighlight) {
      cardColor = isDark
          ? const Color(0xFF0D2B45).withValues(alpha: 0.2)
          : const Color(0xFF0D2B45).withValues(alpha: 0.05);
    }

    final bool isBackgroundDark = isDark || (backgroundColor != null && backgroundColor!.computeLuminance() < 0.45);
    final Color defaultLabelColor = isBackgroundDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF2E3135);
    final Color effectiveLabelColor = labelColor ?? defaultLabelColor;
    final Color effectiveValueColor = (isBackgroundDark && valueColor == const Color(0xFF2E3135))
        ? Colors.white
        : valueColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasHighlight
                ? const Color(0xFF0D2B45).withValues(alpha: 0.2)
                : (backgroundColor != null
                    ? backgroundColor!.withValues(alpha: 0.4)
                    : const Color(0xFFE2E8F0)),
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
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (bgImageUrl != null && bgImageUrl!.isNotEmpty) ...[
              Positioned.fill(
                child: Opacity(
                  opacity: (imageOpacity ?? 0.25).clamp(0.0, 1.0),
                  child: CachedNetworkImage(
                    imageUrl: bgImageUrl!,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 150),
                    fadeOutDuration: const Duration(milliseconds: 100),
                    placeholder: (context, url) => const SizedBox.shrink(),
                    errorWidget: (context, url, error) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: isSmallScreen ? 8 : 12,
              ),
              child: Row(
                children: [
                  // Icono con círculo de fondo
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: isBackgroundDark ? 0.2 : 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      svgIconPath,
                      width: isSmallScreen ? 16 : 20,
                      height: isSmallScreen ? 16 : 20,
                      colorFilter: ColorFilter.mode(
                        isBackgroundDark && iconColor == const Color(0xFF2E3135)
                            ? Colors.white
                            : iconColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  // Textos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            color: effectiveValueColor,
                            fontSize: isSmallScreen ? 18 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: TextStyle(
                            color: effectiveLabelColor,
                            fontSize: isSmallScreen ? 9 : 10,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showChevron) ...[
                    Icon(
                      Icons.arrow_forward_ios,
                      size: isSmallScreen ? 10 : 12,
                      color: isBackgroundDark && chevronColor == const Color(0xFF2E3135)
                          ? Colors.white70
                          : chevronColor,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
