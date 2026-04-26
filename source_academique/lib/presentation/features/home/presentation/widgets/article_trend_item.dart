import 'package:flutter/material.dart';
import 'package:source_academique/core/constants/app_colors.dart';
import 'package:source_academique/core/utils/image_utils.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
// Vérifie que ce chemin correspond bien à l'endroit où tu as créé ton entité

class ArticleTrendItem extends StatelessWidget {
  final Article document;
  final VoidCallback onTap;
  final bool isDark;
  

  const ArticleTrendItem({
    super.key,
    required this.document,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            // Image circulaire parfaitement ronde
            Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                shape: BoxShape.circle, 
                image: document.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(ImageUtils.getDefaultImage('article', seed: document.id.hashCode)),
                        fit: BoxFit.cover,
                      )
                    : null,
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Titre de l'article centré
            Text(
              document.titre,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.primary : const Color(0xFF004D40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}