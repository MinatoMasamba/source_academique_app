// lib/core/widgets/glass_back_button.dart
import 'package:flutter/material.dart';

class GlassBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;
  final double? size;

  const GlassBackButton({
    super.key,
    this.onPressed,
    this.iconColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed ?? () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: iconColor ?? Colors.white,
              size: size ?? 18,
            ),
          ),
        ),
      ),
    );
  }
}