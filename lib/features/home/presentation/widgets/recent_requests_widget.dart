import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/job_request_entity.dart';

class RecentRequestsWidget extends StatelessWidget {
  final List<JobRequestEntity> requests;
  final Function(JobRequestEntity) onRequestTap;

  const RecentRequestsWidget({
    super.key,
    required this.requests,
    required this.onRequestTap,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.pureWhite,
          borderRadius: BorderRadius.circular(20),
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
        padding: const EdgeInsets.all(20),
        // child: Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     Text(
        //       l10n.homeRecentRequestsTitle,
        //       style: const TextStyle(
        //         fontSize: 16,
        //         fontWeight: FontWeight.bold,
        //       ),
        //     ),
        //     const SizedBox(height: 16),
        //     ...requests.map((request) => _RequestItem(
        //           request: request,
        //           onRequestTap: () => onRequestTap(request),
        //         )),
        //   ],
        // ),
      ),
    );
  }
}

class _RequestItem extends StatelessWidget {
  final JobRequestEntity request;
  final VoidCallback onRequestTap;

  const _RequestItem({required this.request, required this.onRequestTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withAlpha(10)
            : AppColors.lightGrey.withAlpha(150),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            request.description,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.pureWhite.withAlpha(180)
                  : AppColors.trueBlack.withAlpha(180),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onRequestTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                l10n.homeGoToRequestAction,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
