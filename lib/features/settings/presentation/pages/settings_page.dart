import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/pages/documents_page.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/pages/rejection_review_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/pages/login_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:clanship_mobile_tradesman/core/theme/bloc/language_bloc.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/bloc/profile_bloc.dart';
import 'personal_info_page.dart';
import 'my_plan_page.dart';
import 'support_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _isAvatarLoading = false;
  String _appVersion = '1.0.3';
  String _buildNumber = '8';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = info.version;
          _buildNumber = info.buildNumber;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickAvatar() async {
    if (_isAvatarLoading) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 60,
    );

    if (image == null || !mounted) return;

    setState(() {
      _isAvatarLoading = true;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final currentUser = authState.user;

        final file = File(image.path);
        final bytes = await file.readAsBytes();
        final base64Image = base64Encode(bytes);

        final updateUseCase = di.sl<UpdateProfileUseCase>();
        final result = await updateUseCase(
          UpdateProfileParams(
            firstName: currentUser.firstName ?? '',
            lastName: currentUser.lastName ?? '',
            email: currentUser.email,
            avatarBase64: base64Image,
          ),
        );

        result.fold(
          (failure) {
            if (mounted) {
              final l10n = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.settingsAvatarUploadError),
                ),
              );
            }
          },
          (updatedUserEntity) {
            if (mounted) {
              final l10n = AppLocalizations.of(context)!;
              // Actualizar AuthBloc global
              final updatedUser = currentUser.copyWith(
                avatarPath: updatedUserEntity.profileImageUrl,
              );
              context.read<AuthBloc>().add(ProfileUpdated(updatedUser));

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.settingsAvatarUploadSuccess),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            }
          },
        );
      } else {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.settingsNotAuthenticatedError)),
          );
        }
      }
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.settingsAvatarProcessError)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAvatarLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final langState = context.watch<LanguageBloc>().state;
    final currentLocale = langState.locale;

    return Scaffold(
      backgroundColor: isDark ? AppColors.trueBlack : AppColors.smokeWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.settingsTitle,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(isDark),
            const SizedBox(height: 32),

            _SettingsSection(
              title: l10n.settingsSectionAccount,
              items: [
                _SettingsItem(
                  icon: Icons.person_outline_rounded,
                  title: l10n.settingsPersonalInfo,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PersonalInfoPage(),
                      ),
                    );
                  },
                ),

                _SettingsItem(
                  icon: Icons.desktop_windows_outlined,
                  title: l10n.settingsMyPlan,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (_) => di.sl<ProfileBloc>(),
                          child: const MyPlanPage(),
                        ),
                      ),
                    );
                  },
                ),
                _SettingsItem(
                  icon: Icons.folder_open_rounded,
                  title: l10n.settingsMyDocs,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DocumentsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),

            _SettingsSection(
              title: l10n.settingsSectionPreferences,
              items: [
                _SettingsItem(
                  icon: Icons.verified_user_outlined,
                  title: l10n.settingsVerificationStatus,
                  trailing: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      bool isValidated = false;
                      bool isRejected = false;
                      if (authState is AuthAuthenticated) {
                        isValidated = authState.user.isValidated;
                        isRejected = authState.user.isRejected;
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isValidated
                                  ? Colors.green.shade100
                                  : (isRejected ? Colors.red.shade100 : Colors.amber.shade100),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isValidated
                                  ? l10n.settingsStatusValidated
                                  : (isRejected ? l10n.settingsStatusRejected : l10n.settingsStatusInProcess),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isValidated
                                    ? Colors.green.shade800
                                    : (isRejected ? Colors.red.shade900 : Colors.amber.shade900),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: (isDark ? Colors.white : AppColors.textDark).withValues(alpha: 0.24),
                          ),
                        ],
                      );
                    },
                  ),
                  onTap: () {
                    final authState = context.read<AuthBloc>().state;
                    bool isValidated = false;
                    bool isRejected = false;
                    String rejectionReason = '';
                    if (authState is AuthAuthenticated) {
                      isValidated = authState.user.isValidated;
                      isRejected = authState.user.isRejected;
                      rejectionReason = authState.user.effectiveRejectionReason;
                    }
                    _showValidationStatusModal(context, isValidated, isRejected, rejectionReason);
                  },
                ),

                _SettingsItem(
                  icon: Icons.language_rounded,
                  title: l10n.settingsChooseLanguage,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentLocale.languageCode == 'es'
                            ? 'Español'
                            : (currentLocale.languageCode == 'fr' ? 'Français' : 'English'),
                        style: TextStyle(
                          fontSize: 14,
                          color: (isDark ? Colors.white : AppColors.textDark)
                              .withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: (isDark ? Colors.white : AppColors.textDark)
                            .withOpacity(0.24),
                      ),
                    ],
                  ),
                  onTap: () => _showLanguagePicker(
                    context,
                    currentLocale,
                    Theme.of(context),
                    l10n,
                  ),
                ),
                _SettingsItem(
                  icon: Icons.dark_mode_outlined,
                  title: l10n.settingsDarkMode,
                  iconColor: AppColors.accentCyan,
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: (val) => setState(() => _isDarkMode = val),
                    activeColor: AppColors.primaryAzure,
                  ),
                ),
              ],
            ),

            _SettingsSection(
              title: l10n.settingsSectionOtherSecurity,
              items: [
                _SettingsItem(
                  icon: Icons.support_agent_rounded,
                  title: l10n.settingsSupport,
                  iconColor: AppColors.primaryAzure,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SupportPage(),
                      ),
                    );
                  },
                ),
                _SettingsItem(
                  icon: Icons.flag_outlined,
                  title: l10n.settingsReportContent,
                  iconColor: AppColors.primaryAzure,
                  onTap: () => _showReportContentDialog(context),
                ),
                _SettingsItem(
                  icon: Icons.info_outline_rounded,
                  title: l10n.settingsAppVersion,
                  iconColor: AppColors.primaryAzure,
                  trailing: Text(
                    'v$_appVersion ($_buildNumber)',
                    style: TextStyle(
                      fontSize: 14,
                      color: (isDark ? Colors.white : AppColors.textDark).withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _SettingsItem(
                  icon: Icons.logout_rounded,
                  title: l10n.settingsLogout,
                  iconColor: AppColors.errorRed,
                  onTap: () {
                    context.read<AuthBloc>().add(LogoutRequested());
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                ),
                _SettingsItem(
                  icon: Icons.delete_forever_outlined,
                  title: l10n.settingsDeleteAccount,
                  iconColor: AppColors.errorRed,
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 32),
            TextButton(
              onPressed: () async {
                final Uri url = Uri.parse('https://clanship.cl/terminos-y-condiciones');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(
                l10n.settingsTerms,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.settingsFooterVersion(_appVersion, _buildNumber),
              style: TextStyle(
                fontSize: 12,
                color: (isDark ? Colors.white : AppColors.textDark).withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String displayName = l10n.settingsDefaultDisplayName;
        String? email;
        String? avatarPath;

        if (authState is AuthAuthenticated) {
          final user = authState.user;
          avatarPath = user.avatarPath;
          email = user.email;
          if (user.firstName != null && user.firstName!.isNotEmpty) {
            displayName = '${user.firstName} ${user.lastName ?? ''}'.trim();
          } else {
            displayName = user.name;
          }
        }

        ImageProvider? avatarImage;
        if (avatarPath != null && avatarPath.isNotEmpty) {
          if (avatarPath.startsWith('http://') ||
              avatarPath.startsWith('https://')) {
            avatarImage = NetworkImage(avatarPath);
          } else {
            avatarImage = FileImage(File(avatarPath));
          }
        }

        return Column(
          children: [
            GestureDetector(
              onTap: _isAvatarLoading ? null : _pickAvatar,
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 2,
                      ),
                      image: avatarImage != null
                          ? DecorationImage(
                              image: avatarImage,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: avatarImage == null && !_isAvatarLoading
                        ? const Center(
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: 52,
                              color: Color(0xFFBCC5D0),
                            ),
                          )
                        : _isAvatarLoading
                        ? Container(
                            decoration: const BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAzure,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.trueBlack : Colors.white,
                          width: 2.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.primaryBlue,
              ),
            ),
            if (email != null) ...[
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : AppColors.textDark,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed, size: 28),
            const SizedBox(width: 8),
            Text(l10n.settingsDeleteAccountTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          l10n.settingsDeleteAccountBody,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.requestCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.settingsAccountDeletedSuccess),
                  backgroundColor: AppColors.errorRed,
                ),
              );
            },
            child: Text(l10n.settingsDeleteAccountConfirm),
          ),
        ],
      ),
    );
  }

  void _showReportContentDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController detailController = TextEditingController();
    String selectedReason = l10n.settingsReportReasonInappropriate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.settingsReportDialogTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.settingsReportDialogSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...[
                    l10n.settingsReportReasonInappropriate,
                    l10n.settingsReportReasonSpam,
                    l10n.settingsReportReasonPhotoProblem,
                    l10n.settingsReportReasonCopyright,
                    l10n.settingsReportReasonOther,
                  ].map((reason) => RadioListTile<String>(
                        title: Text(reason, style: const TextStyle(fontSize: 14)),
                        value: reason,
                        groupValue: selectedReason,
                        activeColor: AppColors.primaryAzure,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedReason = val);
                          }
                        },
                      )),
                  const SizedBox(height: 8),
                  TextField(
                    controller: detailController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: l10n.settingsReportDetailsHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAzure,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.settingsReportSubmittedSuccess,
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: Text(
                        l10n.settingsReportSubmitBtn,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
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

  void _showValidationStatusModal(BuildContext context, bool isValidated, bool isRejected, String rejectionReason) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isValidated
                          ? Colors.green.shade100
                          : (isRejected ? Colors.red.shade100 : Colors.amber.shade100),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isValidated
                          ? Icons.verified_rounded
                          : (isRejected ? Icons.cancel_rounded : Icons.hourglass_top_rounded),
                      size: 48,
                      color: isValidated
                          ? Colors.green.shade700
                          : (isRejected ? Colors.red.shade700 : const Color(0xFFD97706)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isValidated
                      ? l10n.verificationModalApprovedTitle
                      : (isRejected ? l10n.verificationModalRejectedTitle : l10n.verificationModalPendingTitle),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isValidated
                        ? Colors.green.shade900
                        : (isRejected ? Colors.red.shade900 : const Color(0xFF92400E)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isValidated
                      ? l10n.verificationModalApprovedBody
                      : (isRejected
                          ? l10n.verificationModalRejectedBody(rejectionReason)
                          : l10n.verificationModalPendingBody),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRejected ? const Color(0xFFDC2626) : AppColors.primaryAzure,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    final authState = context.read<AuthBloc>().state;
                    if (isRejected && authState is AuthAuthenticated) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RejectionReviewPage()),
                      );
                    } else {

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DocumentsPage()),
                      );
                    }
                  },
                  icon: Icon(isRejected ? Icons.upload_file_rounded : Icons.folder_open_rounded),
                  label: Text(
                    isValidated
                        ? l10n.verificationModalApprovedBtn
                        : (isRejected ? l10n.verificationModalRejectedBtn : l10n.verificationModalPendingBtn),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  void _showLanguagePicker(
    BuildContext context,
    Locale currentLocale,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.settingsChooseLanguage,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                _buildLanguageOption(
                  context: context,
                  label: 'Español',
                  isSelected: currentLocale.languageCode == 'es',
                  onTap: () {
                    context.read<LanguageBloc>().add(
                      const LanguageChanged(Locale('es')),
                    );
                    Navigator.pop(context);
                  },
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context: context,
                  label: 'English',
                  isSelected: currentLocale.languageCode == 'en',
                  onTap: () {
                    context.read<LanguageBloc>().add(
                      const LanguageChanged(Locale('en')),
                    );
                    Navigator.pop(context);
                  },
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context: context,
                  label: 'Français',
                  isSelected: currentLocale.languageCode == 'fr',
                  onTap: () {
                    context.read<LanguageBloc>().add(
                      const LanguageChanged(Locale('fr')),
                    );
                    Navigator.pop(context);
                  },
                  theme: theme,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryAzure : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? AppColors.primaryAzure.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primaryAzure
                    : theme.colorScheme.onSurface,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryAzure,
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> childrenWithDividers = [];
    for (int i = 0; i < items.length; i++) {
      childrenWithDividers.add(items[i]);
      if (i < items.length - 1) {
        childrenWithDividers.add(
          Divider(
            height: 1,
            thickness: 1,
            color: isDark
                ? Colors.white12
                : Colors.black.withValues(alpha: 0.05),
            indent: 68,
            endIndent: 16,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white38 : AppColors.primaryAzure,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(children: childrenWithDividers),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color resolvedIconColor = iconColor ?? AppColors.primaryAzure;
    final Color resolvedBgColor = resolvedIconColor.withValues(
      alpha: isDark ? 0.18 : 0.1,
    );

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: resolvedBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: resolvedIconColor, size: 20),
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          trailing:
              trailing ??
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark
                    ? AppColors.primaryAzure.withValues(alpha: 0.7)
                    : AppColors.primaryAzure,
              ),
        ),
      ],
    );
  }
}
