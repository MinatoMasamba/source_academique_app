import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/ui_dimensions.dart';

class GlassMorphism extends StatelessWidget {
  final Widget child;
  final double? blur;
  final double? opacity;
  final double? borderRadius;
  final Color? borderColor;

  const GlassMorphism({
    super.key,
    required this.child,
    this.blur,
    this.opacity,
    this.borderRadius,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    // Détection automatique du mode sombre pour adapter l'opacité du verre
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? UiDimensions.radiusMedium),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blur ?? UiDimensions.blurSigma,
          sigmaY: blur ?? UiDimensions.blurSigma,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
              opacity ?? (isDark ? 0.07 : 0.4), // Plus sombre en Dark Mode
            ),
            borderRadius: BorderRadius.circular(borderRadius ?? UiDimensions.radiusMedium),
            border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(UiDimensions.glassBorderOpacity),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}