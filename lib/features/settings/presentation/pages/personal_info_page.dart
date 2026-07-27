import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/repositories/profile_repository.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/usecases/update_profile_usecase.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    String firstName = '';
    String lastName = '';
    String email = '';
    String address = '';

    if (authState is AuthAuthenticated) {
      firstName = authState.user.firstName ?? '';
      lastName = authState.user.lastName ?? '';
      email = authState.user.email;
      address = authState.user.address ?? '';
    }

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _emailController = TextEditingController(text: email);
    _addressController = TextEditingController(text: address);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final currentUser = authState.user;
        final updateUseCase = di.sl<UpdateProfileUseCase>();
        final profileRepo = di.sl<ProfileRepository>();

        final result = await updateUseCase(
          UpdateProfileParams(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
          ),
        );

        if (_addressController.text.trim().isNotEmpty) {
          await profileRepo.updateProfessionalProfile(
            address: _addressController.text.trim(),
          );
        }

        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lo sentimos, no se pudo guardar los datos.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          (updatedUserEntity) {
            if (mounted) {
              // Actualizar AuthBloc global
              final updatedUser = currentUser.copyWith(
                firstName: updatedUserEntity.firstName,
                lastName: updatedUserEntity.lastName,
                email: updatedUserEntity.email,
                address: updatedUserEntity.address,
              );
              context.read<AuthBloc>().add(ProfileUpdated(updatedUser));

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Información personal guardada con éxito'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
              Navigator.pop(context);
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lo sentimos, hubo un error inesperado.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.trueBlack : AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.trueBlack,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Información Personal',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.trueBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Mantén tus datos actualizados para que los clientes de ClanShip puedan contactarte fácilmente.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Inputs Container Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Nombre (solo lectura)
                          TextFormField(
                            controller: _firstNameController,
                            readOnly: true,
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                            decoration: InputDecoration(
                              labelText: 'Nombre',
                              prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue),
                              filled: true,
                              fillColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                              suffixIcon: const Tooltip(
                                message: 'El nombre no puede ser modificado',
                                child: Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Apellido (solo lectura)
                          TextFormField(
                            controller: _lastNameController,
                            readOnly: true,
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                            decoration: InputDecoration(
                              labelText: 'Apellido',
                              prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue),
                              filled: true,
                              fillColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                              suffixIcon: const Tooltip(
                                message: 'El apellido no puede ser modificado',
                                child: Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Correo electrónico (solo lectura)
                          TextFormField(
                            controller: _emailController,
                            readOnly: true,
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Correo Electrónico',
                              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryBlue),
                              filled: true,
                              fillColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                              suffixIcon: const Tooltip(
                                message: 'El correo no puede ser modificado',
                                child: Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Dirección
                          TextFormField(
                            controller: _addressController,
                            style: TextStyle(color: isDark ? Colors.white : AppColors.trueBlack),
                            decoration: const InputDecoration(
                              labelText: 'Dirección',
                              prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primaryBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Save Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        disabledBackgroundColor: AppColors.primaryBlue.withAlpha(153),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Guardar cambios',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
