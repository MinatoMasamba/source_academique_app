// lib/presentation/features/article/screens/article_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:source_academique/core/constants/app_colors.dart';

import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
import 'package:source_academique/presentation/features/discovery/widgets/glass_back_button.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: size.height * 0.4,
            stretch: true,
            pinned: true,
            backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
            elevation: 0,
            leading: const GlassBackButton(), // ← Bouton Glass
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                    Image.network(article.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder())
                  else
                    _buildPlaceholder(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          isDark ? AppColors.bgDark : AppColors.bgLight,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 24,
                    right: 24,
                    child: Text(
                      article.titre,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ... reste du contenu
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientNeon),
      child: Center(child: Icon(Icons.article_outlined, size: 80, color: Colors.white.withOpacity(0.3))),
    );
  }
}