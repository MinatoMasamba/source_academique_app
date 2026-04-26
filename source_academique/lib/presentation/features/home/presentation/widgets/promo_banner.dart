import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:source_academique/core/constants/app_colors.dart';
import 'package:source_academique/core/constants/ui_dimensions.dart';

class PromoBanner extends StatelessWidget {
  final bool isDark;

  const PromoBanner({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: UiDimensions.paddingLarge),
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.secondary],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF004D40), Color(0xFF00695C)],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.primary : const Color(0xFF004D40)).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.menu_book,
              size: 100,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Flexible(
                  child: Text(
                    "Top Documents\nSession 2026",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.push('/featured'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isDark ? AppColors.primary : const Color(0xFF004D40),
                    shape: const StadiumBorder(),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    minimumSize: const Size(100, 35),
                  ),
                  child: const Text("Découvrir", style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}