import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
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
            value: active.toString(),
            label: l10n.homeStatsActive,
            valueColor: const Color(0xFF2E3135), // Gris grafito
            onTap: onActiveTap,
            hasHighlight: hasUnread,
            iconColor: const Color(0xFF2E3135),
            showChevron: false,
            chevronColor: const Color(0xFF2E3135),
            svgIconPath: 'assets/icon/icons_ F28C28/document-add.svg',
          ),
          StatCard(
            value: completed.toString(),
            label: l10n.homeStatsCompleted,
            valueColor: const Color(0xFF0B6E4F), // Verde esmeralda
            onTap: onCompletedTap,
            iconColor: const Color(0xFF0B6E4F),
            showChevron: true,
            chevronColor: const Color(0xFF0B6E4F),
            svgIconPath: 'assets/icon/icons_ F28C28/document-add.svg',
          ),
          StatCard(
            value: rejected.toString(),
            label: l10n.homeStatsRejected,
            valueColor: const Color(0xFFEA4335), // Rojo
            onTap: onRejectedTap,
            iconColor: const Color(0xFFEA4335),
            showChevron: true,
            chevronColor: const Color(0xFFEA4335),
            svgIconPath: 'assets/icon/icons_ F28C28/document-add.svg',
          ),
          StatCard(
            value: scheduled.toString(),
            label: l10n.homeStatsScheduled,
            valueColor: hasScheduledUnread ? const Color(0xFFEF4444) : const Color(0xFFF28C28),
            onTap: onScheduledTap,
            hasHighlight: hasScheduledUnread,
            iconColor: hasScheduledUnread ? const Color(0xFFEF4444) : const Color(0xFFF28C28),
            showChevron: true,
            chevronColor: hasScheduledUnread ? const Color(0xFFEF4444) : const Color(0xFFF28C28),
            svgIconPath: 'assets/icon/icons_ F28C28/document-add.svg',
          ),
        ],
      ),
    );
  }
}
