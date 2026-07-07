import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme getTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.pureWhite : AppColors.textDark;
    final secondaryColor = isDark ? Colors.white70 : Colors.grey[600]!;

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'RymanEco',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: baseColor,
        letterSpacing: -1.0,
      ),
      displayMedium: TextStyle(
        fontFamily: 'RymanEco',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: baseColor,
        letterSpacing: -0.5,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'RymanEco',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'RymanEco',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: secondaryColor,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: secondaryColor,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
    );
  }
}
