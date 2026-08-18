import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/subscription_banner.dart';
import '../widgets/bio_section.dart';
import '../widgets/portfolio_gallery.dart';
import '../widgets/section_header.dart';
import '../widgets/services_header_banner.dart';
import '../widgets/working_radius_section.dart';
import '../widgets/profile_skeleton.dart';
import '../widgets/social_link_section.dart';
import '../widgets/profile_action_button.dart';
import 'documents_page.dart';
import 'profile_preview_page.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/widgets/tradesman_subtags_sheet.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_mobile_tradesman/core/utils/image_cropper_helper.dart';
import 'package:clanship_mobile_tradesman/features/navigation/presentation/bloc/navigation_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScrollController _scrollController = ScrollController();
  bool _showAllServices = false;

  Widget _buildServicesWrap(UserEntity user) {
    final List<Map<String, dynamic>> displaySpecialties = List.from(user.specialties);
    if (displaySpecialties.isEmpty && user.specialtyName != null && user.specialtyName!.isNotEmpty) {
      displaySpecialties.add({
        'id': user.specialtyId ?? '',
        'name': user.specialtyName!,
        'iconUrl': user.specialtyIconUrl ?? '',
      });
    }

    final List<Widget> allChips = [
      ...displaySpecialties.map((spec) {
        final specName = spec['name'] ?? '';
        if (specName.isEmpty) return const SizedBox.shrink();
        return Chip(
          label: Text(specName),
          backgroundColor: AppColors.primaryBlue.withOpacity(0.12),
          side: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
        );
      }),
      ...user.serviceTags
          .where((name) {
            return !user.specialties.any((s) => s['name'] == name);
          })
          .map((tagName) {
            return Chip(
              label: Text(tagName),
              backgroundColor: Colors.grey.withOpacity(0.1),
              side: BorderSide(
                color: Colors.grey.shade300,
              ),
            );
          }),
      ...user.subtags.map((subtag) {
        final subtagName = subtag['name'] ?? '';
        final tagName = subtag['tag']?['name'] ?? '';
        return Chip(
          label: Text(
            tagName.isNotEmpty ? '$tagName > $subtagName' : subtagName,
          ),
          backgroundColor: AppColors.primaryBlue.withOpacity(0.08),
          side: const BorderSide(
            color: AppColors.primaryBlue,
          ),
        );
      }),
    ];

    if (allChips.isEmpty) {
      return const Text(
        'No has seleccionado especialidades.',
        style: TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (allChips.length <= 4) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: allChips,
      );
    }

    List<Widget> visibleChips;
    if (!_showAllServices) {
      visibleChips = allChips.take(4).toList();
      final remaining = allChips.length - 4;
      visibleChips.add(
        ActionChip(
          label: Text(
            '+$remaining más',
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
          side: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
          onPressed: () {
            setState(() {
              _showAllServices = true;
            });
          },
        ),
      );
    } else {
      visibleChips = List.from(allChips);
      visibleChips.add(
        ActionChip(
          label: const Text(
            'Ver menos',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.grey.withOpacity(0.15),
          side: BorderSide(
            color: Colors.grey.shade400,
          ),
          onPressed: () {
            setState(() {
              _showAllServices = false;
            });
          },
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: visibleChips,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showEditBioDialog(BuildContext context, UserEntity user) {
    final bioController = TextEditingController(text: user.biography);
    final rateController = TextEditingController(
      text: user.hourlyRate.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          title: const Text(
            'Editar Perfil Profesional',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: bioController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Biografía',
                    hintText: 'Describe tu experiencia y habilidades...',
                  ),
                ),
                const SizedBox(height: 16),
                // TextField(
                //   controller: rateController,
                //   keyboardType: TextInputType.number,
                //   decoration: const InputDecoration(
                //     labelText: 'Tarifa por hora (\$)',
                //     hintText: 'Ej: 15000',
                //   ),
                // ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final rate = double.tryParse(rateController.text) ?? 0.0;
                context.read<ProfileBloc>().add(
                  UpdateProfessionalProfileEvent(
                    bio: bioController.text.trim(),
                    hourlyRate: rate,
                  ),
                );
                Navigator.pop(dialogContext);
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

  Future<void> _pickPortfolioImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (pickedFile != null && context.mounted) {
      final croppedPath = await ImageCropperHelper.cropImage(
        imagePath: pickedFile.path,
        isSquare: false,
      );
      if (croppedPath != null && context.mounted) {
        context.read<ProfileBloc>().add(AddPortfolioPhotoEvent(croppedPath));
      }
    }
  }

  void _showSubtagsBottomSheet(
    BuildContext context,
    UserEntity user,
    List<Map<String, dynamic>> availableSpecialties,
  ) {
    if (availableSpecialties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cargando especialidades...')),
      );
      context.read<ProfileBloc>().add(LoadSpecialtiesEvent());
      return;
    }

    final initialSpecialtyIds = user.specialties
        .map((s) => s['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    final initialTagIds = user.tags
        .map((t) => t['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    final initialSubtagIds = user.subtags
        .map((s) => s['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return TradesmanSubtagsSheet(
          specialties: availableSpecialties,
          initialSelectedSpecialtyIds: initialSpecialtyIds,
          initialSelectedTagIds: initialTagIds,
          initialSelectedSubtagIds: initialSubtagIds,
          maxSpecialtiesPerTradesman: user.subscriptionPlan?.serviceCategories ?? 999,
          onSave: (selectedSpecialtyIds, selectedTagIds, selectedSubtagIds) {
            context.read<ProfileBloc>().add(
              UpdateProfessionalProfileEvent(
                specialtyIds: selectedSpecialtyIds.toList(),
                tagIds: selectedTagIds.toList(),
                subtagIds: selectedSubtagIds.toList(),
              ),
            );
          },
        );
      },
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileBloc>()..add(LoadProfileData()),
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.trueBlack
            : AppColors.smokeWhite,
        floatingActionButton: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoaded) {
              return FloatingActionButton.extended(
                backgroundColor: AppColors.primaryBlue,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfilePreviewPage(user: state.user),
                    ),
                  );
                },
                icon: const Icon(Icons.remove_red_eye, color: Colors.white),
                label: const Text(
                  'Vista Previa',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        body: BlocListener<NavigationBloc, NavigationState>(
          listenWhen: (prev, curr) =>
              curr.scrollToServices && curr.currentIndex == 2,
          listener: (context, state) => _scrollToBottom(),
          child: BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (previous, current) {
              if (previous is ProfileLoaded && current is ProfileLoaded) {
                return previous.isAvatarUploading &&
                    !current.isAvatarUploading &&
                    previous.user.profileImageUrl !=
                        current.user.profileImageUrl;
              }
              return false;
            },
            listener: (context, state) {
              if (state is ProfileLoaded) {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  final updatedUser = authState.user.copyWith(
                    avatarPath: state.user.profileImageUrl,
                  );
                  context.read<AuthBloc>().add(ProfileUpdated(updatedUser));
                }
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Foto de perfil actualizada con éxito'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const ProfileSkeleton();
                }

                if (state is ProfileLoaded) {
                  final user = state.user;
                  final l10n = AppLocalizations.of(context)!;

                  return Column(
                    children: [
                      ProfileAppBar(user: user),
                      Expanded(
                        child: ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 40),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 24.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.profileWhoAmI,
                                    style: const TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      ...List.generate(5, (index) {
                                        final starValue = index + 1;
                                        final rating = user.rating;
                                        IconData icon;
                                        if (rating >= starValue) {
                                          icon = Icons.star_rounded;
                                        } else if (rating >= starValue - 0.5) {
                                          icon = Icons.star_half_rounded;
                                        } else {
                                          icon = Icons.star_outline_rounded;
                                        }
                                        return Icon(
                                          icon,
                                          color: const Color(0xFFFFC107),
                                          size: 22,
                                        );
                                      }),
                                      const SizedBox(width: 4),
                                      Text(
                                        user.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SubscriptionBanner(
                              planName: user.planName,
                              daysRemaining: user.daysRemaining,
                            ),
                            const SizedBox(height: 24),
                            BioSection(
                              biography: user.biography,
                              hourlyRate: user.hourlyRate,
                              onEditTap: () =>
                                  _showEditBioDialog(context, user),
                            ),
                            ServicesHeaderBanner(
                              onTap: () => _showSubtagsBottomSheet(
                                context,
                                user,
                                state.availableSpecialties,
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Row(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     const Text(
                                  //       'Mis Especialidades',
                                  //       style: TextStyle(
                                  //         fontSize: 18,
                                  //         fontWeight: FontWeight.bold,
                                  //       ),
                                  //     ),
                                  //     TextButton.icon(
                                  //       onPressed: () =>
                                  //           _showSubtagsBottomSheet(
                                  //             context,
                                  //             user,
                                  //             state.availableSpecialties,
                                  //           ),
                                  //       icon: const Icon(Icons.edit, size: 18),
                                  //       label: const Text('Editar'),
                                  //       style: TextButton.styleFrom(
                                  //         foregroundColor:
                                  //             AppColors.primaryBlue,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  const SizedBox(height: 8),
                                  _buildServicesWrap(user),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            WorkingRadiusSection(
                              initialRadius: user.serviceRadius,
                              onRadiusChanged: (value) {
                                context.read<ProfileBloc>().add(
                                  UpdateProfessionalProfileEvent(
                                    serviceRadius: value.toInt(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            const SizedBox(height: 24),
                            Stack(
                              children: [
                                PortfolioGallery(
                                  portfolioPhotos: user.portfolioPhotos,
                                  onAddTap: () {
                                    if (user.portfolioPhotos.length >= 8) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'No puedes subir más de 8 fotos a tu portafolio',
                                          ),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    } else {
                                      _pickPortfolioImage(context);
                                    }
                                  },
                                  onDeleteTap: (photoId) {
                                    context.read<ProfileBloc>().add(
                                      DeletePortfolioPhotoEvent(photoId),
                                    );
                                  },
                                  onSetAvatarTap: (imageUrl) {
                                    context.read<ProfileBloc>().add(
                                      SetAvatarFromUrlEvent(imageUrl),
                                    );
                                  },
                                ),
                                if (state.isPhotoUploading ||
                                    state.isPhotoDeleting ||
                                    state.isUpdating)
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.black12,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            ProfileActionButton(
                              title: l10n.profileViewDocuments,
                              isSecondary: false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DocumentsPage(),
                                  ),
                                );
                              },
                            ),
                            SocialLinkSection(
                              facebookUrl: user.facebookUrl,
                              instagramUrl: user.instagramUrl,
                              tiktokUrl: user.tiktokUrl,
                              onEditLinks: (facebook, instagram, tiktok) {
                                context.read<ProfileBloc>().add(
                                  UpdateProfessionalProfileEvent(
                                    facebookUrl: facebook,
                                    instagramUrl: instagram,
                                    tiktokUrl: tiktok,
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                if (state is ProfileError) {
                  return Center(child: Text(state.message));
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}
