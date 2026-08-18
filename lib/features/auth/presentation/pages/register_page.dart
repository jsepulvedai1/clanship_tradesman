import 'dart:io';
import 'package:clanship_mobile_tradesman/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_mobile_tradesman/features/navigation/presentation/pages/main_shell_page.dart';
import 'package:clanship_mobile_tradesman/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:clanship_mobile_tradesman/core/widgets/address_picker_page.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/core/utils/image_cropper_helper.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/repositories/auth_repository.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/widgets/tradesman_subtags_sheet.dart';
import 'package:clanship_mobile_tradesman/core/utils/lower_case_text_formatter.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 0 Controllers (Datos Personales)
  final _emailController = TextEditingController();
  final _repeatEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthdateController = TextEditingController();


  // Password visibility states
  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;

  // Step 1 Controllers (Dirección y Contacto)
  final _addressController = TextEditingController();
  double? _latitude;
  double? _longitude;
  final _phoneController = TextEditingController();
  bool _acceptedTerms = false;
  bool _isCheckingStep0 = false;
  bool _isCheckingStep1 = false;

  // Step 2 Fields (Biografía y Experiencia)
  final _bioController = TextEditingController();

  // Step 3 Fields (Foto de Perfil y Trabajos)
  String? _avatarPath;
  final List<String> _workPhotoPaths = [];
  final List<String> _selectedSubtagNames = [];

  // Tags
  List<Map<String, dynamic>> _availableTags = [];
  List<String> _selectedSpecialtyIds = [];
  List<String> _selectedTagIds = [];
  List<String> _selectedSubtagIds = [];
  bool _isLoadingTags = false;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() {
      _isLoadingTags = true;
    });
    final result = await di.sl<AuthRepository>().getAvailableTags();
    result.fold(
      (failure) {
        // ignore error
      },
      (tags) {
        if (mounted) {
          setState(() {
            _availableTags = tags;
          });
        }
      },
    );
    if (mounted) {
      setState(() {
        _isLoadingTags = false;
      });
    }
  }

  // Step 3 Fields (Documentos)
  String? _cedulaFrontPath;
  String? _cedulaBackPath;
  final List<Map<String, String>> _certificates = [];

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _repeatEmailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthdateController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Pick Image from Gallery or Camera
  Future<void> _pickAvatarFlow() async {
    final source = await _showImageSourceOptions();
    if (source != null) {
      await _pickImage(source);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 70,
      );
      if (image != null) {
        final croppedPath = await ImageCropperHelper.cropImage(
          imagePath: image.path,
          isSquare: true,
        );
        if (croppedPath != null) {
          setState(() {
            _avatarPath = croppedPath;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.registerPickImageError),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  // Date Picker for Birthdate
  Future<void> _selectBirthdate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime eighteenYearsAgo = DateTime(
      now.year - 18,
      now.month,
      now.day,
    );

    DateTime initialDate = eighteenYearsAgo;
    if (_birthdateController.text.isNotEmpty) {
      try {
        final parsed = DateFormat('dd/MM/yyyy').parseStrict(_birthdateController.text);
        if (!parsed.isAfter(eighteenYearsAgo) && !parsed.isBefore(DateTime(1920))) {
          initialDate = parsed;
        }
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: eighteenYearsAgo,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D2B45),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2E3135),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthdateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Step 0 Validation
  bool _validateStep0() {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim().toLowerCase();
    final repeatEmail = _repeatEmailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final repeatPassword = _repeatPasswordController.text;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final birthdate = _birthdateController.text;

    if (email.isEmpty ||
        repeatEmail.isEmpty ||
        password.isEmpty ||
        repeatPassword.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        birthdate.isEmpty) {
      _showError(l10n.registerErrorFillAll);
      return false;
    }

    // Validar edad >= 18 años
    try {
      final parsedDate = DateFormat('dd/MM/yyyy').parseStrict(birthdate);
      final now = DateTime.now();
      final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
      if (parsedDate.isAfter(eighteenYearsAgo)) {
        _showError(l10n.registerErrorAgeRestriction);
        return false;
      }
    } catch (_) {
      _showError(l10n.registerErrorFillAll);
      return false;
    }

    if (firstName.length > 30) {
      _showError(l10n.registerErrorNameLength);
      return false;
    }

    if (lastName.length > 30) {
      _showError(l10n.registerErrorLastNameLength);
      return false;
    }

    if (email != repeatEmail) {
      _showError(l10n.registerErrorEmailMismatch);
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showError(l10n.registerErrorEmailInvalid);
      return false;
    }

    if (password.length < 6) {
      _showError(l10n.registerErrorPasswordLength);
      return false;
    }

    if (password != repeatPassword) {
      _showError(l10n.registerErrorPasswordMismatch);
      return false;
    }

    return true;
  }


  void _showTagsDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_availableTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.registerLoadingTags)),
      );
      return;
    }


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return TradesmanSubtagsSheet(
          specialties: _availableTags,
          initialSelectedSpecialtyIds: _selectedSpecialtyIds.toSet(),
          initialSelectedTagIds: _selectedTagIds.toSet(),
          initialSelectedSubtagIds: _selectedSubtagIds.toSet(),
          maxSpecialtiesPerTradesman:
              AuthRemoteDataSourceImpl.maxSpecialtiesLimit,
          onSave: (selectedSpecialtyIds, selectedTagIds, selectedSubtagIds) {
            setState(() {
              _selectedSpecialtyIds = selectedSpecialtyIds.toList();
              _selectedTagIds = selectedTagIds.toList();
              _selectedSubtagIds = selectedSubtagIds.toList();
              _updateSelectedSubtagNames();
            });
          },
        );
      },
    );
  }

  // Step 1 Validation
  bool _isStep1FormValid() {
    final phone = _phoneController.text.trim();
    return _addressController.text.trim().isNotEmpty &&
        phone.length == 8 &&
        RegExp(r'^[0-9]{8}$').hasMatch(phone) &&
        (_selectedSpecialtyIds.isNotEmpty ||
            _selectedTagIds.isNotEmpty ||
            _selectedSubtagIds.isNotEmpty) &&
        _acceptedTerms;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _nextPage() {
    FocusScope.of(context).unfocus();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    FocusScope.of(context).unfocus();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.read<NavigationBloc>().add(const TabChanged(0));
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainShellPage()),
              (route) => false,
            );
          } else if (state is AuthFailure) {
            _showError(state.errorMessage);
          }
        },
        child: Stack(
          children: [
            // Bottom-right decorative wave
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 180,
              child: CustomPaint(painter: BottomWavePainter()),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Page indicator dots & Header
                  _buildHeader(),
                  // Form view
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (page) {
                        setState(() {
                          _currentStep = page;
                        });
                      },
                      children: [
                        _buildStep0(), // Correo, Contraseña, Nombre, Fecha Nacimiento
                        _buildStep1(), // Dirección, Teléfono, Especialidades, Términos
                        _buildStep2Bio(), // Biografía & Experiencia Profesional
                        _buildStep3WorkPhotos(), // Foto de Perfil & Fotos de Trabajos Realizados
                        _buildStep3New(), // Documentos (Cédula de Identidad, Certificados)
                        _buildStep3(), // Resumen Perfil & Submit
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateSelectedSubtagNames() {
    _selectedSubtagNames.clear();
    for (final spec in _availableTags) {
      final tags = spec['tags'] as List<dynamic>? ?? [];
      for (final tag in tags) {
        final subtags = tag['subtags'] as List<dynamic>? ?? [];
        for (final subtag in subtags) {
          final subtagId = subtag['id'].toString();
          if (_selectedSubtagIds.contains(subtagId)) {
            _selectedSubtagNames.add(subtag['name'].toString());
          }
        }
      }
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentStep < 5
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Color(0xFF0D2B45),
                  ),
                  onPressed: () {
                    if (_currentStep == 0) {
                      Navigator.of(context).pop();
                    } else {
                      _previousPage();
                    }
                  },
                )
              : const SizedBox(width: 48, height: 48),
          // Page indicator dots
          Row(
            children: List.generate(6, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentStep == index
                      ? const Color(0xFF0D2B45)
                      : const Color(0xFF2E3135).withValues(alpha: 0.2),
                ),
              );
            }),
          ),
          const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }

  Widget _buildLogoHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset('assets/icon/app_icon.jpg', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          l10n.registerTitle,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D2B45),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.registerSubtitle,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E3135),
          ),
        ),
      ],
    );
  }

  // STEP 0: DATOS PERSONALES
  Widget _buildStep0() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLogoHeader(),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _emailController,
            hint: l10n.registerEmailHint,
            keyboardType: TextInputType.emailAddress,
            icon: Icons.mail_outline,
            textCapitalization: TextCapitalization.none,
            inputFormatters: [LowerCaseTextFormatter()],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _repeatEmailController,
            hint: l10n.registerRepeatEmailHint,
            keyboardType: TextInputType.emailAddress,
            icon: Icons.mail_outline,
            textCapitalization: TextCapitalization.none,
            inputFormatters: [LowerCaseTextFormatter()],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _passwordController,
            hint: l10n.registerPasswordHint,
            obscureText: _obscurePassword,
            icon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF2E3135).withValues(alpha: 0.6),
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _repeatPasswordController,
            hint: l10n.registerRepeatPasswordHint,
            obscureText: _obscureRepeatPassword,
            icon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRepeatPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF2E3135).withValues(alpha: 0.6),
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscureRepeatPassword = !_obscureRepeatPassword;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _firstNameController,
            hint: l10n.registerFirstNameHint,
            keyboardType: TextInputType.name,
            icon: Icons.person_outline,
            inputFormatters: [LengthLimitingTextInputFormatter(30)],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _lastNameController,
            hint: l10n.registerLastNameHint,
            keyboardType: TextInputType.name,
            icon: Icons.person_outline,
            inputFormatters: [LengthLimitingTextInputFormatter(30)],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _selectBirthdate(context),
            child: AbsorbPointer(
              child: _buildTextField(
                controller: _birthdateController,
                hint: l10n.registerBirthdateHint,
                icon: Icons.calendar_month_outlined,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Siguiente Button
          SizedBox(
            width: 280,
            height: 48,
            child: ElevatedButton(
              onPressed: _isCheckingStep0
                  ? null
                  : () async {
                      if (_validateStep0()) {
                        setState(() {
                          _isCheckingStep0 = true;
                        });
                        final email = _emailController.text
                            .trim()
                            .toLowerCase();
                        final res = await di
                            .sl<AuthRepository>()
                            .checkUserExistence(email: email);
                        if (mounted) {
                          setState(() {
                            _isCheckingStep0 = false;
                          });
                          res.fold(
                            (failure) {
                              _nextPage();
                            },
                            (data) {
                              if (data['emailExists'] == true) {
                                _showError(
                                  l10n.registerErrorEmailRegistered,
                                );
                              } else {
                                _nextPage();
                              }
                            },
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D2B45),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isCheckingStep0
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.authNext,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 2),
          // Footer terms row with dialog.svg
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icon/icons_ F28C28/dialog.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF0B6E4F),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.registerTermsAgreement,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B6E4F),
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


  int _calculateSelectedCategoriesCount() {
    int count = _selectedSubtagIds.length;
    final userTagIds = _selectedTagIds.toSet();

    for (final spec in _availableTags) {
      final tags = spec['tags'] as List<dynamic>? ?? [];
      for (final tag in tags) {
        final tagId = tag['id']?.toString() ?? '';
        final subtags = tag['subtags'] as List<dynamic>? ?? [];
        if (subtags.isEmpty && userTagIds.contains(tagId)) {
          count++;
        }
      }
    }
    return count;
  }

  // STEP 1: UBICACIÓN Y CONTACTO
  Widget _buildStep1() {
    final l10n = AppLocalizations.of(context)!;
    final bool isValid = _isStep1FormValid();
    final int realCount = _calculateSelectedCategoriesCount();

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            l10n.registerStepLocation,
            style: const TextStyle(
              color: Color(0xFF0D2B45),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.registerStepLocationSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF2E3135), fontSize: 14),
          ),
          const SizedBox(height: 36),
          GestureDetector(
            onTap: _openAddressPicker,
            child: AbsorbPointer(
              child: _buildTextField(
                controller: _addressController,
                hint: l10n.registerAddressHint,
                keyboardType: TextInputType.streetAddress,
                icon: Icons.location_on_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPhoneField(),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                Text(
                  l10n.registerTagsTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D2B45),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  realCount == 0
                      ? l10n.registerTagsEmpty
                      : l10n.registerTagsSelectedCount(realCount),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: realCount == 0 ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoadingTags)
                  const CircularProgressIndicator()
                else
                  OutlinedButton.icon(
                    onPressed: () => _showTagsDialog(context),
                    icon: const Icon(Icons.sell_outlined),
                    label: Text(l10n.registerTagsButton),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0D2B45),
                      side: const BorderSide(color: Color(0xFF0D2B45)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _showTermsDialog,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  onChanged: (val) {
                    setState(() {
                      _acceptedTerms = val ?? false;
                    });
                  },
                  activeColor: const Color(0xFF0D2B45),
                  checkColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF2E3135), width: 1.5),
                ),
                Flexible(
                  child: Text(
                    l10n.registerTermsAccept,
                    style: const TextStyle(
                      color: Color(0xFF0D2B45),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 180,
            height: 48,
            child: ElevatedButton(
              onPressed: (isValid && !_isCheckingStep1)
                  ? () async {
                      setState(() {
                        _isCheckingStep1 = true;
                      });
                      final phone = '+569${_phoneController.text.trim()}';
                      final res = await di
                          .sl<AuthRepository>()
                          .checkUserExistence(phoneNumber: phone);
                      if (mounted) {
                        setState(() {
                          _isCheckingStep1 = false;
                        });
                        res.fold(
                          (failure) {
                            _nextPage();
                          },
                          (data) {
                            if (data['phoneExists'] == true) {
                              _showError(
                                l10n.registerErrorPhoneRegistered,
                              );
                            } else {
                              _nextPage();
                            }
                          },
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D2B45),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(
                  0xFF0D2B45,
                ).withValues(alpha: 0.3),
                disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isCheckingStep1
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.authNext,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3 (NEW): DOCUMENTOS (Cédula y Certificados)
  Widget _buildStep3New() {
    final l10n = AppLocalizations.of(context)!;
    final bool hasCedula = _cedulaFrontPath != null && _cedulaBackPath != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            l10n.registerStepDocs,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0D2B45),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.registerStepDocsSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF2E3135),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          if (!hasCedula) ...[
            Row(
              children: [
                Expanded(
                  child: _buildDocUploadButton(
                    label: _cedulaFrontPath == null
                        ? l10n.registerPhotoFront
                        : l10n.registerPhotoFrontAttached,
                    hasFile: _cedulaFrontPath != null,
                    onTap: () => _pickCedulaPhoto(isFront: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDocUploadButton(
                    label: _cedulaBackPath == null
                        ? l10n.registerPhotoBack
                        : l10n.registerPhotoBackAttached,
                    hasFile: _cedulaBackPath != null,
                    onTap: () => _pickCedulaPhoto(isFront: false),
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildDocUploadButton(
              label: l10n.registerCedulaAttached,
              hasFile: true,
              onTap: () {
                setState(() {
                  _cedulaFrontPath = null;
                  _cedulaBackPath = null;
                });
              },
            ),
          ],
          const SizedBox(height: 32),
          Text(
            l10n.registerTradeProofHint,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF2E3135),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _buildDocUploadButton(
            label: l10n.registerUploadDocsOptional,
            hasFile: false,
            onTap: _addCertificateFlow,
          ),
          if (_certificates.isNotEmpty) ...[
            const SizedBox(height: 16),
            Column(
              children: _certificates.asMap().entries.map((entry) {
                final idx = entry.key;
                final cert = entry.value;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2B45).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF0D2B45),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cert['name'] ?? 'Certificado',
                          style: const TextStyle(
                            color: Color(0xFF2E3135),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFEA4335),
                        ),
                        onPressed: () {
                          setState(() {
                            _certificates.removeAt(idx);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _showTermsDialog,
            child: Text(
              l10n.registerTermsAccept,
              style: const TextStyle(
                color: Color(0xFF0D2B45),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 180,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (hasCedula) {
                  _nextPage();
                } else {
                  _showError(
                    l10n.registerErrorCedulaMissing,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D2B45),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.authNext,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }


  // STEP 2: BIOGRAFÍA Y EXPERIENCIA PROFESIONAL
  Widget _buildStep2Bio() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(
            l10n.registerStepBio,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0D2B45),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.registerStepBioSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF2E3135),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Suggestion Chips
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.registerBioTemplatesTitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                label: const Text(
                  '💡 Electricista Certificado',
                  style: TextStyle(fontSize: 12),
                ),
                onPressed: () {
                  setState(() {
                    _bioController.text = l10n.registerBioElectrician;
                  });
                },
              ),
              ActionChip(
                label: const Text(
                  '🔧 Gasfitería 24/7',
                  style: TextStyle(fontSize: 12),
                ),
                onPressed: () {
                  setState(() {
                    _bioController.text = l10n.registerBioPlumber;
                  });
                },
              ),
              ActionChip(
                label: const Text(
                  '🎨 Pintura y Remodelación',
                  style: TextStyle(fontSize: 12),
                ),
                onPressed: () {
                  setState(() {
                    _bioController.text = l10n.registerBioPainter;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _bioController,
              maxLines: 5,
              maxLength: 400,
              decoration: InputDecoration(
                hintText: l10n.registerBioHint,
                contentPadding: const EdgeInsets.all(16),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: 180,
            height: 48,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D2B45),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.authNext,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // STEP 3: FOTO DE PERFIL Y FOTOS DE TRABAJOS ANTERIORES
  Widget _buildStep3WorkPhotos() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(
            l10n.registerStepPhotos,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0D2B45),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.registerStepPhotosSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF2E3135),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Avatar Section
          InkWell(
            onTap: _pickAvatarFlow,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(
                      0xFF0D2B45,
                    ).withValues(alpha: 0.1),
                    backgroundImage: _avatarPath != null
                        ? FileImage(File(_avatarPath!))
                        : null,
                    child: _avatarPath == null
                        ? const Icon(
                            Icons.person,
                            color: Color(0xFF0D2B45),
                            size: 36,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.registerProfilePhotoTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              l10n.registerProfilePhotoMandatory,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _avatarPath != null
                              ? l10n.registerProfilePhotoUploaded
                              : l10n.registerProfilePhotoDesc,
                          style: TextStyle(
                            fontSize: 12,
                            color: _avatarPath != null
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontWeight: _avatarPath == null
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _avatarPath != null
                          ? Icons.edit_outlined
                          : Icons.add_a_photo_outlined,
                      color: const Color(0xFF0D2B45),
                    ),
                    onPressed: _pickAvatarFlow,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Work Gallery Photos Section
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.registerWorkGalleryTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D2B45),
                  ),
                ),
                Text(
                  l10n.registerWorkPhotosCount(_workPhotoPaths.length),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: _workPhotoPaths.length < 6
                ? _workPhotoPaths.length + 1
                : 6,
            itemBuilder: (context, index) {
              if (index == _workPhotoPaths.length &&
                  _workPhotoPaths.length < 6) {
                return InkWell(
                  onTap: _pickWorkPhoto,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF0D2B45),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Color(0xFF0D2B45),
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.registerAddPhoto,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D2B45),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final photoPath = _workPhotoPaths[index];
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(photoPath),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _workPhotoPaths.removeAt(index);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: 180,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (_avatarPath == null || _avatarPath!.isEmpty) {
                  _showError(
                    l10n.registerErrorAvatarMissing,
                  );
                  return;
                }
                _nextPage();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D2B45),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.authNext,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _pickWorkPhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 75,
      );
      if (image != null) {
        setState(() {
          _workPhotoPaths.add(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showError(l10n.registerPickWorkPhotoError);
      }
    }
  }

  // STEP 5: RESUMEN Y CONFIRMAR REGISTRO
  Widget _buildStep3() {
    final l10n = AppLocalizations.of(context)!;
    final bool hasCedula = _cedulaFrontPath != null && _cedulaBackPath != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.verified_user_rounded,
            size: 64,
            color: Color(0xFF0B6E4F),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.registerStepSummary,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0D2B45),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.registerStepSummarySubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF2E3135),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Profile Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(
                        0xFF0D2B45,
                      ).withValues(alpha: 0.1),
                      backgroundImage: _avatarPath != null
                          ? FileImage(File(_avatarPath!))
                          : null,
                      child: _avatarPath == null
                          ? const Icon(
                              Icons.person,
                              color: Color(0xFF0D2B45),
                              size: 32,
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D2B45),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _emailController.text.trim().toLowerCase(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Especialidades
                Text(
                  l10n.registerSummarySelectedTags,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                _selectedSubtagNames.isNotEmpty
                    ? Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _selectedSubtagNames.map((name) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF0D2B45,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0D2B45),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : const Text(
                        '✓',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0D2B45),
                        ),
                      ),

                const SizedBox(height: 16),

                // Biografía
                Text(
                  l10n.registerSummaryBio,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _bioController.text.trim().isNotEmpty
                      ? _bioController.text.trim()
                      : l10n.registerSummaryNoBio,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2E3135),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Metadatos adicionales
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.registerSummaryWorkPhotos(_workPhotoPaths.length),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.registerSummaryIdCard(
                        hasCedula ? l10n.registerSummaryIdCardLoaded : l10n.registerSummaryIdCardPending,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: hasCedula
                            ? AppColors.successGreen
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const CircularProgressIndicator(
                  color: Color(0xFF0D2B45),
                );
              }

              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_avatarPath == null || _avatarPath!.isEmpty) {
                      _showError(
                        l10n.registerErrorAvatarMissing,
                      );
                      return;
                    }
                    context.read<AuthBloc>().add(
                      RegisterRequested(
                        email: _emailController.text.trim().toLowerCase(),
                        password: _passwordController.text,
                        firstName: _firstNameController.text.trim(),
                        lastName: _lastNameController.text.trim(),
                        birthdate: _birthdateController.text,
                        address: _addressController.text.trim(),
                        phoneNumber: '+569${_phoneController.text.trim()}',
                        avatarPath: _avatarPath,
                        cedulaFrontPath: _cedulaFrontPath,
                        cedulaBackPath: _cedulaBackPath,
                        certificates: _certificates,
                        latitude: _latitude,
                        longitude: _longitude,
                        specialtyIds: _selectedSpecialtyIds,
                        tagIds: _selectedTagIds,
                        subtagIds: _selectedSubtagIds,
                        bio: _bioController.text.trim(),
                        workPhotoPaths: _workPhotoPaths,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D2B45),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.registerCompleteButton,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }


  // HELPER WIDGETS
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Color(0xFF2E3135), fontSize: 14),
        cursorColor: const Color(0xFF0D2B45),
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: TextStyle(
            color: const Color(0xFF2E3135).withValues(alpha: 0.6),
            fontSize: 14,
          ),
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: const Color(0xFF2E3135).withValues(alpha: 0.6),
                  size: 20,
                )
              : null,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0D2B45), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    final l10n = AppLocalizations.of(context)!;
    return Container(

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        maxLength: 8,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(8),
        ],
        style: const TextStyle(color: Color(0xFF2E3135), fontSize: 14),
        cursorColor: const Color(0xFF0D2B45),
        decoration: InputDecoration(
          labelText: l10n.registerPhoneHint,
          labelStyle: TextStyle(
            color: const Color(0xFF2E3135).withValues(alpha: 0.6),
            fontSize: 14,
          ),
          counterText: '',
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 12),
              Icon(
                Icons.phone_outlined,
                color: const Color(0xFF2E3135).withValues(alpha: 0.6),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '+569',
                style: TextStyle(
                  color: Color(0xFF0D2B45),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                width: 1,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: const Color(0xFFE2E8F0),
              ),
            ],
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0D2B45), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDocUploadButton({
    required String label,
    required bool hasFile,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: hasFile
              ? const Color(0xFF0B6E4F).withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile ? const Color(0xFF0B6E4F) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: hasFile
                      ? const Color(0xFF0B6E4F)
                      : const Color(0xFF2E3135),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (hasFile) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF0B6E4F),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickCedulaPhoto({required bool isFront}) async {
    final source = await _showImageSourceOptions();
    if (source != null) {
      try {
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 70,
        );
        if (image != null) {
          setState(() {
            if (isFront) {
              _cedulaFrontPath = image.path;
            } else {
              _cedulaBackPath = image.path;
            }
          });
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          _showError(l10n.registerPickImageError);
        }
      }
    }
  }

  Future<void> _addCertificateFlow() async {
    final source = await _showImageSourceOptions();
    if (source != null) {
      try {
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 70,
        );
        if (image != null) {
          if (mounted) {
            final String? name = await _showDocumentNameDialog();
            if (!mounted) return;
            if (name != null && name.isNotEmpty) {
              setState(() {
                _certificates.add({'path': image.path, 'name': name});
              });
            }
          }
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          _showError(l10n.registerPickImageError);
        }
      }
    }
  }

  Future<ImageSource?> _showImageSourceOptions() async {
    final l10n = AppLocalizations.of(context)!;
    return await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF0D2B45),
                ),
                title: Text(l10n.authCamera),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.image_outlined,
                  color: Color(0xFF0D2B45),
                ),
                title: Text(l10n.authGallery),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _showDocumentNameDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.registerDocNameDialogTitle,
            style: const TextStyle(
              color: Color(0xFF0D2B45),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: l10n.registerDocNameDialogHint,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.commonCancel,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D2B45),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(l10n.commonSave),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openAddressPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddressPickerPage(initialAddress: _addressController.text),
      ),
    );

    if (result != null) {
      setState(() {
        _addressController.text = result['address'] ?? '';
        _latitude = result['latitude'];
        _longitude = result['longitude'];
      });
    }
  }

  void _showTermsDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final Uri url = Uri.parse('https://clanship.cl/terminos-y-condiciones');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.settingsTerms,
            style: const TextStyle(
              color: Color(0xFF0D2B45),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Bienvenido a ClanShip. Al registrarte y utilizar nuestra plataforma de vinculación laboral y servicios técnicos a domicilio, aceptas cumplir los siguientes términos y condiciones:\n\n'
              '1. Uso del Servicio: ClanShip es un intermediario que conecta profesionales con clientes. No nos hacemos responsables de las disputas contractuales o de la calidad del servicio realizado por los maestros independientes.\n\n'
              '2. Registro y Privacidad: Garantizas que toda la información entregada es verídica y que cuentas con la mayoría de edad para contratar servicios.\n\n'
              '3. Cancelaciones y Tarifas: Las tarifas son pactadas directamente entre cliente y profesional, o bien calculadas por el sistema según disponibilidad de viaje.\n\n'
              'Al presionar "Aceptar", declaras conocer y aprobar estos términos de uso.',
              style: TextStyle(color: Color(0xFF2E3135)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.commonCancel,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _acceptedTerms = true;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D2B45),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(l10n.commonAccept),
            ),
          ],
        );
      },
    );
  }
}


class BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0D2B45)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width * 0.5, size.height)
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.6,
        size.width,
        size.height * 0.4,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
