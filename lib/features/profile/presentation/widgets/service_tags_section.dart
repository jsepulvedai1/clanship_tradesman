import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';

class ServiceTagsSection extends StatelessWidget {
  final List<String> tags;
  final String? primaryTag;
  final VoidCallback? onSearchTap;
  final Function(String tag)? onDeleteTap;
  final Function(String tag)? onPrimaryTap;

  const ServiceTagsSection({
    super.key,
    required this.tags,
    this.primaryTag,
    this.onSearchTap,
    this.onDeleteTap,
    this.onPrimaryTap,
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
      ),
    );
  }
}

class _ServiceTag extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onDelete;

  const _ServiceTag({
    required this.label,
    this.isPrimary = false,
    this.onPrimaryTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPrimaryTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryAzure : AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? Border.all(color: AppColors.starGold, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPrimary ? Icons.star : Icons.sell_outlined,
              color: isPrimary ? AppColors.starGold : Colors.white,
              size: 14,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close, color: Colors.white70, size: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
