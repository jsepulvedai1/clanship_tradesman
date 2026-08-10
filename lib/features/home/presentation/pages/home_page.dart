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
import 'package:clanship_mobile_tradesman/features/home/presentation/widgets/home_skeleton.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/repositories/profile_repository.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_mobile_tradesman/core/network/jobs_websocket_service.dart';
import 'package:clanship_mobile_tradesman/core/network/firebase_notification_helper.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_bloc.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_event.dart';
import 'package:clanship_mobile_tradesman/core/network/local_notification_service.dart';
import '../../../../core/widgets/skeleton_box.dart';
import 'package:clanship_mobile_tradesman/core/widgets/address_picker_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription? _socketSubscription;
  late final HomeBloc _homeBloc;
  List<LocalNotificationItem> _localNotifications = [];
  bool _showAllNotifications = false;
  StreamSubscription? _localNotificationSubscription;

  @override
  void initState() {
    super.initState();
    _homeBloc = di.sl<HomeBloc>()..add(LoadUserData());
    FirebaseNotificationHelper.uploadFcmToken();

    // Conectar y escuchar notificaciones del WebSocket
    final socketService = di.sl<JobsWebSocketService>();
    socketService.connect();
    _socketSubscription = socketService.stream.listen((event) {
      debugPrint('HomePage received jobs websocket notification: $event');

      try {
        final Map<String, dynamic> data = event;
        if (data['event'] == 'new_message' ||
            data['event'] == 'job_created' ||
            data['event'] == 'job_updated') {
          final String title = data['event'] == 'job_created'
              ? 'Nueva Solicitud'
              : (data['event'] == 'job_updated' ? 'Trabajo Actualizado' : 'Mensaje Nuevo');
          final String msgText = data['message'] ?? 'Tienes una actualización de trabajo';
          LocalNotificationService.saveNotification(title, msgText);

          try {
            di.sl<RequestsBloc>().add(LoadPendingRequests());
          } catch (_) {}
        }
        if (data['event'] == 'profile_validated' ||
            data['event'] == 'profile_unvalidated') {
          final isVal =
              data['event'] == 'profile_validated' ||
              data['is_validated'] == true;
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            final updatedUser = authState.user.copyWith(isValidated: isVal);
            context.read<AuthBloc>().add(ProfileUpdated(updatedUser));
          }
          /*
          if (isVal && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '🎉 ¡Tu perfil profesional ha sido validado! Ya puedes activarte y cotizar.',
                ),
                backgroundColor: AppColors.successGreen,
                duration: Duration(seconds: 4),
              ),
            );
          }
          */
        }
      } catch (_) {}

      _homeBloc.add(LoadUserData());
    });

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
    _socketSubscription?.cancel();
    _localNotificationSubscription?.cancel();
    super.dispose();
  }

  Widget _buildNotificationsSection(double spacing) {
    if (_localNotifications.isEmpty) return const SizedBox.shrink();

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
                'Notificaciones',
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
                  'Limpiar todo',
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
                        'Notificaciones',
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
                          'Limpiar todo',
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No tienes nuevas notificaciones',
                          style: TextStyle(color: Colors.grey),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lo sentimos, no se pudo subir la foto.')),
            );
          }
        },
        (updatedUserEntity) {
          if (mounted) {
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
                content: const Text('Foto de perfil actualizada con éxito'),
                backgroundColor: AppColors.successGreen,
              ),
            );
          }
        },
      );
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lo sentimos, no se pudo procesar la foto.')),
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
    setState(() {
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Los servicios de ubicación están desactivados en el dispositivo.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Permiso de ubicación denegado.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Permiso de ubicación denegado permanentemente. Actívalo en los ajustes del sistema.';
      }

      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 5),
          );
        } catch (_) {}
      }

      if (position == null) {
        throw 'No se pudo obtener la ubicación actual.';
      }

      final profileRepo = di.sl<ProfileRepository>();
      final result = await profileRepo.updateProfessionalProfile(
        address: 'Ubicación GPS actual',
        latitude: position.latitude,
        longitude: position.longitude,
      );

      result.fold((failure) => _showError(failure.message), (_) {
        homeBloc.add(LoadUserData());
        _showSuccess('Ubicación GPS actualizada con éxito.');
      });
    } catch (e) {
      _showError('Lo sentimos, hubo un error. Por favor, intenta de nuevo.');
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
        _showSuccess('Dirección fija actualizada con éxito.');
      });
    } catch (e) {
      _showError('Lo sentimos, hubo un error. Por favor, intenta de nuevo.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showGpsActualInfoDialog(BuildContext context, HomeBloc homeBloc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.gps_fixed, color: Color(0xFF0D2B45)),
            SizedBox(width: 10),
            Text(
              'GPS Actual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Esta opción utiliza el sensor GPS en tiempo real de tu dispositivo para detectar tu ubicación geográfica exacta en este momento. Es ideal si te encuentras en terreno y deseas recibir trabajos cercanos a tu posición física actual.',
          style: TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF2E3135)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
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
            child: const Text('Usar mi GPS'),
          ),
        ],
      ),
    );
  }

  void _showFijarDireccionInfoDialog(BuildContext context, HomeBloc homeBloc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.pin_drop_rounded, color: Color(0xFF0B6E4F)),
            SizedBox(width: 10),
            Text(
              'Fijar Dirección',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Esta opción te permite seleccionar y fijar una dirección estática en el mapa como tu punto base de trabajo (por ejemplo tu hogar o taller). Así recibirás solicitudes en ese sector sin depender de tu ubicación GPS.',
          style: TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF2E3135)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
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
                    initialAddress: widget.user.address == 'Ubicación GPS actual'
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
            child: const Text('Seleccionar en Mapa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeBloc = context.read<HomeBloc>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 750;
    final String currentAddress =
        (widget.user.address != null && widget.user.address!.trim().isNotEmpty)
        ? widget.user.address!.trim()
        : 'Sin dirección configurada';
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
                  'Mi Área de Servicio / Ubicación',
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
                      title: const Row(
                        children: [
                          Icon(Icons.map_rounded, color: Color(0xFF0D2B45)),
                          SizedBox(width: 10),
                          Text(
                            'Área de Servicio',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• GPS Actual: Utiliza tu ubicación en vivo por GPS para recibir solicitudes cerca de donde te encuentres físicamente.',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '• Fijar Dirección: Define un punto fijo o taller en el mapa para recibir solicitudes en ese sector de forma permanente.',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Entendido'),
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
              'Coordenadas: ${widget.user.latitude.toStringAsFixed(5)}, ${widget.user.longitude.toStringAsFixed(5)}',
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
                      'GPS Actual',
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
                      'Fijar Dirección',
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
