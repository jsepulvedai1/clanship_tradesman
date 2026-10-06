import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_mobile_tradesman/core/network/local_notification_service.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/features/chat/presentation/pages/chat_page.dart';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<LocalNotificationItem> _localNotifications = [];
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _loadLocalNotifications();
    _notificationSubscription =
        LocalNotificationService.onNotificationAdded.listen((_) {
      _loadLocalNotifications();
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadLocalNotifications() async {
    final list = await LocalNotificationService.getNotifications();
    if (mounted) {
      setState(() {
        _localNotifications = list;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.homeNotificationsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await LocalNotificationService.clearAll();
              await _loadLocalNotifications();
            },
            child: Text(
              l10n.homeClearAllNotifications,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _localNotifications.isEmpty
          ? Center(
              child: Text(
                l10n.homeNoNewNotifications,
                style: const TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _localNotifications.length,
              itemBuilder: (context, index) {
                final notif = _localNotifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: () async {
                      // Marcar como leída / borrarla
                      await LocalNotificationService.deleteNotification(notif.id);
                      
                      final event = notif.data?['event'];
                      if (event == 'chat_message') {
                        final roomId = notif.data?['room_id']?.toString() ?? '';
                        final jobIdStr = notif.data?['job_id']?.toString();
                        final jobId = jobIdStr != null && jobIdStr.isNotEmpty ? int.tryParse(jobIdStr) : null;
                        
                        if (roomId.isNotEmpty) {
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(
                                roomId: roomId,
                                jobId: jobId,
                              ),
                            ),
                          );
                          return;
                        }
                      }

                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      context.read<NavigationBloc>().add(
                        const TabChanged(1, subIndex: 0),
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryBlue.withValues(
                        alpha: 0.1,
                      ),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notif.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      notif.body,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4),
                        size: 20,
                      ),
                      onPressed: () async {
                        await LocalNotificationService.deleteNotification(
                          notif.id,
                        );
                        await _loadLocalNotifications();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
