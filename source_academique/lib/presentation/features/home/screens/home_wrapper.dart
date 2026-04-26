import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/glass_morphism.dart';

/// **HomeWrapper** : Le conteneur principal avec effet Glassmorphism et Assistant IA.
class HomeWrapper extends StatelessWidget {
  final Widget child;

  const HomeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Permet au contenu de passer derrière la barre de navigation translucide
      extendBody: true,
      // Évite que le clavier ne pousse la barre et crée un overflow
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // Le contenu de la page actuelle (Library, Community, etc.)
          child,
          
          // L'Assistant IA flottant (Positionné au centre au-dessus de la barre)

        ],
      ),
      bottomNavigationBar: const _CustomGlassNavigationBar(),
    );
  }
}

/// **_CustomGlassNavigationBar** : La barre de navigation stylisée avec Glassmorphism.
class _CustomGlassNavigationBar extends StatelessWidget {
  const _CustomGlassNavigationBar();

  @override
  Widget build(BuildContext context) {
    // --- SÉCURITÉ GOROUTER ---
    String location = '/';
    try {
      location = GoRouterState.of(context).matchedLocation;
    } catch (e) {
      location = '/'; 
    }

    return Container(
      height: 90,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: GlassMorphism(
        blur: 20,
        opacity: 0.1,
        borderRadius: 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(
              icon: Icons.home_outlined,
              label: 'Home',
              isSelected: location == '/',
              onTap: () => _safeGo(context, '/'),
            ),
            _NavBarItem(
              icon: Icons.book,
              label: 'Library',
              isSelected: location == '/Library',
              onTap: () => _safeGo(context, '/Library'),
            ),
            
            _NavBarItem(
              icon: Icons.star_border,
              label: 'IA',
              isSelected: location == '/ai-assistant',
              onTap: () => _safeGo(context, '/ai-assistant'),
            ),

            _NavBarItem(
              icon: Icons.download_for_offline_outlined,
              label: 'espace',
              isSelected: location == '/space-student',
              onTap: () => _safeGo(context, '/space-student'),
            ),
            _NavBarItem(
              icon: Icons.person_outline_rounded,
              label: 'Profil',
              isSelected: location == '/profile',
              onTap: () => _safeGo(context, '/profile'),
            ),
          ],
        ),
      ),
    );
  }

  void _safeGo(BuildContext context, String path) {
    try {
      context.go(path);
    } catch (e) {
      debugPrint("Erreur navigation : $path non configurée.");
    }
  }
}

/// **_NavBarItem** : Widget interne pour les icônes de la barre avec animation.
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.secondary : Colors.white70;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary.withOpacity(0.15) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26), // Taille réduite pour éviter l'overflow
          ),
          const SizedBox(height: 2),
          // FittedBox empêche le texte de dépasser (Overflow 10px) si le mot est trop long
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: color, 
                fontSize: 10, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ),
        ],
      ),
    );
  }
}

