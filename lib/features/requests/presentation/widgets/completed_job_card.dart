import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import '../../domain/entities/completed_job_entity.dart';

class CompletedJobCard extends StatelessWidget {
  final CompletedJobEntity job;

  const CompletedJobCard({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.category,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _InfoTag(icon: Icons.calendar_today_outlined, text: job.date),
                      const SizedBox(width: 16),
                      _InfoTag(icon: Icons.access_time, text: job.time),
                    ],
                  ),
                ],
              ),
            ),
            if (job.isUrgent)
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4B6E),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.completedUrgentTag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBlue),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }
}
