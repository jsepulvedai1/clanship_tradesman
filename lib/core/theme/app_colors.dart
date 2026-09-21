import 'package:flutter/material.dart';

class AppColors {
  // Brand Defaults (Official Corporate Colors)
  static const Color defaultPrimaryBlue = Color(0xFF0D2B45); // Deep Blue
  static const Color defaultPrimaryAzure = Color(0xFF0B6E4F); // Green (#0B6E4F)
  static const Color defaultAccentCyan = Color(0xFFF28C28); // Orange (#F28C28)

  // Mutable overrides for dynamic remote seasonal theming
  static Color _primaryBlue = defaultPrimaryBlue;
  static Color _primaryAzure = defaultPrimaryAzure;
  static Color _accentCyan = defaultAccentCyan;

  // Dynamic getters
  static Color get primaryBlue => _primaryBlue;
  static Color get primaryAzure => _primaryAzure;
  static Color get accentCyan => _accentCyan;

  // Semantic aliases for consistency
  static Color get primary => _primaryAzure;
  static Color get secondary => _primaryBlue;
  static Color get accent => _accentCyan;

  static void setSeasonalOverrides({
    Color? primary,
    Color? secondary,
    Color? accent,
  }) {
    if (primary != null) _primaryAzure = primary;
    if (secondary != null) _primaryBlue = secondary;
    if (accent != null) _accentCyan = accent;
  }

  static void resetDefaults() {
    _primaryAzure = defaultPrimaryAzure;
    _primaryBlue = defaultPrimaryBlue;
    _accentCyan = defaultAccentCyan;
  }

  // Other brand colors
  static const Color availabilityGreen = Color(0xFF13D934); // Green
  static const Color textDark = Color(0xFF2E3135); // Graphite Grey
  static const Color gray = Color(0xFF323437);

  // Neutral Colors (Dark/True Black)
  static const Color trueBlack = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF121212);
  static const Color surfaceGrey = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF1A1A1A);

  // Neutral Colors (Light)
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F7);
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color cardLight = Color(0xFFF8F8F8);
  static const Color smokeWhite = Color(0xFFF7F7F5);

  // Semantic Colors (Stats)
  static const Color statsGreen = Color(0xFF00C853);
  static Color get statsBlue => _primaryAzure;
  static const Color statsRed = Color(0xFFFF5252);
  static const Color statsOrange = Color(0xFFFFAB40);
  static const Color availabilityActive = Color.fromARGB(221, 2, 122, 24);

  // Other Semantic Colors
  static const Color starGold = Color(0xFFFFD740);
  static const Color errorRed = Color(0xFFFF5252);
  static const Color successGreen = Color(0xFF4CAF50);

  // Helper for Gradients
  static List<Color> get logoGradient => [primaryBlue, primaryAzure];
}
