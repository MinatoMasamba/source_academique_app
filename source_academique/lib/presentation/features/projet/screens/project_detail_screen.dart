// lib/presentation/features/project/screens/project_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
import 'package:source_academique/presentation/features/discovery/widgets/glass_back_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:source_academique/core/constants/app_colors.dart';
import 'package:source_academique/core/constants/ui_dimensions.dart';


class ProjectDetailScreen extends StatelessWidget {
  final Projet project;

  const ProjectDetailScreen({super.key, required this.project});

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
            leading: const GlassBackButton(),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (project.imageUrl != null && project.imageUrl!.isNotEmpty)
                    Image.network(
                      project.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
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
                      project.titre,
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UiDimensions.paddingLarge,
                vertical: UiDimensions.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Métadonnées
                  Row(
                    children: [
                      if (project.categorie != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            project.categorie!.toUpperCase(),
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
                        _formatDate(project.dateCreation),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Auteur et université
                  if (project.auteur != null || project.universite != null)
                    Column(
                      children: [
                        if (project.auteur != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    project.auteur!,
                                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (project.universite != null)
                          Row(
                            children: [
                              Icon(Icons.school_outlined, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  project.universite!,
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Ligne de séparation
                  Container(
                    height: 3,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  HtmlWidget(
                    project.description,
                    textStyle: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: isDark ? Colors.white.withOpacity(0.85) : Colors.black.withOpacity(0.8),
                    ),
                    onTapUrl: (url) async {
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                        return true;
                      }
                      return false;
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientNeon),
      child: Center(
        child: Icon(
          Icons.rocket_launch_outlined,
          size: 80,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}