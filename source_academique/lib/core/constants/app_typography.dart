import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Titres (Style Prestige)
  static TextStyle h1 = GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static TextStyle h2 = GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  // Corps de texte (Style Technique/Moderne)
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  // Spécial pour le Markdown / Code
  static TextStyle code = GoogleFonts.firaCode(
    fontSize: 13,
    backgroundColor: Colors.black12,
  );
}