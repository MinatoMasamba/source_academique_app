// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Palette principal 2026
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color accent = Color(0xFFF43F5E);

  // Glassmorphism
  static const Color glassBGDark = Color(0x1AFFFFFF);
  static const Color glassBorderDark = Color(0x33FFFFFF);
  static const Color glassBGLight = Color(0x66FFFFFF);
  static const Color glassBorderLight = Color(0x80FFFFFF);

  static const Color bgDark = Color(0xFF0F172A);
  static const Color bgLight = Color(0xFFF8FAFC);

  // Gradient neon pour les éléments en vedette
  static const LinearGradient gradientNeon = LinearGradient(
    colors: [Color(0xFF00C6FB), Color(0xFF005BEA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}