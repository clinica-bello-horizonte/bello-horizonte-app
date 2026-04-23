import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.poppins();

  // Display
  static TextStyle get displayLarge => _base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get displayMedium => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        letterSpacing: -0.5,
        height: 1.2,
      );

  // Headings
  static TextStyle get h1 => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        letterSpacing: -0.3,
        height: 1.3,
      );

  static TextStyle get h2 => _base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
        height: 1.3,
      );

  static TextStyle get h3 => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
        height: 1.4,
      );

  static TextStyle get h4 => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
        height: 1.4,
      );

  // Body
  static TextStyle get bodyLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
        height: 1.6,
      );

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
        height: 1.6,
      );

  static TextStyle get bodySmall => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textGray,
        height: 1.5,
      );

  // Labels
  static TextStyle get labelLarge => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textGray,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => _base.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textGray,
        letterSpacing: 0.5,
      );

  // Button
  static TextStyle get button => _base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  // Caption
  static TextStyle get caption => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
        height: 1.4,
      );

  // Special
  static TextStyle get greeting => _base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        height: 1.3,
      );

  static TextStyle get sectionTitle => _base.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      );

  static TextStyle get cardTitle => _base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      );

  static TextStyle get cardSubtitle => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textGray,
        height: 1.4,
      );

  static TextStyle get whiteTitle => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  static TextStyle get whiteBody => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.9),
      );

  static TextStyle get price => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  static TextStyle get badge => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );
}
