import 'package:flutter/material.dart';
import '../../domain/entities/active_request_detail_entity.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';

class ActiveRequestItem extends StatelessWidget {
  final ActiveRequestDetailEntity request;
  final VoidCallback onTap;

  const ActiveRequestItem({
    super.key,
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUrgent = request.isUrgent;
    final bool isUnread = !request.isRead && request.status == 'REQUESTED';
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color cardColor;
    if (isUrgent) {
      cardColor = const Color(0xFFFF4B6E);
    } else if (isUnread) {
      cardColor = isDark
          ? AppColors.primaryBlue.withAlpha(55)
          : AppColors.primaryBlue.withAlpha(25);
    } else {
      cardColor = Theme.of(context).cardColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isUnread
            ? Border.all(color: AppColors.primaryBlue.withAlpha(150), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isUrgent ? 40 : (isUnread ? 25 : 10)),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isUrgent
              ? Colors.white.withAlpha(50)
              : (isUnread
                  ? AppColors.primaryBlue.withAlpha(60)
                  : AppColors.primaryBlue.withAlpha(30)),
          child: Icon(
            _getCategoryIcon(request.category),
            color: isUrgent ? Colors.white : AppColors.primaryBlue,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                request.category,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUrgent ? Colors.white : Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ),
            if (isUnread)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statsOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NUEVA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.clientName,
              style: TextStyle(
                color: isUrgent ? Colors.white70 : Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(180),
              ),
            ),
            if (request.status == 'AGREED' || request.status == 'IN_VISIT') ...[
              const SizedBox(height: 6),
              if (request.scheduledDate != null && request.scheduledDate!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: isUrgent ? Colors.white70 : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${request.scheduledDate} ${request.scheduledTime ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isUrgent ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              if (request.agreedPrice != null && request.agreedPrice! > 0)
                Row(
                  children: [
                    Icon(
                      Icons.sell_outlined,
                      size: 12,
                      color: isUrgent ? Colors.white70 : AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Precio acordado: \$${request.agreedPrice!.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isUrgent ? Colors.white : AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isUrgent ? Colors.white : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fontanería':
        return Icons.plumbing;
      case 'electricidad':
        return Icons.electrical_services;
      default:
        return Icons.assignment_outlined;
    }
  }
}
