import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/features/profile/domain/repositories/profile_repository.dart';
import 'package:clanship_mobile_tradesman/core/widgets/address_picker_page.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/bloc/profile_event.dart';
import 'package:clanship_mobile_tradesman/features/home/presentation/bloc/home_bloc.dart';

class ServiceAreaWidget extends StatefulWidget {
  final dynamic user;

  const ServiceAreaWidget({super.key, required this.user});

  @override
  State<ServiceAreaWidget> createState() => _ServiceAreaWidgetState();
}

class _ServiceAreaWidgetState extends State<ServiceAreaWidget> {
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

  void _triggerReloads() {
    // Reload both Home and Profile data if their respective blocs are available in the current context.
    try {
      context.read<HomeBloc>().add(LoadUserData());
    } catch (_) {}
    
    try {
      context.read<ProfileBloc>().add(LoadProfileData());
    } catch (_) {}
  }

  Future<void> _updateLocationWithGPS(BuildContext context) async {
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
        if (mounted) {
          _showPermissionSettingsDialog(context);
        }
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw 'Location timeout';
            },
          );
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
        _triggerReloads();
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

  void _showPermissionSettingsDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.homeGpsPermissionDenied,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.homeGpsPermissionDeniedPermanent,
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.requestCancel,
              style: const TextStyle(color: Colors.grey),
            ),
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
              Geolocator.openAppSettings();
            },
            child: const Text('Abrir Ajustes'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddressPicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (context) => AddressPickerPage(
          initialAddress:
              widget.user.address == l10n.homeGpsCurrentLocationAddress
              ? ''
              : widget.user.address,
        ),
      ),
    );
    if (result != null && mounted) {
      final address = result['address'] as String;
      final lat = result['latitude'] as double;
      final lng = result['longitude'] as double;
      _updateLocationManual(context, address, lat, lng);
    }
  }

  Future<void> _updateLocationManual(
    BuildContext context,
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
        _triggerReloads();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 750;
    final String currentAddress =
        (widget.user.address != null && widget.user.address!.trim().isNotEmpty)
        ? widget.user.address!.trim()
        : l10n.homeNoAddressConfigured;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12), // Reduced padding
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF0D2B45),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.homeServiceAreaTitle,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E3135),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF0D2B45),
                  size: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Row(
                        children: [
                          const Icon(
                            Icons.map_rounded,
                            color: Color(0xFF0D2B45),
                          ),
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
          const SizedBox(height: 4),
          Text(
            currentAddress,
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2E3135),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateLocationWithGPS(context),
                    icon: SvgPicture.asset(
                      'assets/icon/icons_ F28C28/dialog.svg',
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(
                      l10n.homeGpsActualBtn,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 11,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D2B45),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openAddressPicker(context),
                    icon: SvgPicture.asset(
                      'assets/icon/icons_ F28C28/dialog.svg',
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF0D2B45),
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(
                      l10n.homeFixAddressBtn,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 11,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0D2B45),
                      side: const BorderSide(color: Color(0xFF0D2B45), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      minimumSize: const Size(0, 36),
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
