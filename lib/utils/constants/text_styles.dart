import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  // Headers
  static TextStyle get h1 => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle get h2 => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get h3 => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get h4 => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get h5 => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get h6 => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body text
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Button text
  static TextStyle get buttonLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.0,
  );

  static TextStyle get buttonMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.0,
  );

  static TextStyle get buttonSmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.0,
  );

  // Specialized styles
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
    height: 1.3,
  );

  static TextStyle get overline => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    height: 1.3,
    letterSpacing: 1.5,
  );

  static TextStyle get subtitle1 => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get subtitle2 => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Special styles for SparkHub
  static TextStyle get logoText => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static TextStyle get eventTitle => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get eventSubtitle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get badgeText => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.0,
  );

  static TextStyle get pointsText => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    height: 1.2,
  );

  // Helper method to apply colors
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  // Helper method to apply gradient text (using shader)
  static TextStyle withGradient(TextStyle style, List<Color> colors) {
    return style.copyWith(
      foreground: Paint()
        ..shader = LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
    );
  }
}
