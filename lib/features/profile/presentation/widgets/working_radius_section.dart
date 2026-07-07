import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';

class WorkingRadiusSection extends StatefulWidget {
  final double initialRadius;
  final ValueChanged<double>? onRadiusChanged;

  const WorkingRadiusSection({
    super.key,
    this.initialRadius = 1.0,
    this.onRadiusChanged,
  });

  @override
  State<WorkingRadiusSection> createState() => _WorkingRadiusSectionState();
}

class _WorkingRadiusSectionState extends State<WorkingRadiusSection> {
  late double _currentRadius;

  @override
  void initState() {
    super.initState();
    _currentRadius = widget.initialRadius;
  }

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
            color: isDark
                ? AppColors.pureWhite.withAlpha(20)
                : AppColors.trueBlack.withAlpha(20),
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
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.primaryAzure.withValues(alpha: 0.18)
                        : AppColors.primaryAzure.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primaryAzure,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.profileWorkingRadiusTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.profileWorkingRadiusSubtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white54
                              : AppColors.textDark.withValues(alpha: 0.7),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  l10n.profileDistance,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _currentRadius.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryAzure,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.profileKm,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 12,
                activeTrackColor: AppColors.primaryAzure,
                inactiveTrackColor: isDark
                    ? AppColors.pureWhite.withValues(alpha: 0.12)
                    : AppColors.textDark.withValues(alpha: 0.12),
                thumbColor: Colors.white,
                overlayColor: AppColors.primaryAzure.withValues(alpha: 0.15),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 10,
                  elevation: 4,
                ),
                trackShape: const RoundedRectSliderTrackShape(),
              ),
              child: Slider(
                value: _currentRadius,
                min: 1,
                max: 50,
                onChanged: (value) {
                  setState(() {
                    _currentRadius = value;
                  });
                },
                onChangeEnd: (value) {
                  widget.onRadiusChanged?.call(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
