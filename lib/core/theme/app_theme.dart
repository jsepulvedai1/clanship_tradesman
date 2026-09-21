import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData buildLightTheme({
    Color? primary,
    Color? secondary,
    Color? accent,
  }) {
    final effectivePrimaryBlue = secondary ?? AppColors.primaryBlue;
    final effectivePrimaryAzure = primary ?? AppColors.primaryAzure;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightGrey,
      textTheme: AppTypography.getTextTheme(Brightness.light),
      colorScheme: ColorScheme.light(
        primary: effectivePrimaryBlue,
        secondary: effectivePrimaryAzure,
        surface: AppColors.pureWhite,
        onSurface: AppColors.textDark,
        onPrimary: AppColors.pureWhite,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pureWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: effectivePrimaryBlue, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: effectivePrimaryBlue,
          foregroundColor: AppColors.pureWhite,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData buildDarkTheme({
    Color? primary,
    Color? secondary,
    Color? accent,
  }) {
    final effectivePrimaryAzure = primary ?? AppColors.primaryAzure;
    final effectivePrimaryBlue = secondary ?? AppColors.primaryBlue;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.trueBlack,
      textTheme: AppTypography.getTextTheme(Brightness.dark),
      colorScheme: ColorScheme.dark(
        primary: effectivePrimaryAzure,
        secondary: effectivePrimaryBlue,
        surface: AppColors.darkGrey,
        onSurface: AppColors.pureWhite,
        onPrimary: AppColors.trueBlack,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.trueBlack,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: effectivePrimaryAzure, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: effectivePrimaryAzure,
          foregroundColor: AppColors.pureWhite,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get lightTheme => buildLightTheme();
  static ThemeData get darkTheme => buildDarkTheme();
}
