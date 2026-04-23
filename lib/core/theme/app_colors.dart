import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette - Deep medical blue
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryContainer = Color(0xFFD6E4FF);
  static const Color onPrimary = Colors.white;

  // Secondary palette - Health teal
  static const Color secondary = Color(0xFF00897B);
  static const Color secondaryLight = Color(0xFF26A69A);
  static const Color secondaryDark = Color(0xFF00695C);
  static const Color secondaryContainer = Color(0xFFB2DFDB);
  static const Color onSecondary = Colors.white;

  // Accent
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF8A65);

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantLight = Color(0xFFECF0F8);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);

  // Text
  static const Color textDark = Color(0xFF1A1F36);
  static const Color textGray = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textWhite = Colors.white;
  static const Color textOnDark = Color(0xFFE5E7EB);

  // Status colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFED6C02);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF0288D1);
  static const Color infoLight = Color(0xFFE1F5FE);

  // Appointment status colors
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusConfirmed = Color(0xFF10B981);
  static const Color statusCancelled = Color(0xFFEF4444);
  static const Color statusCompleted = Color(0xFF6366F1);
  static const Color statusRescheduled = Color(0xFF8B5CF6);

  // Dividers & borders
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF374151);

  // Shadows
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);

  // Specialty colors (for category pills)
  static const List<Color> specialtyColors = [
    Color(0xFF1565C0), // Cardiology
    Color(0xFF00897B), // General Medicine
    Color(0xFF6A1B9A), // Neurology
    Color(0xFFAD1457), // Gynecology
    Color(0xFFE65100), // Traumatology
    Color(0xFF00838F), // Ophthalmology
    Color(0xFF2E7D32), // Pediatrics
    Color(0xFF4527A0), // Psychiatry
    Color(0xFF1565C0), // Radiology
    Color(0xFF558B2F), // Urology
    Color(0xFF4E342E), // Gastroenterology
    Color(0xFF283593), // Endocrinology
  ];
}
