import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_state.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    String firstName = '';
    String lastName = '';
    String email = '';
    String phone = '';
    String address = '';

    if (authState is AuthAuthenticated) {
      firstName = authState.user.firstName ?? '';
      lastName = authState.user.lastName ?? '';
      email = authState.user.email;
      phone = authState.user.phoneNumber ?? '';
      address = authState.user.address ?? '';
    }

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _emailController = TextEditingController(text: email);
    _phoneController = TextEditingController(text: phone);
    _addressController = TextEditingController(text: address);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Widget _buildReadOnlyField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    required bool isDark,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          readOnly: true,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(prefixIcon, color: AppColors.primaryBlue),
            hintText: hintText,
            filled: true,
            fillColor: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
            suffixIcon: const Tooltip(
              message: 'Este campo no puede ser modificado',
              child: Icon(Icons.lock_outline_rounded, size: 18, color: Colors.grey),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
            ),
          ),
        ),
      ],
    );
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Consulta tus datos personales como profesional registrado. Todos los campos están bloqueados por seguridad.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              
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
                    _buildReadOnlyField(
                      context: context,
                      label: 'Nombre',
                      controller: _firstNameController,
                      prefixIcon: Icons.person_outline_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),
                    _buildReadOnlyField(
                      context: context,
                      label: 'Apellido',
                      controller: _lastNameController,
                      prefixIcon: Icons.person_outline_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),
                    _buildReadOnlyField(
                      context: context,
                      label: 'Correo Electrónico',
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),
                    _buildReadOnlyField(
                      context: context,
                      label: 'Número de Teléfono',
                      controller: _phoneController,
                      prefixIcon: Icons.phone_outlined,
                      isDark: isDark,
                      hintText: 'No registrado',
                    ),
                    const SizedBox(height: 18),
                    _buildReadOnlyField(
                      context: context,
                      label: 'Dirección',
                      controller: _addressController,
                      prefixIcon: Icons.location_on_outlined,
                      isDark: isDark,
                      hintText: 'No registrada',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Security Info Notice Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_rounded, color: AppColors.primaryBlue, size: 24),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Tus datos personales no pueden ser editados directamente. Si necesitas cambiar algún dato, por favor contacta al equipo de soporte.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
