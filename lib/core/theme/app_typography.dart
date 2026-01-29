import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App typography - Calm, readable fonts
class AppTypography {
  AppTypography._();

  // Font Families
  // TODO: Replace with custom fonts when added
  // static const String fontFamilyEn = 'Inter';
  // static const String fontFamilyAr = 'Amiri';
  static const String fontFamilyEn = 'Roboto'; // Default for now
  static const String fontFamilyAr = 'Roboto'; // Default for now

  // Get font family based on locale
  static String getFontFamily(String languageCode) {
    return languageCode == 'ar' ? fontFamilyAr : fontFamilyEn;
  }

  // Headline Styles
  static TextStyle headline1(String languageCode) => TextStyle(
        fontFamily: getFontFamily(languageCode),
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle headline2(String languageCode) => TextStyle(
        fontFamily: getFontFamily(languageCode),
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle headline3(String languageCode) => TextStyle(
        fontFamily: getFontFamily(languageCode),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  // Body Styles
  static TextStyle bodyLarge(String languageCode) => TextStyle(
        fontFamily: getFontFamily(languageCode),
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle bodyMedium(String languageCode) => TextStyle(
        fontFamily: getFontFamily(languageCode),
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle bodySmall(String languageCode) => TextStyle(
        fontFamily: getFontFamily(languageCode),
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // Caption & Label
  static TextStyle caption(String languageCode) => TextStyle(
        fontFamily: getFontFamily(languageCode),
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 1.4,
      );

  static TextStyle label(String languageCode) => TextStyle(
        fontFamily: getFontFamily(languageCode),
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // Button Text
  static TextStyle button(String languageCode) => TextStyle(
        fontFamily: getFontFamily(languageCode),
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
        height: 1.2,
      );

  // Blessing Card Text
  static TextStyle blessingText(String languageCode) => TextStyle(
        fontFamily: getFontFamily(languageCode),
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.6,
      );
}
