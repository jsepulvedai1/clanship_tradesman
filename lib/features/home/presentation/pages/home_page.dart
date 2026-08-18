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
import 'package:clanship_mobile_tradesman/features/home/presentation/widgets/stats_banner.dart';
import 'package:clanship_mobile_tradesman/features/home/presentation/widgets/stats_grid.dart';
import 'package:clanship_mobile_tradesman/features/home/presentation/widgets/availability_widget.dart';
import 'package:clanship_mobile_tradesman/features/home/presentation/widgets/recent_requests_widget.dart';
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
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_bloc.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_event.dart';
import 'package:clanship_mobile_tradesman/core/network/local_notification_service.dart';
import '../../../../core/widgets/skeleton_box.dart';
import 'package:clanship_mobile_tradesman/core/widgets/address_picker_page.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/pages/documents_page.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/pages/rejection_review_page.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeBloc _homeBloc;
  List<LocalNotificationItem> _localNotifications = [];
  bool _showAllNotifications = false;
  StreamSubscription? _localNotificationSubscription;

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
                          color: AppColors.primaryBlue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryBlue.withOpacity(0.1),
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
                          color: AppColors.primaryBlue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryBlue.withOpacity(0.1),
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
                      color: AppColors.primaryBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        context.read<NavigationBloc>().add(
                          const TabChanged(1, subIndex: 0),
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
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
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
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
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.homeNotificationsTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await LocalNotificationService.clearAll();
                          await _loadLocalNotifications();
                          setSheetState(() {});
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
                  const SizedBox(height: 16),
                  if (_localNotifications.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          l10n.homeNoNewNotifications,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _localNotifications.length,
                        itemBuilder: (context, index) {
                          final notif = _localNotifications[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              onTap: () {
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
                                backgroundColor: AppColors.primaryBlue
                                    .withOpacity(0.1),
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
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.4),
                                  size: 20,
                                ),
                                onPressed: () async {
                                  await LocalNotificationService.deleteNotification(
                                    notif.id,
                                  );
                                  await _loadLocalNotifications();
                                  setSheetState(() {});
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
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
        body: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeDataLoaded) {
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
                child: ListView(
                  padding: EdgeInsets.only(
                    top: isSmallScreen ? 6 : 10,
                    bottom: isSmallScreen ? 20 : 40,
                  ),
                  children: [
                    StatsBanner(
                      rating: state.user.rating,
                      reviewsCount: state.user.reviewsCount,
                      onServicesTap: () {
                        context.read<NavigationBloc>().add(
                          const TabChanged(3, scrollToServices: false),
                        );
                      },
                    ),
                    SizedBox(height: spacing),
                    _buildNotificationsSection(spacing),
                    StatsGrid(
                      active: state.user.activeJobs,
                      completed: state.user.completedJobs,
                      rejected: state.user.rejectedJobs,
                      scheduled: state.user.scheduledJobs,
                      hasUnread: state.recentRequests.any(
                        (r) => !r.isRead && r.status == 'REQUESTED',
                      ),
                      hasScheduledUnread: state.recentRequests.any(
                        (r) =>
                            !r.isRead &&
                            (r.status == 'AGREED' ||
                                r.status == 'SCHEDULED' ||
                                r.status == 'IN_VISIT'),
                      ),
                      onActiveTap: () {
                        context.read<NavigationBloc>().add(
                          const TabChanged(1, subIndex: 0),
                        );
                      },
                      onCompletedTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CompletedRequestsPage(),
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
                            builder: (context) => const RejectedRequestsPage(),
                          ),
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
                            builder: (context) => const RejectionReviewPage(),
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
                    _LocationWidget(user: state.user),
                    SizedBox(height: spacing),
                    // RecentRequestsWidget(
                    //   requests: state.recentRequests,
                    //   onRequestTap: (request) {
                    //     context.read<NavigationBloc>().add(const TabChanged(1));
                    //   },
                    // ),
                  ],
                ),
              );
            }
            return const HomeSkeleton();
          },
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

class _LocationWidget extends StatefulWidget {
  final dynamic user;

  const _LocationWidget({required this.user});

  @override
  State<_LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<_LocationWidget> {
  bool _isLoading = false;

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _updateLocationWithGPS(
    BuildContext context,
    HomeBloc homeBloc,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw l10n.homeGpsDisabledError;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw l10n.homeGpsPermissionDenied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw l10n.homeGpsPermissionDeniedPermanent;
      }

      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
          ).timeout(const Duration(seconds: 5), onTimeout: () {
            throw 'Location timeout';
          });
        } catch (_) {}
      }

      if (position == null) {
        throw l10n.homeGpsLocationFetchError;
      }

      final profileRepo = di.sl<ProfileRepository>();
      final result = await profileRepo.updateProfessionalProfile(
        address: l10n.homeGpsCurrentLocationAddress,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      result.fold((failure) => _showError(failure.message), (_) {
        homeBloc.add(LoadUserData());
        _showSuccess(l10n.homeGpsUpdateSuccess);
      });
    } catch (e) {
      _showError(e is String ? e : l10n.homeGenericError);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateLocationManual(
    BuildContext context,
    HomeBloc homeBloc,
    String address,
    double latitude,
    double longitude,
  ) async {
    if (address.trim().isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
    });

    try {
      final profileRepo = di.sl<ProfileRepository>();
      final result = await profileRepo.updateProfessionalProfile(
        address: address.trim(),
        latitude: latitude,
        longitude: longitude,
      );

      result.fold((failure) => _showError(failure.message), (_) {
        homeBloc.add(LoadUserData());
        _showSuccess(l10n.homeFixAddressSuccess);
      });
    } catch (e) {
      _showError(l10n.homeGenericError);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showGpsActualInfoDialog(BuildContext context, HomeBloc homeBloc) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.gps_fixed, color: Color(0xFF0D2B45)),
            const SizedBox(width: 10),
            Text(
              l10n.mapGpsDialogTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          l10n.homeGpsDialogInfoContent,
          style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF2E3135)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.requestCancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D2B45),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              _updateLocationWithGPS(context, homeBloc);
            },
            child: Text(l10n.homeUseMyGpsBtn),
          ),
        ],
      ),
    );
  }

  void _showFijarDireccionInfoDialog(BuildContext context, HomeBloc homeBloc) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.pin_drop_rounded, color: Color(0xFF0B6E4F)),
            const SizedBox(width: 10),
            Text(
              l10n.mapPinAddressDialogTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          l10n.homePinAddressInfoContent,
          style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF2E3135)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.requestCancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B6E4F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final result = await Navigator.push<Map<String, dynamic>?>(
                context,
                MaterialPageRoute(
                  builder: (context) => AddressPickerPage(
                    initialAddress: widget.user.address == l10n.homeGpsCurrentLocationAddress
                        ? ''
                        : widget.user.address,
                  ),
                ),
              );
              if (result != null && mounted) {
                final address = result['address'] as String;
                final lat = result['latitude'] as double;
                final lng = result['longitude'] as double;
                _updateLocationManual(
                  context,
                  homeBloc,
                  address,
                  lat,
                  lng,
                );
              }
            },
            child: Text(l10n.homeSelectOnMapBtn),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final homeBloc = context.read<HomeBloc>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 750;
    final String currentAddress =
        (widget.user.address != null && widget.user.address!.trim().isNotEmpty)
        ? widget.user.address!.trim()
        : l10n.homeNoAddressConfigured;
    final hasCoordinates =
        widget.user.latitude != null && widget.user.longitude != null;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 18),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icon/icons_ F28C28/map-point.svg',
                width: isSmallScreen ? 20 : 24,
                height: isSmallScreen ? 20 : 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF0D2B45),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.homeServiceAreaTitle,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E3135),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF0D2B45),
                  size: 20,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Row(
                        children: [
                          const Icon(Icons.map_rounded, color: Color(0xFF0D2B45)),
                          const SizedBox(width: 10),
                          Text(
                            l10n.homeServiceAreaInfoTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.homeServiceAreaInfoGps,
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.homeServiceAreaInfoPin,
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.commonUnderstood),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 14),
          Text(
            currentAddress,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2E3135),
            ),
          ),
          if (hasCoordinates) ...[
            const SizedBox(height: 4),
            Text(
              '${l10n.homeCoordinatesLabel}: ${widget.user.latitude.toStringAsFixed(5)}, ${widget.user.longitude.toStringAsFixed(5)}',
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 11,
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
            ),
          ],
          SizedBox(height: isSmallScreen ? 12 : 18),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showGpsActualInfoDialog(context, homeBloc),
                    icon: SvgPicture.asset(
                      'assets/icon/icons_ F28C28/dialog.svg',
                      width: isSmallScreen ? 14 : 16,
                      height: isSmallScreen ? 14 : 16,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(
                      l10n.homeGpsActualBtn,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D2B45),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 10 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showFijarDireccionInfoDialog(context, homeBloc),
                    icon: SvgPicture.asset(
                      'assets/icon/icons_ F28C28/dialog.svg',
                      width: isSmallScreen ? 14 : 16,
                      height: isSmallScreen ? 14 : 16,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(
                      l10n.homeFixAddressBtn,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B6E4F),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 10 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          // Switch.adaptive(
          //   value: isUrgencyModeActive,
          //   onChanged: onToggleUrgencyMode,
          //   activeColor: urgencyColor,
          //   activeTrackColor: urgencyColor.withValues(alpha: 0.3),
          // ),
        ],
      ),
    );
  }
}
