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
  final int unreadActiveCount;
  final int unreadScheduledCount;
  final int openOpportunitiesCount;
  final VoidCallback? onActiveTap;
  final VoidCallback? onCompletedTap;
  final VoidCallback? onScheduledTap;
  final VoidCallback? onRejectedTap;
  final VoidCallback? onCotizacionesTap;

  const StatsGrid({
    super.key,
    required this.active,
    required this.completed,
    required this.rejected,
    required this.scheduled,
    this.unreadActiveCount = 0,
    this.unreadScheduledCount = 0,
    this.openOpportunitiesCount = 0,
    this.onActiveTap,
    this.onCompletedTap,
    this.onScheduledTap,
    this.onRejectedTap,
    this.onCotizacionesTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final seasonalState = context.watch<SeasonalThemeBloc>().state;

    final cards = [
      StatCard(
        key: TutorialKeys.homeActiveRequestsKey,
        value: active.toString(),
        label: l10n.homeStatsActive,
        valueColor: seasonalState.statCardActiveNumberColor ?? const Color(0xFF2E3135),
        labelColor: seasonalState.statCardActiveTextColor,
        onTap: onActiveTap,
        highlightCount: unreadActiveCount,
        iconColor: seasonalState.statCardActiveIconColor ?? const Color(0xFF2E3135),
        showChevron: false,
        chevronColor: seasonalState.statCardActiveIconColor ?? const Color(0xFF2E3135),
        svgIconPath: 'assets/icon/icons_ F28C28/document-add.svg',
        backgroundColor: seasonalState.statCardActiveBgColor,
        bgImageUrl: seasonalState.statCardActiveBgImageUrl,
        imageOpacity: seasonalState.statCardActiveImageOpacity,
      ),
      StatCard(
        value: 'Ver',
        label: 'Cotizaciones',
        valueColor: const Color(0xFF3B82F6),
        labelColor: seasonalState.statCardActiveTextColor,
        onTap: onCotizacionesTap,
        highlightCount: openOpportunitiesCount,
        iconColor: const Color(0xFF3B82F6),
        showChevron: true,
        chevronColor: const Color(0xFF3B82F6),
        svgIconPath: 'assets/icon/icons_ F28C28/document-add.svg',
      ),
      StatCard(
        key: TutorialKeys.homeScheduledRequestsKey,
        value: scheduled.toString(),
        label: l10n.homeStatsScheduled,
        valueColor: seasonalState.statCardScheduledNumberColor ??
            ((unreadScheduledCount > 0) ? const Color(0xFFEF4444) : const Color(0xFFF28C28)),
        labelColor: seasonalState.statCardScheduledTextColor,
        onTap: onScheduledTap,
        highlightCount: unreadScheduledCount,
        iconColor: seasonalState.statCardScheduledIconColor ??
            ((unreadScheduledCount > 0) ? const Color(0xFFEF4444) : const Color(0xFFF28C28)),
        showChevron: true,
        chevronColor: seasonalState.statCardScheduledIconColor ??
            ((unreadScheduledCount > 0) ? const Color(0xFFEF4444) : const Color(0xFFF28C28)),
        svgIconPath: 'assets/icon/icons_ F28C28/document-add.svg',
        backgroundColor: seasonalState.statCardScheduledBgColor,
        bgImageUrl: seasonalState.statCardScheduledBgImageUrl,
        imageOpacity: seasonalState.statCardScheduledImageOpacity,
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
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: cards.map((card) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 4 - 10,
              height: 110,
              child: card,
            ),
          );
        }).toList(),
      ),
    );
  }
}
