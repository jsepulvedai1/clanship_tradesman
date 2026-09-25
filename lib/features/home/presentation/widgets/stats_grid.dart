import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/theme/bloc/seasonal_theme_bloc.dart';
import 'package:clanship_mobile_tradesman/core/utils/tutorial_keys.dart';
import 'stat_card.dart';

class StatsGrid extends StatelessWidget {
  final int active;
  final int completed;
  final int rejected;
  final int scheduled;
  final bool hasUnread;
  final bool hasScheduledUnread;
  final VoidCallback? onActiveTap;
  final VoidCallback? onCompletedTap;
  final VoidCallback? onScheduledTap;
  final VoidCallback? onRejectedTap;

  const StatsGrid({
    super.key,
    required this.active,
    required this.completed,
    required this.rejected,
    required this.scheduled,
    this.hasUnread = false,
    this.hasScheduledUnread = false,
    this.onActiveTap,
    this.onCompletedTap,
    this.onScheduledTap,
    this.onRejectedTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 750;

    final seasonalState = context.watch<SeasonalThemeBloc>().state;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: isSmallScreen ? 8 : 12,
        mainAxisSpacing: isSmallScreen ? 8 : 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: isSmallScreen ? 1.95 : 1.6,
        children: [
          StatCard(
            key: TutorialKeys.homeActiveRequestsKey,
            value: active.toString(),
            label: l10n.homeStatsActive,
            valueColor: seasonalState.statCardActiveNumberColor ?? const Color(0xFF2E3135),
            labelColor: seasonalState.statCardActiveTextColor,
            onTap: onActiveTap,
            hasHighlight: hasUnread,
            iconColor: seasonalState.statCardActiveIconColor ?? const Color(0xFF2E3135),
            showChevron: false,
            chevronColor: seasonalState.statCardActiveIconColor ?? const Color(0xFF2E3135),
            svgIconPath: 'assets/icon/icons_ F28C28/document-add.svg',
            backgroundColor: seasonalState.statCardActiveBgColor,
            bgImageUrl: seasonalState.statCardActiveBgImageUrl,
            imageOpacity: seasonalState.statCardActiveImageOpacity,
          ),
          StatCard(
            key: TutorialKeys.homeCompletedRequestsKey,
            value: completed.toString(),
            label: l10n.homeStatsCompleted,
            valueColor: seasonalState.statCardCompletedNumberColor ?? const Color(0xFF0B6E4F),
            labelColor: seasonalState.statCardCompletedTextColor,
            onTap: onCompletedTap,
            iconColor: seasonalState.statCardCompletedIconColor ?? const Color(0xFF0B6E4F),
            showChevron: true,
            chevronColor: seasonalState.statCardCompletedIconColor ?? const Color(0xFF0B6E4F),
            svgIconPath: 'assets/icon/icons_ F28C28/document-add.svg',
            backgroundColor: seasonalState.statCardCompletedBgColor,
            bgImageUrl: seasonalState.statCardCompletedBgImageUrl,
            imageOpacity: seasonalState.statCardCompletedImageOpacity,
          ),
          StatCard(
            value: rejected.toString(),
            label: l10n.homeStatsRejected,
            valueColor: seasonalState.statCardRejectedNumberColor ?? const Color(0xFFEA4335),
            labelColor: seasonalState.statCardRejectedTextColor,
            onTap: onRejectedTap,
            iconColor: seasonalState.statCardRejectedIconColor ?? const Color(0xFFEA4335),
            showChevron: true,
            chevronColor: seasonalState.statCardRejectedIconColor ?? const Color(0xFFEA4335),
            svgIconPath: 'assets/icon/icons_ F28C28/document-add.svg',
            backgroundColor: seasonalState.statCardRejectedBgColor,
            bgImageUrl: seasonalState.statCardRejectedBgImageUrl,
            imageOpacity: seasonalState.statCardRejectedImageOpacity,
          ),
          StatCard(
            key: TutorialKeys.homeScheduledRequestsKey,
            value: scheduled.toString(),
            label: l10n.homeStatsScheduled,
            valueColor: seasonalState.statCardScheduledNumberColor ??
                (hasScheduledUnread ? const Color(0xFFEF4444) : const Color(0xFFF28C28)),
            labelColor: seasonalState.statCardScheduledTextColor,
            onTap: onScheduledTap,
            hasHighlight: hasScheduledUnread,
            iconColor: seasonalState.statCardScheduledIconColor ??
                (hasScheduledUnread ? const Color(0xFFEF4444) : const Color(0xFFF28C28)),
            showChevron: true,
            chevronColor: seasonalState.statCardScheduledIconColor ??
                (hasScheduledUnread ? const Color(0xFFEF4444) : const Color(0xFFF28C28)),
            svgIconPath: 'assets/icon/icons_ F28C28/document-add.svg',
            backgroundColor: seasonalState.statCardScheduledBgColor,
            bgImageUrl: seasonalState.statCardScheduledBgImageUrl,
            imageOpacity: seasonalState.statCardScheduledImageOpacity,
          ),
        ],
      ),
    );
  }
}
