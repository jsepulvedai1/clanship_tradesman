import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/bloc/profile_event.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/bloc/profile_state.dart';
import 'package:clanship_mobile_tradesman/core/utils/image_cropper_helper.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserEntity user;
  final VoidCallback? onSyncTap;

  const ProfileAppBar({super.key, required this.user, this.onSyncTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.pureWhite.withAlpha(20)
                : AppColors.trueBlack.withAlpha(20),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LADO IZQUIERDO: Logo & Saludo
          Row(
            children: [
              // Texto de Bienvenida (Logo removed)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.homeWelcomePrefix,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.pureWhite.withValues(alpha: 0.7)
                          : AppColors.textDark.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${user.name}!',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.pureWhite
                          : AppColors.primaryBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // LADO DERECHO: Sincronización, Configuración & Foto Perfil
          Row(
            children: [
              // Icono Sincronización
              const SizedBox(width: 4),
              // Foto de Perfil
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  final isUploading =
                      state is ProfileLoaded && state.isAvatarUploading;

                  return GestureDetector(
                    onTap: isUploading
                        ? null
                        : () async {
                            final picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 800,
                              maxHeight: 800,
                              imageQuality: 60,
                            );
                            if (image != null && context.mounted) {
                              final croppedPath = await ImageCropperHelper.cropImage(
                                imagePath: image.path,
                                isSquare: true,
                              );
                              if (croppedPath != null && context.mounted) {
                                context.read<ProfileBloc>().add(
                                  UploadAvatarEvent(croppedPath),
                                );
                              }
                            }
                          },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: accentColor, width: 2),
                            image:
                                user.profileImageUrl != null &&
                                    user.profileImageUrl!.isNotEmpty
                                ? DecorationImage(
                                    image:
                                        (user.profileImageUrl!.startsWith(
                                              'http://',
                                            ) ||
                                            user.profileImageUrl!.startsWith(
                                              'https://',
                                            ))
                                        ? NetworkImage(user.profileImageUrl!)
                                              as ImageProvider
                                        : FileImage(
                                            File(user.profileImageUrl!),
                                          ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child:
                              user.profileImageUrl == null ||
                                  user.profileImageUrl!.isEmpty
                              ? Icon(
                                  Icons.person,
                                  color: isDark
                                      ? AppColors.pureWhite
                                      : AppColors.trueBlack,
                                )
                              : null,
                        ),
                        if (isUploading)
                          Container(
                            width: 45,
                            height: 45,
                            decoration: const BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
