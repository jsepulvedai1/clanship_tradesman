import 'package:clanship_mobile_tradesman/features/home/presentation/pages/notifications_page.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/home/presentation/bloc/home_bloc.dart';
import 'package:clanship_mobile_tradesman/features/home/presentation/widgets/home_app_bar.dart';
import 'package:clanship_mobile_tradesman/features/home/presentation/widgets/home_banner_carousel.dart';
import 'package:clanship_mobile_tradesman/features/home/presentation/widgets/stats_grid.dart';
import 'package:clanship_mobile_tradesman/features/home/presentation/widgets/availability_widget.dart';
import 'package:clanship_mobile_tradesman/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/pages/completed_requests_page.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/pages/rejected_requests_page.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/features/home/presentation/widgets/home_skeleton.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/repositories/profile_repository.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_mobile_tradesman/core/network/firebase_notification_helper.dart';
import 'package:clanship_mobile_tradesman/core/network/local_notification_service.dart';
import '../../../../core/widgets/skeleton_box.dart';
import 'package:clanship_mobile_tradesman/core/widgets/address_picker_page.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/widgets/service_area_widget.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/pages/rejection_review_page.dart';
import 'package:clanship_mobile_tradesman/core/utils/tutorial_keys.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeBloc _homeBloc;
  List<LocalNotificationItem> _localNotifications = [];
  StreamSubscription? _localNotificationSubscription;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _homeBloc = context.read<HomeBloc>()..add(LoadUserData());
    FirebaseNotificationHelper.uploadFcmToken();

    _loadLocalNotifications();
    _localNotificationSubscription = LocalNotificationService
        .onNotificationAdded
        .listen((_) {
          _loadLocalNotifications();
        });
  }

  late TutorialCoachMark _tutorialCoachMark;
  List<TargetFocus> _targets = [];

  Future<void> _checkAndShowTutorial() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    
    final userId = authState.user.id;
    final prefs = await SharedPreferences.getInstance();
    final prefsKey = 'hasSeenHomeTutorial_$userId';
    final hasSeenTutorial = prefs.getBool(prefsKey) ?? false;

    if (!hasSeenTutorial && mounted) {
      _initTargets();
      prefs.setBool(prefsKey, true);
      _showTutorial();
    }
  }

  void _showTutorial() {
    _tutorialCoachMark = TutorialCoachMark(
      targets: _targets,
      colorShadow: const Color(0xFF1A1A1A),
      textSkip: "Omitir",
      paddingFocus: 10,
      opacityShadow: 0.85,
      onFinish: () => debugPrint("Tutorial completado"),
      onSkip: () => true,
      onClickTarget: (target) {
        if (target.identify == "scheduledKey") {
          _scrollToBottom();
        }
      },
      onClickOverlay: (target) {
        if (target.identify == "scheduledKey") {
          _scrollToBottom();
        }
      },
    );

    _tutorialCoachMark.show(context: context);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _initTargets() {
    _targets = [
      TargetFocus(
        identify: "questionKey",
        keyTarget: TutorialKeys.homeQuestionKey,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _buildTooltipContent(
              title: "Ayuda y Soporte",
              description:
                  "Si tienes dudas, presiona aquí para consultar la guía o contactar a soporte.",
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "activeKey",
        keyTarget: TutorialKeys.homeActiveRequestsKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _buildTooltipContent(
              title: "Solicitudes de Trabajo",
              description:
                  "Aquí verás las solicitudes de trabajo nuevas o en curso.",
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "completedKey",
        keyTarget: TutorialKeys.homeCompletedRequestsKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _buildTooltipContent(
              title: "Trabajos Completados",
              description:
                  "Revisa el historial de los servicios que ya has finalizado con éxito.",
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "scheduledKey",
        keyTarget: TutorialKeys.homeScheduledRequestsKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _buildTooltipContent(
              title: "Solicitudes Programadas",
              description:
                  "Tus visitas y trabajos agendados para fechas futuras aparecerán aquí.",
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "locationKey",
        keyTarget: TutorialKeys.homeLocationKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTooltipContent(
              title: "Tu Ubicación",
              description:
                  "Puedes actualizar tu dirección actual o activar la ubicación in movimiento para conseguir trabajos cercanos.",
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "navInicioKey",
        keyTarget: TutorialKeys.navInicioKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTooltipContent(
              title: "Inicio",
              description:
                  "Tu panel principal donde ves tus estadísticas y estado actual.",
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "navSolicitudesKey",
        keyTarget: TutorialKeys.navSolicitudesKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTooltipContent(
              title: "Solicitudes",
              description:
                  "Aquí administras todas tus visitas y trabajos en curso.",
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "navBuscaKey",
        keyTarget: TutorialKeys.navBuscaKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTooltipContent(
              title: "Oportunidades",
              description:
                  "Explora nuevas oportunidades de trabajo cercanas a ti.",
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "navProfileKey",
        keyTarget: TutorialKeys.navProfileKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTooltipContent(
              title: "Tu Perfil",
              description:
                  "Visualiza y actualiza tu información profesional y fotos.",
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "navAjustesKey",
        keyTarget: TutorialKeys.navAjustesKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTooltipContent(
              title: "Ajustes",
              description:
                  "Configura tu cuenta, tu plan y más. ¡Puedes repetir este tutorial desde allí!",
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildTooltipContent({
    required String title,
    required String description,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22.0,
          ),
        ),
        const SizedBox(height: 10.0),
        Text(
          description,
          style: const TextStyle(color: Colors.white70, fontSize: 16.0),
        ),
      ],
    );
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
  void dispose() {
    _scrollController.dispose();
    _localNotificationSubscription?.cancel();
    super.dispose();
  }

  Widget _buildNotificationsSection(double spacing) {
    if (_localNotifications.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final count = _localNotifications.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.homeNotificationsTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () async {
                  await LocalNotificationService.clearAll();
                  _loadLocalNotifications();
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
          const SizedBox(height: 8),
          SizedBox(
            height: 88, // Total height to account for stack shifts
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Card 3 (Bottom)
                if (count > 2)
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 16,
                    child: Opacity(
                      opacity: 0.4,
                      child: Container(
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Card 2 (Middle)
                if (count > 1)
                  Positioned(
                    left: 8,
                    right: 8,
                    top: 8,
                    child: Opacity(
                      opacity: 0.7,
                      child: Container(
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Card 1 (Top/Interactive)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        _showLocalNotificationsBottomSheet();
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryBlue.withValues(
                          alpha: 0.1,
                        ),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          color: AppColors.primaryBlue,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        _localNotifications[0].title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        _localNotifications[0].body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 11,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                          size: 18,
                        ),
                        onPressed: () async {
                          await LocalNotificationService.deleteNotification(
                            _localNotifications[0].id,
                          );
                          _loadLocalNotifications();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLocalNotificationsBottomSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    ).then((_) {
      _loadLocalNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F5),
        appBar: _AppBarLoader(
          hasNotifications: _localNotifications.isNotEmpty,
          onNotificationsTap: _showLocalNotificationsBottomSheet,
        ),
        body: BlocListener<NavigationBloc, NavigationState>(
          listener: (context, navState) {
            if (navState.currentIndex == 0) {
              context.read<HomeBloc>().add(LoadUserData());
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _checkAndShowTutorial();
              });
            } else if (navState.currentIndex == 2) {
              context.read<HomeBloc>().add(MarkOpportunitiesAsSeen());
            }
          },
          child: BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is HomeDataLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _checkAndShowTutorial();
                });

                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated &&
                    authState.user.isValidated != state.user.isValidated) {
                  final updatedUser = authState.user.copyWith(
                    isValidated: state.user.isValidated,
                  );
                  context.read<AuthBloc>().add(ProfileUpdated(updatedUser));
                }
              }
            },
            builder: (context, state) {
              if (state is HomeDataLoaded) {
                final double screenHeight = MediaQuery.of(context).size.height;
                final bool isSmallScreen = screenHeight < 750;
                final double spacing = isSmallScreen ? 6.0 : 10.0;

                return RefreshIndicator(
                  onRefresh: () async {
                    _homeBloc.add(LoadUserData());
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: isSmallScreen ? 6 : 10,
                      bottom: isSmallScreen
                          ? 80
                          : 120, // Aumentado para dar espacio al scroll sobre el Navbar
                    ),
                    child: Column(
                      children: [
                        const HomeBannerCarousel(),
                        SizedBox(height: spacing),
                        _buildNotificationsSection(spacing),
                        StatsGrid(
                          active: state.user.activeJobs,
                          completed: state.user.completedJobs,
                          rejected: state.user.rejectedJobs,
                          scheduled: state.user.scheduledJobs,
                          unreadActiveCount: state.recentRequests.where(
                            (r) => !r.isRead && r.status == 'REQUESTED',
                          ).length,
                          unreadScheduledCount: state.recentRequests.where(
                            (r) =>
                                !r.isRead &&
                                (r.status == 'AGREED' ||
                                    r.status == 'SCHEDULED' ||
                                    r.status == 'IN_VISIT'),
                          ).length,
                          openOpportunitiesCount: state.openOpportunitiesCount,
                          onActiveTap: () {
                            context.read<NavigationBloc>().add(
                              const TabChanged(1, subIndex: 0),
                            );
                          },
                          onCompletedTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CompletedRequestsPage(),
                              ),
                            );
                          },
                          onScheduledTap: () {
                            context.read<NavigationBloc>().add(
                              const TabChanged(1, subIndex: 1),
                            );
                          },
                          onRejectedTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RejectedRequestsPage(),
                              ),
                            );
                          },
                          onCotizacionesTap: () {
                            context.read<HomeBloc>().add(MarkOpportunitiesAsSeen());
                            context.read<NavigationBloc>().add(
                              const TabChanged(2),
                            );
                          },
                        ),
                        SizedBox(height: spacing),
                        AvailabilityWidget(
                          isAvailable: state.user.isAvailable,
                          isUrgencyModeActive: state.user.isEmergency,
                          isValidated: state.user.isValidated,
                          isRejected: state.user.isRejected,
                          rejectionReason: state.user.effectiveRejectionReason,
                          onReuploadDocuments: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RejectionReviewPage(),
                              ),
                            );
                            _homeBloc.add(LoadUserData());
                          },
                          onToggleAvailability: (bool value) {
                            _homeBloc.add(ToggleAvailability(value));
                          },
                          onToggleUrgencyMode: (bool value) {
                            _homeBloc.add(ToggleUrgency(value));
                          },
                        ),

                        SizedBox(height: spacing),

                        SizedBox(height: spacing),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ServiceAreaWidget(
                            key: TutorialKeys.homeLocationKey,
                            user: state.user,
                          ),
                        ),
                        SizedBox(height: spacing),
                        // RecentRequestsWidget(
                        //   requests: state.recentRequests,
                        //   onRequestTap: (request) {
                        //     context.read<NavigationBloc>().add(const TabChanged(1));
                        //   },
                        // ),
                      ],
                    ),
                  ),
                );
              }
              return const HomeSkeleton();
            },
          ),
        ),
      ),
    );
  }
}

class _AppBarLoader extends StatefulWidget implements PreferredSizeWidget {
  final bool hasNotifications;
  final VoidCallback onNotificationsTap;

  const _AppBarLoader({
    required this.hasNotifications,
    required this.onNotificationsTap,
  });

  @override
  State<_AppBarLoader> createState() => _AppBarLoaderState();

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _AppBarLoaderState extends State<_AppBarLoader> {
  bool _isAvatarUploading = false;

  Future<void> _pickAvatar(BuildContext context, dynamic userEntity) async {
    if (_isAvatarUploading) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 60,
    );

    if (image == null || !mounted) return;

    setState(() {
      _isAvatarUploading = true;
    });

    try {
      final file = File(image.path);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final authState = context.read<AuthBloc>().state;
      String firstName = '';
      String lastName = '';
      String email = '';

      if (userEntity != null) {
        firstName = userEntity.firstName ?? '';
        lastName = userEntity.lastName ?? '';
        email = userEntity.email ?? '';
      }

      if (firstName.isEmpty && authState is AuthAuthenticated) {
        firstName = authState.user.firstName ?? '';
      }
      if (lastName.isEmpty && authState is AuthAuthenticated) {
        lastName = authState.user.lastName ?? '';
      }
      if (email.isEmpty && authState is AuthAuthenticated) {
        email = authState.user.email;
      }

      if (firstName.isEmpty) firstName = 'Maestro';

      final updateUseCase = di.sl<UpdateProfileUseCase>();
      final result = await updateUseCase(
        UpdateProfileParams(
          firstName: firstName,
          lastName: lastName,
          email: email,
          avatarBase64: base64Image,
        ),
      );

      result.fold(
        (failure) {
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.settingsAvatarUploadError)),
            );
          }
        },
        (updatedUserEntity) {
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            if (authState is AuthAuthenticated) {
              final updatedUser = authState.user.copyWith(
                avatarPath: updatedUserEntity.profileImageUrl,
              );
              context.read<AuthBloc>().add(ProfileUpdated(updatedUser));
            }

            // Recargar HomeBloc
            context.read<HomeBloc>().add(LoadUserData());

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.settingsAvatarUploadSuccess),
                backgroundColor: AppColors.successGreen,
              ),
            );
          }
        },
      );
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsAvatarProcessError)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAvatarUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeDataLoaded) {
          return HomeAppBar(
            user: state.user,
            isAvatarUploading: _isAvatarUploading,
            onAvatarTap: () => _pickAvatar(context, state.user),
            hasNotifications: widget.hasNotifications,
            onSyncTap: widget.onNotificationsTap,
          );
        }

        final bool isDark = Theme.of(context).brightness == Brightness.dark;

        return AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          toolbarHeight: 80,
          title: Row(
            children: [
              const SkeletonBox(width: 45, height: 45, borderRadius: 25),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 100, height: 14),
                  SizedBox(height: 6),
                  SkeletonBox(width: 150, height: 18),
                ],
              ),
            ],
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: SkeletonBox(width: 32, height: 32, borderRadius: 16),
            ),
          ],
        );
      },
    );
  }
}


