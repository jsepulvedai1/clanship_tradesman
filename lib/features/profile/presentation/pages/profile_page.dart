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
import '../widgets/service_tags_section.dart';
import '../widgets/section_header.dart';
import '../widgets/services_header_banner.dart';
import '../widgets/working_radius_section.dart';
import '../widgets/profile_skeleton.dart';
import '../widgets/social_link_section.dart';
import '../widgets/profile_action_button.dart';
import 'documents_page.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
                TextField(
                  controller: rateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tarifa por hora (\$)',
                    hintText: 'Ej: 15000',
                  ),
                ),
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

  void _showSpecialtiesDialog(
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

    List<String> selectedIds = user.specialties
        .map((s) => s['id']?.toString() ?? '')
        .toList();
    String? selectedPrincipalId = user.specialtyId;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDark ? AppColors.cardDark : Colors.white,
              title: const Text(
                'Seleccionar Especialidades',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Marca las especialidades que dominas y selecciona la estrella de tu especialidad principal.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableSpecialties.length,
                        itemBuilder: (context, index) {
                          final specialty = availableSpecialties[index];
                          final id = specialty['id']?.toString() ?? '';
                          final name = specialty['name'] ?? '';
                          final iconUrl = specialty['iconUrl']?.toString();
                          final isSelected = selectedIds.contains(id);
                          final isPrincipal = selectedPrincipalId == id;

                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Row(
                              children: [
                                if (iconUrl != null && iconUrl.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Image.network(
                                      iconUrl,
                                      width: 24,
                                      height: 24,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.work_outline,
                                                size: 24,
                                              ),
                                    ),
                                  )
                                else
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Icon(Icons.work_outline, size: 24),
                                  ),
                                Expanded(child: Text(name)),
                              ],
                            ),
                            value: isSelected,
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  selectedIds.add(id);
                                  selectedPrincipalId ??= id;
                                } else {
                                  selectedIds.remove(id);
                                  if (selectedPrincipalId == id) {
                                    selectedPrincipalId = selectedIds.isNotEmpty
                                        ? selectedIds.first
                                        : null;
                                  }
                                }
                              });
                            },
                            secondary: isSelected
                                ? IconButton(
                                    icon: Icon(
                                      isPrincipal
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: isPrincipal
                                          ? Colors.amber
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedPrincipalId = id;
                                      });
                                    },
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
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
                    if (selectedIds.isNotEmpty && selectedPrincipalId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Debes seleccionar una especialidad principal',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    context.read<ProfileBloc>().add(
                      UpdateProfessionalProfileEvent(
                        specialtyId: selectedPrincipalId,
                        specialtyIds: selectedIds,
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
      },
    );
  }

  void _showTagsDialog(
    BuildContext context,
    UserEntity user,
    List<Map<String, dynamic>> availableTags,
  ) {
    if (availableTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cargando etiquetas de servicio...')),
      );
      context.read<ProfileBloc>().add(LoadTagsEvent());
      return;
    }

    final selectedTagNames = List<String>.from(user.serviceTags);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDark ? AppColors.cardDark : Colors.white,
              title: const Text(
                'Seleccionar Etiquetas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableTags.map((tag) {
                    final name = tag['name'] as String;
                    final isSelected = selectedTagNames.contains(name);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(name),
                      selectedColor: AppColors.primaryBlue,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            if (selectedTagNames.length < 6) {
                              selectedTagNames.add(name);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Máximo de 6 etiquetas de servicios.',
                                  ),
                                ),
                              );
                            }
                          } else {
                            selectedTagNames.remove(name);
                          }
                        });
                      },
                    );
                  }).toList(),
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
                    final tagIds = availableTags
                        .where((t) => selectedTagNames.contains(t['name']))
                        .map((t) => t['id'] as String)
                        .toList();
                    context.read<ProfileBloc>().add(
                      UpdateProfessionalProfileEvent(tagIds: tagIds),
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
    if (pickedFile != null) {
      context.read<ProfileBloc>().add(AddPortfolioPhotoEvent(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileBloc>()..add(LoadProfileData()),
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.trueBlack
            : AppColors.smokeWhite,
        body: BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) {
            if (previous is ProfileLoaded && current is ProfileLoaded) {
              return previous.isAvatarUploading &&
                  !current.isAvatarUploading &&
                  previous.user.profileImageUrl != current.user.profileImageUrl;
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
                        padding: const EdgeInsets.only(bottom: 40),
                        children: [
                          SectionHeader(title: l10n.profileWhoAmI),
                          SubscriptionBanner(
                            planName: user.planName,
                            daysRemaining: user.daysRemaining,
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
                          BioSection(
                            biography: user.biography,
                            hourlyRate: user.hourlyRate,
                            onEditTap: () => _showEditBioDialog(context, user),
                          ),
                          const SizedBox(height: 24),
                          Stack(
                            children: [
                              PortfolioGallery(
                                portfolioPhotos: user.portfolioPhotos,
                                onAddTap: () {
                                  if (user.portfolioPhotos.length >= 8) {
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                          const SizedBox(height: 20),
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
                          ProfileActionButton(
                            title: l10n.profileClientReviews,
                            onTap: () => print('Ver valoraciones'),
                          ),
                          ProfileActionButton(
                            title: l10n.profileViewDocuments,
                            isSecondary: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DocumentsPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Mis Especialidades',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => _showSpecialtiesDialog(
                                        context,
                                        user,
                                        state.availableSpecialties,
                                      ),
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text('Editar'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (user.specialties.isEmpty)
                                  const Text(
                                    'No has seleccionado especialidades.',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: user.specialties.map((spec) {
                                      final isPrincipal =
                                          spec['id']?.toString() ==
                                          user.specialtyId;
                                      final iconUrl = spec['iconUrl']
                                          ?.toString();
                                      return Chip(
                                        avatar:
                                            iconUrl != null &&
                                                iconUrl.isNotEmpty
                                            ? CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                  iconUrl,
                                                ),
                                                backgroundColor:
                                                    Colors.transparent,
                                              )
                                            : const Icon(
                                                Icons.work_outline,
                                                size: 16,
                                              ),
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(spec['name'] ?? ''),
                                            if (isPrincipal) ...[
                                              const SizedBox(width: 4),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.successGreen,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'Principal',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        backgroundColor: isPrincipal
                                            ? AppColors.primaryBlue.withOpacity(
                                                0.1,
                                              )
                                            : Colors.grey.withOpacity(0.1),
                                        side: BorderSide(
                                          color: isPrincipal
                                              ? AppColors.primaryBlue
                                              : Colors.grey.shade300,
                                          width: isPrincipal ? 1.5 : 1.0,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const ServicesHeaderBanner(),
                          ServiceTagsSection(
                            tags: user.serviceTags,
                            primaryTag: user.serviceTags.isNotEmpty
                                ? user.serviceTags.first
                                : null,
                            onPrimaryTap: (tagName) {
                              final currentTags = List<String>.from(
                                user.serviceTags,
                              );
                              if (currentTags.remove(tagName)) {
                                currentTags.insert(0, tagName);

                                final newTagIds = currentTags
                                    .map((name) {
                                      final tagObj = state.availableTags
                                          .firstWhere(
                                            (t) => t['name'] == name,
                                            orElse: () => <String, dynamic>{},
                                          );
                                      return tagObj['id']?.toString() ?? '';
                                    })
                                    .where((id) => id.isNotEmpty)
                                    .toList();

                                context.read<ProfileBloc>().add(
                                  UpdateProfessionalProfileEvent(
                                    tagIds: newTagIds,
                                  ),
                                );
                              }
                            },
                            onSearchTap: () => _showTagsDialog(
                              context,
                              user,
                              state.availableTags,
                            ),
                            onDeleteTap: (tagName) {
                              final remainingTagIds = state.availableTags
                                  .where(
                                    (t) =>
                                        user.serviceTags.contains(t['name']) &&
                                        t['name'] != tagName,
                                  )
                                  .map((t) => t['id'] as String)
                                  .toList();
                              context.read<ProfileBloc>().add(
                                UpdateProfessionalProfileEvent(
                                  tagIds: remainingTagIds,
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
    );
  }
}
