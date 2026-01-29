import 'package:flutter/material.dart';

/// App color palette - Calm, spiritual, minimalist
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryGreen = Color(0xFF7CB77C);
  static const Color primaryGreenLight = Color(0xFFA8D5A8);
  static const Color primaryGreenDark = Color(0xFF5A9A5A);

  // Background Colors
  static const Color backgroundBeige = Color(0xFFF5F1EB);
  static const Color backgroundWhite = Color(0xFFFEFEFE);
  static const Color backgroundCard = Color(0xFFFFFFFF);

  // Accent Colors
  static const Color accentGold = Color(0xFFD4A853);
  static const Color accentGoldLight = Color(0xFFE8C97D);

  // Text Colors
  static const Color textPrimary = Color(0xFF3C4043);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textMuted = Color(0xFF9AA0A6);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFFB74D);

  // Overlay Colors
  static const Color overlayDark = Color(0x80000000);
  static const Color overlayLight = Color(0x40FFFFFF);

  // Gradient Colors
  static const List<Color> blessingGradient = [
    Color(0xFF7CB77C),
    Color(0xFF5A9A5A),
  ];

  static const List<Color> calmGradient = [
    Color(0xFFF5F1EB),
    Color(0xFFE8E4DE),
  ];

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
