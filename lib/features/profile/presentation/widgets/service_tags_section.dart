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
            Text(
              l10n.profileServiceTags,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map((tag) => _ServiceTag(
                        label: tag,
                        isPrimary: tag == primaryTag,
                        onPrimaryTap: onPrimaryTap != null ? () => onPrimaryTap!(tag) : null,
                        onDelete: onDeleteTap != null ? () => onDeleteTap!(tag) : null,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            // Sección de agregar más
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(5) : AppColors.lightGrey.withAlpha(100),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                   Text(
                    l10n.profileAddServiceTag,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: onSearchTap,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? Colors.white.withAlpha(100) : Colors.black.withAlpha(100),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text(
                      l10n.profileSearchTags,
                      style: TextStyle(
                        color: isDark ? Colors.white.withAlpha(150) : Colors.black.withAlpha(150),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.profileMaxTagsHint,
                    style: TextStyle(
                      fontSize: 12,
                      color: (isDark ? Colors.white : Colors.black).withAlpha(100),
                    ),
                  ),
                ],
              ),
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
                child: const Icon(
                  Icons.close,
                  color: Colors.white70,
                  size: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
