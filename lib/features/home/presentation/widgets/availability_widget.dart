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
  final bool isRejected;
  final String? rejectionReason;
  final VoidCallback? onReuploadDocuments;
  final ValueChanged<bool> onToggleAvailability;
  final ValueChanged<bool> onToggleUrgencyMode;

  const AvailabilityWidget({
    super.key,
    required this.isAvailable,
    required this.isUrgencyModeActive,
    this.isValidated = true,
    this.isRejected = false,
    this.rejectionReason,
    this.onReuploadDocuments,
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

    if (isRejected) {
      final isDark = theme.brightness == Brightness.dark;
      final reason = (rejectionReason != null && rejectionReason!.trim().isNotEmpty)
          ? rejectionReason!
          : 'Tus antecedentes o documentos fueron observados por el equipo de administración.';

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF450A0A).withValues(alpha: 0.35) : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF87171), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cancel_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeRejectedValidationTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.homeRejectedValidationSubtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : const Color(0xFF7F1D1D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF991B1B) : const Color(0xFFFECACA),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.homeRejectedReasonLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      reason,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (onReuploadDocuments != null) ...[
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: onReuploadDocuments,
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: Text(
                    l10n.homeRejectedReuploadBtn,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

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
                  children: [
                    Text(
                      l10n.homePendingValidationTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.homePendingValidationMessage,
                      style: const TextStyle(fontSize: 12, color: Color(0xFFB45309)),
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
