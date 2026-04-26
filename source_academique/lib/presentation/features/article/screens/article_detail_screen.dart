// lib/presentation/features/article/screens/article_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:source_academique/core/constants/app_colors.dart';
import 'package:source_academique/core/constants/ui_dimensions.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  ArticleDetailScreen({super.key, required this.article}) {
    print("📰 [ArticleDetailScreen] Constructeur - article: ${article.titre} (id: ${article.id})");
  }

  @override
  Widget build(BuildContext context) {
    print("📰 [ArticleDetailScreen.build] Début construction");
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header avec image de couverture
          SliverAppBar(
            expandedHeight: 350, // Légèrement agrandi pour plus d'impact visuel
            pinned: true,
            backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image de couverture
                  if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                    Image.network(
                      article.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    )
                  else
                    _buildPlaceholder(),
                    
                  // Overlay dégradé pour adoucir la transition vers le texte
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4), // Assombrit le haut pour les icônes
                          Colors.transparent,
                          isDark ? AppColors.bgDark : AppColors.bgLight, // Se fond dans le background du Scaffold
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: _buildHeaderIcon(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
            actions: [
              _buildHeaderIcon(
                icon: Icons.share_outlined,
                onTap: () => _shareArticle(context),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Corps de l'article (Libéré de la carte)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UiDimensions.paddingLarge,
                vertical: UiDimensions.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catégorie et Date
                  Row(
                    children: [
                      if (article.categorie != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            article.categorie!.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(article.datePublication),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Titre principal
                  Text(
                    article.titre,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Ligne de séparation subtile
                  Container(
                    height: 3,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Contenu HTML/Markdown
                  HtmlWidget(
                    article.description,
                    textStyle: TextStyle(
                      fontSize: 16,
                      height: 1.8, // Espacement des lignes plus aéré pour la lecture
                      color: isDark ? Colors.white.withOpacity(0.85) : Colors.black.withOpacity(0.8),
                    ),
                    onTapUrl: (url) async {
                      print("🔗 [ArticleDetailScreen] Clic sur lien intégré: $url");
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                        return true;
                      }
                      return false;
                    },
                  ),
                  const SizedBox(height: 40),

                  // Bouton Lien externe
                  if (article.lien != null && article.lien!.isNotEmpty)
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientNeon, // Utilisation de ton gradient
                          borderRadius: BorderRadius.circular(UiDimensions.radiusMedium),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(UiDimensions.radiusMedium),
                            onTap: () async {
                              print("🔗 [ArticleDetailScreen] Ouverture source: ${article.lien}");
                              final uri = Uri.parse(article.lien!);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Impossible d'ouvrir ce lien")),
                                );
                              }
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Lire la source complète",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                  const SizedBox(height: 60), // Espace final pour ne pas coller au bord de l'écran
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Petit widget pour uniformiser les boutons de l'AppBar
  Widget _buildHeaderIcon({required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  // Placeholder en cas d'absence d'image
  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.article_rounded,
          size: 80,
          color: Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  void _shareArticle(BuildContext context) {
    print("📤 [ArticleDetailScreen] Partage de l'article: ${article.titre}");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fonction de partage à venir")),
    );
  }
}