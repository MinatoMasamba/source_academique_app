import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/ui_dimensions.dart';

class AppTheme {
  /// Configuration commune des textes basée sur AppTypography
  static TextTheme _textTheme(Color textColor) => TextTheme(
        displayLarge: AppTypography.h1.copyWith(color: textColor),
        titleLarge: AppTypography.h2.copyWith(color: textColor),
        bodyLarge: AppTypography.bodyLarge.copyWith(
          color: textColor.withOpacity(0.9),
        ),
        bodyMedium: AppTypography.bodyMedium.copyWith(
          color: textColor.withOpacity(0.8),
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      );

  // --- THEME SOMBRE (Look Premium 2026) ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.glassBGDark,
        error: AppColors.accent,
        onSurface: Colors.white,
      ),
      textTheme: _textTheme(Colors.white),

      // Configuration des Inputs pour le Glassmorphism
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(UiDimensions.glassOpacity),
        contentPadding: EdgeInsets.symmetric(
          horizontal: UiDimensions.paddingMedium,
          vertical: UiDimensions.paddingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        hintStyle: const TextStyle(color: Colors.white38),
      ),

      // Barre de navigation translucide (ShellRoute)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.secondary);
          }
          return const IconThemeData(color: Colors.white70);
        }),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),

      // Card Theme pour le Glassmorphism - CORRECTION: CardThemeData
      cardTheme: CardThemeData(
        color: AppColors.glassBGDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiDimensions.radiusMedium),
          side: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),

      // Boutons modernes avec Gradient Neon indirect
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          ),
          elevation: 0,
          textStyle: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Boutons textes
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          textStyle: AppTypography.bodyMedium,
        ),
      ),

      // Boutons outlines
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          ),
        ),
      ),

      // AppBar transparente
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // --- THEME CLAIR ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.glassBGLight,
        onSurface: AppColors.bgDark,
      ),
      textTheme: _textTheme(AppColors.bgDark),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withOpacity(0.05),
        contentPadding: EdgeInsets.symmetric(
          horizontal: UiDimensions.paddingMedium,
          vertical: UiDimensions.paddingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        hintStyle: TextStyle(color: AppColors.bgDark.withOpacity(0.4)),
      ),

      // Card Theme pour le mode clair - CORRECTION: CardThemeData
      cardTheme: CardThemeData(
        color: AppColors.glassBGLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiDimensions.radiusMedium),
          side: BorderSide(
            color: Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          ),
          elevation: 0,
          textStyle: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.bodyMedium,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.bgDark,
          side: BorderSide(color: AppColors.bgDark.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          ),
        ),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.bgDark),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.bgDark,
        ),
      ),
    );
  }
}