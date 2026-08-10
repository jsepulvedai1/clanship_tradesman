import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';

class StatsBanner extends StatelessWidget {
  final double rating;
  final int reviewsCount;
  final VoidCallback? onServicesTap;

  const StatsBanner({
    super.key,
    required this.rating,
    required this.reviewsCount,
    this.onSyncTap,
    this.onServicesTap,
  });

  final VoidCallback? onSyncTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 750;

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.90,
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: isSmallScreen ? 10 : 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0D2B45),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D2B45).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // PARTE IZQUIERDA: Calificación
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.homeRatingLabel,
                  style: TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: isSmallScreen ? 13 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 3 : 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: const Color(0xFFF28C28),
                      size: isSmallScreen ? 22 : 28,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString().replaceAll('.', ','),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Text(
                    //   '($reviewsCount ${l10n.homeReviewsText})',
                    //   style: TextStyle(
                    //     color: Colors.white.withAlpha(200),
                    //     fontSize: isSmallScreen ? 11 : 13,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),

            // Línea divisoria vertical blanca
            Container(
              width: 1,
              height: isSmallScreen ? 40 : 55,
              color: Colors.white.withValues(alpha: 0.2),
            ),

            // PARTE DERECHA: Servicios
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onServicesTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.open_in_new_rounded,
                        color: Colors.white,
                        size: isSmallScreen ? 20 : 26,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.homeServicesLink,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 15 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
