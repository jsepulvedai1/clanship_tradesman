import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/settings/presentation/pages/associate_code_page.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';

class AssociateCodeBanner extends StatelessWidget {
  final String referralCode;
  final int pendingCount;
  final int targetCount;
  final String? customTitle;
  final String? customSubtitle;
  final String? customShareMessage;
  final bool hasReachedMaxRewards;
  final int rewardsEarnedCount;
  final int maxRewardsPerUser;

  const AssociateCodeBanner({
    super.key,
    required this.referralCode,
    this.pendingCount = 0,
    this.targetCount = 5,
    this.customTitle,
    this.customSubtitle,
    this.customShareMessage,
    this.hasReachedMaxRewards = false,
    this.rewardsEarnedCount = 0,
    this.maxRewardsPerUser = 1,
  });

  void _copyToClipboard(BuildContext context, String code, String message) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safeTarget = targetCount > 0 ? targetCount : 5;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AssociateCodePage()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryAzure.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAzure.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.card_giftcard_rounded,
                        color: AppColors.primaryAzure,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                customTitle ?? l10n.associateCodeTitle,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.textDark,
                                ),
                              ),
                              if (hasReachedMaxRewards) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.successGreen.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    l10n.associateCodeMaxReachedBadge,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.successGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            hasReachedMaxRewards
                                ? l10n.associateCodeMaxRewardsReached
                                : (customSubtitle ?? 'Invita $safeTarget asociados y gana un plan gratis'),
                            style: TextStyle(
                              fontSize: 12,
                              color: (isDark ? Colors.white : AppColors.textDark).withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : AppColors.smokeWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          referralCode,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: AppColors.primaryAzure,
                          ),
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        icon: Icon(Icons.copy_rounded, size: 18, color: AppColors.primaryAzure),
                        tooltip: l10n.associateCodeCopy,
                        onPressed: () => _copyToClipboard(
                          context,
                          referralCode,
                          l10n.associateCodeCopied,
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        icon: Icon(Icons.share_rounded, size: 18, color: AppColors.primaryBlue),
                        tooltip: l10n.associateCodeShare,
                        onPressed: () async {
                          final shareText = customShareMessage != null
                              ? customShareMessage!.replaceAll('{code}', referralCode)
                              : l10n.associateCodeShareMessage(referralCode);
                          try {
                            await SharePlus.instance.share(
                              ShareParams(
                                text: shareText,
                                subject: 'Únete a Clanship con mi código de asociado',
                              ),
                            );
                          } catch (_) {
                            if (context.mounted) {
                              _copyToClipboard(
                                context,
                                referralCode,
                                l10n.associateCodeCopied,
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
