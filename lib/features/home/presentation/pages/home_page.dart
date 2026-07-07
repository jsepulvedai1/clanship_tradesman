import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
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
import 'package:clanship_mobile_tradesman/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_mobile_tradesman/core/network/jobs_websocket_service.dart';
import 'package:clanship_mobile_tradesman/core/network/firebase_notification_helper.dart';
import '../../../../core/widgets/skeleton_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription? _socketSubscription;
  late final HomeBloc _homeBloc;

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
      // Recargar datos al recibir cualquier evento
      _homeBloc.add(LoadUserData());
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F5),
        appBar: const _AppBarLoader(),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeDataLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  _homeBloc.add(LoadUserData());
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: ListView(
                  padding: const EdgeInsets.only(top: 10, bottom: 40),
                  children: [
                    StatsBanner(
                      rating: state.user.rating,
                      reviewsCount: state.user.reviewsCount,
                      onServicesTap: () {
                        // Acción próximamente
                      },
                    ),
                    const SizedBox(height: 10),
                    StatsGrid(
                      active: state.user.activeJobs,
                      completed: state.user.completedJobs,
                      rejected: state.user.rejectedJobs,
                      scheduled: state.user.scheduledJobs,
                      hasUnread: state.recentRequests.any(
                        (r) => !r.isRead && r.status == 'REQUESTED',
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
                    const SizedBox(height: 10),
                    AvailabilityWidget(
                      isAvailable: state.user.isAvailable,
                      onToggle: (value) {
                        _homeBloc.add(ToggleAvailability(value));
                      },
                    ),
                    const SizedBox(height: 10),
                    _LocationWidget(user: state.user),
                    const SizedBox(height: 10),
                    RecentRequestsWidget(
                      requests: state.recentRequests,
                      onRequestTap: (request) {
                        context.read<NavigationBloc>().add(const TabChanged(1));
                      },
                    ),
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
  const _AppBarLoader();

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
              SnackBar(
                content: Text('Error al subir foto: ${failure.toString()}'),
              ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al procesar foto: $e')));
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
            onSyncTap: () {
              context.read<HomeBloc>().add(LoadUserData());
            },
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final updateUseCase = di.sl<UpdateProfileUseCase>();
      final result = await updateUseCase(
        UpdateProfileParams(
          firstName: widget.user.firstName,
          lastName: widget.user.lastName,
          email: widget.user.email,
          address: 'Ubicación GPS actual',
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      result.fold((failure) => _showError(failure.message), (_) {
        homeBloc.add(LoadUserData());
        _showSuccess('Ubicación GPS actualizada con éxito.');
      });
    } catch (e) {
      _showError(e.toString());
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
  ) async {
    if (address.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final random = Random();
      final double latitude = -33.4489 + (random.nextDouble() - 0.5) * 0.1;
      final double longitude = -70.6693 + (random.nextDouble() - 0.5) * 0.1;

      final updateUseCase = di.sl<UpdateProfileUseCase>();
      final result = await updateUseCase(
        UpdateProfileParams(
          firstName: widget.user.firstName,
          lastName: widget.user.lastName,
          email: widget.user.email,
          address: address.trim(),
          latitude: latitude,
          longitude: longitude,
        ),
      );

      result.fold((failure) => _showError(failure.message), (_) {
        homeBloc.add(LoadUserData());
        _showSuccess('Dirección fija actualizada con éxito.');
      });
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showManualAddressDialog(BuildContext context, HomeBloc homeBloc) {
    final controller = TextEditingController(
      text: widget.user.address == 'Ubicación GPS actual'
          ? ''
          : widget.user.address,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Fijar Dirección Manual'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Ingresa tu dirección fija (Ej: Av. Providencia 1234)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final address = controller.text.trim();
                Navigator.pop(context);
                _updateLocationManual(context, homeBloc, address);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeBloc = context.read<HomeBloc>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String currentAddress =
        widget.user.address ?? 'Sin dirección configurada';
    final hasCoordinates =
        widget.user.latitude != null && widget.user.longitude != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
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
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF0D2B45),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Mi Área de Servicio / Ubicación',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3135),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            currentAddress,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E3135),
            ),
          ),
          if (hasCoordinates) ...[
            const SizedBox(height: 4),
            Text(
              'Coordenadas: ${widget.user.latitude.toStringAsFixed(5)}, ${widget.user.longitude.toStringAsFixed(5)}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
            ),
          ],
          const SizedBox(height: 18),
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
                    onPressed: () => _updateLocationWithGPS(context, homeBloc),
                    icon: SvgPicture.asset(
                      'assets/icon/icons_ F28C28/dialog.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: const Text(
                      'GPS Actual',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D2B45),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showManualAddressDialog(context, homeBloc),
                    icon: SvgPicture.asset(
                      'assets/icon/icons_ F28C28/dialog.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: const Text(
                      'Fijar Dirección',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B6E4F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
