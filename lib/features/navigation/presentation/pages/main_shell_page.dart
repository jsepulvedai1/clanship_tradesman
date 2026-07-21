import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_mobile_tradesman/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'package:clanship_mobile_tradesman/features/home/presentation/pages/home_page.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/pages/requests_page.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/pages/profile_page.dart';
import 'package:clanship_mobile_tradesman/features/settings/presentation/pages/settings_page.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_bloc.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_event.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_state.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/core/network/jobs_websocket_service.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    // Connect and listen globally to WebSocket notifications
    final socketService = di.sl<JobsWebSocketService>();
    socketService.connect();
    _socketSubscription = socketService.stream.listen((event) {
      debugPrint('MainShellPage received jobs websocket notification: $event');
      if (mounted) {
        context.read<RequestsBloc>().add(LoadPendingRequests());
      }
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.currentIndex,
            children: const [
              HomePage(),
              RequestsPage(),
              ProfilePage(),
              SettingsPage(),
            ],
          ),
          bottomNavigationBar: BlocBuilder<RequestsBloc, RequestsState>(
            builder: (context, requestsState) {
              final bool hasUnread = requestsState is RequestsLoaded &&
                  requestsState.requests.any((r) => !r.isRead || r.hasUnreadMessages);
              return _PremiumBottomNavBar(
                currentIndex: state.currentIndex,
                hasUnreadRequests: hasUnread,
                onTap: (index) {
                  context.read<NavigationBloc>().add(TabChanged(index));
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _PremiumBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool hasUnreadRequests;

  const _PremiumBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.hasUnreadRequests,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final Color activeColor = const Color(0xFF0D2B45);
    final Color inactiveColor = isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF5E6E78);
    final Color labelActiveColor = const Color(0xFF0D2B45);
    final Color labelInactiveColor = isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF5E6E78);
    final Color indicatorColor = const Color(0xFF0B6E4F); // Verde esmeralda

    final List<_NavBarItemData> items = [
      _NavBarItemData(
        activeIcon: Icons.home_rounded,
        inactiveIcon: Icons.home_outlined,
        label: l10n.navHome,
      ),
      _NavBarItemData(
        activeIcon: Icons.assignment_rounded,
        inactiveIcon: Icons.assignment_outlined,
        label: l10n.navRequests,
        showBadge: hasUnreadRequests,
      ),
      _NavBarItemData(
        activeIcon: Icons.person_rounded,
        inactiveIcon: Icons.person_outline_rounded,
        label: l10n.navProfile,
      ),
      _NavBarItemData(
        activeIcon: Icons.settings_rounded,
        inactiveIcon: Icons.settings_outlined,
        label: l10n.navSettings,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final bool isActive = currentIndex == index;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Badge(
                    isLabelVisible: item.showBadge,
                    backgroundColor: const Color(0xFFEF4444),
                    child: Icon(
                      isActive ? item.activeIcon : item.inactiveIcon,
                      color: isActive ? activeColor : inactiveColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Green indicator line
                  Container(
                    width: 24,
                    height: 3,
                    decoration: BoxDecoration(
                      color: isActive ? indicatorColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isActive ? labelActiveColor : labelInactiveColor,
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavBarItemData {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final bool showBadge;

  const _NavBarItemData({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    this.showBadge = false,
  });
}
