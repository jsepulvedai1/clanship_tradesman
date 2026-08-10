import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAvailable = true;
  bool _isUrgencyModeActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AvailabilityWidget(
          isAvailable: _isAvailable,
          isUrgencyModeActive: _isUrgencyModeActive,
          onToggleAvailability: (value) {
            setState(() {
              _isAvailable = value;
            });
          },
          onToggleUrgencyMode: (value) {
            setState(() {
              _isUrgencyModeActive = value;
            });
          },
        ),
      ),
    );
  }
}

class AvailabilityWidget extends StatelessWidget {
  final bool isAvailable;
  final bool isUrgencyModeActive;
  final bool isValidated;
  final ValueChanged<bool> onToggleAvailability;
  final ValueChanged<bool> onToggleUrgencyMode;

  const AvailabilityWidget({
    super.key,
    required this.isAvailable,
    required this.isUrgencyModeActive,
    this.isValidated = true,
    required this.onToggleAvailability,
    required this.onToggleUrgencyMode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 750;

    final activeColor = AppColors.availabilityActive; // Verde disponible
    final urgencyColor = AppColors.errorRed; // Rojo urgencia
    final inactiveBg = theme.brightness == Brightness.dark
        ? Colors.grey.withAlpha(40)
        : Colors.grey.withAlpha(25);
    final inactiveIconColor = theme.brightness == Brightness.dark
        ? Colors.grey[400]!
        : Colors.grey[600]!;

    if (!isValidated) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.shade400, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isSmallScreen ? 14 : 18,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'En proceso de validación',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tu cuenta está siendo revisada por el equipo administrativo. Una vez aprobada podrás activar tu disponibilidad.',
                      style: TextStyle(fontSize: 12, color: Color(0xFFB45309)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isSmallScreen ? 12 : 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Disponibilidad General
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color: isAvailable ? activeColor.withAlpha(35) : inactiveBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    size: isSmallScreen ? 20 : 24,
                    color: isAvailable ? activeColor : inactiveIconColor,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeAvailabilityTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        l10n.homeAvailabilitySubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: isAvailable,
                  onChanged: onToggleAvailability,
                  activeColor: activeColor,
                  activeTrackColor: activeColor.withAlpha(100),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Row 2: Modo Urgencias
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color: isUrgencyModeActive
                        ? urgencyColor.withAlpha(35)
                        : inactiveBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUrgencyModeActive
                        ? Icons.bolt_rounded
                        : Icons.bolt_outlined,
                    size: isSmallScreen ? 22 : 26,
                    color: isUrgencyModeActive
                        ? urgencyColor
                        : inactiveIconColor,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activo Urgencias',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        'Atiende casos urgentes e ingresa una tarifa superior.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: isUrgencyModeActive,
                  onChanged: onToggleUrgencyMode,
                  activeColor: urgencyColor,
                  activeTrackColor: urgencyColor.withAlpha(100),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
