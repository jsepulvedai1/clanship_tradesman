import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Vibrant/Action)
  static const Color primaryBlue = Color(0xFF0D2B45); // Deep Blue
  static const Color primaryAzure = Color(0xFF0B6E4F); // Green
  static const Color accentCyan = Color(0xFFF28C28); // Orange
  static const Color textDark = Color(0xFF2E3135); // Graphite Grey

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
  static const Color statsBlue = Color(0xFF0B6E4F);
  static const Color statsRed = Color(0xFFFF5252);
  static const Color statsOrange = Color(0xFFFFAB40);
  static const Color availabilityActive = Color.fromARGB(221, 19, 217, 52);

  // Other Semantic Colors
  static const Color starGold = Color(0xFFFFD740);
  static const Color errorRed = Color(0xFFFF5252);
  static const Color successGreen = Color(0xFF4CAF50);

  // Helper for Gradients
  static const List<Color> logoGradient = [primaryBlue, primaryAzure];
}
