import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/core/theme/widgets/seasonal_top_garland.dart';
import 'package:clanship_mobile_tradesman/core/theme/widgets/seasonal_particles.dart';

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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.90,
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: isSmallScreen ? 10 : 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: SeasonalParticlesOverlay(height: 100),
                ),
                Row(
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
                              color: AppColors.accentCyan,
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
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: const SeasonalTopGarland(
                height: 22,
                slot: GarlandSlot.bottom,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
