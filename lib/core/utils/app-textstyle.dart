import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medident/core/utils/app-colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _inter({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
    double? height,
    Color color = AppColors.textPrimary,
  }) {
    try {
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'Inter',
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    }
  }

  static String get fontFamily => 'Inter';

  static TextStyle get displayLarge => _inter(
    fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25, height: 1.12,
  );
  static TextStyle get displayMedium => _inter(
    fontSize: 45, fontWeight: FontWeight.w400, letterSpacing: 0, height: 1.16,
  );
  static TextStyle get displaySmall => _inter(
    fontSize: 36, fontWeight: FontWeight.w400, letterSpacing: 0, height: 1.22,
  );
  static TextStyle get headlineLarge => _inter(
    fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.25,
  );
  static TextStyle get headlineMedium => _inter(
    fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.29,
  );
  static TextStyle get headlineSmall => _inter(
    fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.33,
  );
  static TextStyle get titleLarge => _inter(
    fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.27,
  );
  static TextStyle get titleMedium => _inter(
    fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15, height: 1.50,
  );
  static TextStyle get titleSmall => _inter(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.43,
  );
  static TextStyle get labelLarge => _inter(
    fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 1.43, color: AppColors.textSecondary,
  );
  static TextStyle get labelMedium => _inter(
    fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.33, color: AppColors.textSecondary,
  );
  static TextStyle get labelSmall => _inter(
    fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.45, color: AppColors.textSecondary,
  );
  static TextStyle get bodyLarge => _inter(
    fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15, height: 1.50, color: AppColors.textSecondary,
  );
  static TextStyle get bodyMedium => _inter(
    fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.25, height: 1.43, color: AppColors.textSecondary,
  );
  static TextStyle get bodySmall => _inter(
    fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, height: 1.33, color: AppColors.textSecondary,
  );
  static TextStyle get logoLarge => _inter(
    fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.0,
  );
  static TextStyle get logoMedium => _inter(
    fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.0,
  );
  static TextStyle get logoSmall => _inter(
    fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.0,
  );
  static TextStyle get productTitle => _inter(
    fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.3,
  );
  static TextStyle get productPrice => _inter(
    fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0, height: 1.2,
  );
  static TextStyle get categoryTitle => _inter(
    fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 1.2, color: AppColors.textSecondary,
  );
  static TextStyle get buttonText => _inter(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.0,
  );
  static TextStyle get buttonTextLarge => _inter(
    fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.0,
  );
}
