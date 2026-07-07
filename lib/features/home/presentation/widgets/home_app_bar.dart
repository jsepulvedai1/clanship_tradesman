import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import '../../domain/entities/user_entity.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserEntity user;
  final VoidCallback? onSyncTap;
  final VoidCallback? onAvatarTap;
  final bool isAvatarUploading;

  const HomeAppBar({
    super.key,
    required this.user,
    this.onSyncTap,
    this.onAvatarTap,
    this.isAvatarUploading = false,
  });

  String _toTitleCase(String text) {
    if (text.isEmpty) return '';
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : const Color(0xFF2E3135);
    final Color nameColor = isDark ? Colors.white : const Color(0xFF0D2B45);

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(color: Color(0xFFF7F7F5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LADO IZQUIERDO: Saludo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.homeWelcomePrefix,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_toTitleCase(user.name)}!',
                style: TextStyle(
                  color: nameColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // LADO DERECHO: Notificaciones (dialog.svg) & Foto Perfil
          Row(
            children: [
              // Icono Notificación (dialog.svg) con punto verde
              GestureDetector(
                onTap: onSyncTap,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icon/icons_ F28C28/bell.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF0D2B45),
                          BlendMode.srcIn,
                        ),
                      ),
                      // Punto verde (Notificación activa)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0B6E4F),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Foto de Perfil
              GestureDetector(
                onTap: isAvatarUploading ? null : onAvatarTap,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFF0D2B45),
                          width: 1.5,
                        ),
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
                                    : FileImage(File(user.profileImageUrl!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child:
                          user.profileImageUrl == null ||
                              user.profileImageUrl!.isEmpty
                          ? const Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFF0D2B45),
                              size: 22,
                            )
                          : null,
                    ),
                    if (isAvatarUploading)
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
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
