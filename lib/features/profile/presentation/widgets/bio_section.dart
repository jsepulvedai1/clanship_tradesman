import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';

class BioSection extends StatelessWidget {
  final String biography;
  final double hourlyRate;
  final VoidCallback? onEditTap;

  const BioSection({
    super.key,
    required this.biography,
    required this.hourlyRate,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.pureWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.pureWhite.withAlpha(20) : AppColors.trueBlack.withAlpha(20),
            width: 0.5,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.profileProfessionalProfile,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primaryBlue,
                  ),
                ),
                TextButton(
                  onPressed: onEditTap,
                  child: Text(
                     l10n.profileEdit,
                    style: TextStyle(
                      color: isDark ? AppColors.primaryAzure.withValues(alpha: 0.8) : AppColors.primaryAzure,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              biography.isNotEmpty ? biography : 'Sin biografía aún. Haz clic en Editar para agregar una.',
              style: TextStyle(
                fontSize: 14,
                color: (isDark ? AppColors.pureWhite : AppColors.textDark).withValues(alpha: 0.7),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.monetization_on_outlined,
                  color: AppColors.accentCyan,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tarifa por hora: ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.textDark.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  '\$${hourlyRate.toStringAsFixed(0)} / hr',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentCyan,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
