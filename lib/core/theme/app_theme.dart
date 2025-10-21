import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryDarkGreen = Color(0xFF22823B);
  static const Color primaryLightGreen = Color(0xFF6ABF7C);

  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF4F4F4F);
  static const Color gray = Color(0xFFBDBDBD);
  static const Color error = Color(0xFFFF4D4D);

  // Koyu gradient için renkler
  static const Color darkGradientTop = Color(0xFF7EDC8A);
  static const Color darkGradientBottom = Color(0xFF3E8D4E);

  // Açık gradient için renkler
  static const Color lightGradientTop = Color(0xFFF7FDF9);
  static const Color lightGradientBottom = Color(0xFFEAF9EE);
}


class AppGradients {
  // Koyu Tema Gradient
  static const LinearGradient dark = LinearGradient(
    colors: [
      AppColors.darkGradientTop,
      AppColors.darkGradientBottom,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Açık Tema Gradient (örneğin: onboarding, otp vs.)
  static const LinearGradient light = LinearGradient(
    colors: [
      AppColors.lightGradientTop,
      AppColors.lightGradientBottom,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryDarkGreen,
      secondary: AppColors.primaryLightGreen,
      surface: AppColors.background,
      error: AppColors.error,
    ),

    textTheme: GoogleFonts.nunitoTextTheme().copyWith(
      headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleSmall: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
      bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
      bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      labelSmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDarkGreen,
        foregroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),

    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      fillColor: WidgetStateProperty.all(AppColors.primaryDarkGreen),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryDarkGreen),
      ),
    ),
  );
}
