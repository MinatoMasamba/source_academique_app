// lib/presentation/features/space_stadent/widgets/shared/student_glass_card.dart
import 'package:flutter/material.dart';

/// Carte avec effet Glassmorphism (fond flouté, bordure légère)
class StudentGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor; // override de la couleur de fond
  final List<BoxShadow>? boxShadow;

  const StudentGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.white.withOpacity(0.7);
    final defaultBorder = isDark
        ? Border.all(color: Colors.white10, width: 0.5)
        : Border.all(color: Colors.white, width: 0.5);
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(24);

    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBgColor,
        borderRadius: defaultBorderRadius,
        border: defaultBorder,
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: defaultBorderRadius,
        child: BackdropFilter(
          filter: isDark
              ? const ColorFilter.matrix(<double>[
                  1, 0, 0, 0, 0,
                  0, 1, 0, 0, 0,
                  0, 0, 1, 0, 0,
                  0, 0, 0, 0.8, 0,
                ]) // flou léger
              : const ColorFilter.matrix(<double>[
                  1, 0, 0, 0, 0,
                  0, 1, 0, 0, 0,
                  0, 0, 1, 0, 0,
                  0, 0, 0, 0.6, 0,
                ]),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}