import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final bool isUrgencyModeActive; // Nuevo estado para el modo urgencia
  final ValueChanged<bool>
  onToggleAvailability; // Callback para cambiar disponibilidad
  final ValueChanged<bool>
  onToggleUrgencyMode; // Callback para cambiar el modo urgencia

  const AvailabilityWidget({
    super.key,
    required this.isAvailable,
    required this.isUrgencyModeActive,
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

    // Uso del sistema de colores definido en el proyecto
    final activeColor =
        AppColors.availabilityActive; // Sustituye tu color hardcodeado
    final inactiveColor = AppColors.gray;
    final urgencyColor = AppColors.errorRed; // Color rojo para modo urgencia

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
          vertical: isSmallScreen ? 10 : 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _buildIcon(
                  isSmallScreen,
                  activeColor,
                  inactiveColor,
                  colorScheme,
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
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
                  activeTrackColor: activeColor,
                ),
              ],
            ),
            SizedBox(height: 16), // Espacio entre los switches
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                  decoration: BoxDecoration(
                    color: (isUrgencyModeActive ? urgencyColor : inactiveColor),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/icon/icons_F28C28/alert.svg', // Cambia el ícono según sea necesario
                    width: isSmallScreen ? 16 : 20,
                    height: isSmallScreen ? 16 : 20,
                    colorFilter: ColorFilter.mode(
                      isUrgencyModeActive ? urgencyColor : inactiveColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
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
                        'Atiende casos urgentes por un valor extra',
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
                  activeTrackColor: urgencyColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(
    bool isSmall,
    Color active,
    Color inactive,
    ColorScheme scheme,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 6 : 8),
      decoration: BoxDecoration(
        color: (isAvailable ? active : inactive),
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        'assets/icon/icons_F28C28/dialog.svg',
        width: isSmall ? 16 : 20,
        height: isSmall ? 16 : 20,
        colorFilter: ColorFilter.mode(
          isAvailable ? active : inactive,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
