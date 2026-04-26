import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback? onTap;
  final bool isDestructive; // Nouveau paramètre

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.onTap,
    this.isDestructive = false, // Par défaut à false
  });

  @override
  Widget build(BuildContext context) {
    // Définition des couleurs selon le mode (Destructif ou Normal)
    final Color contentColor = isDestructive 
        ? Colors.redAccent 
        : (isDark ? Colors.white : Colors.black87);
    
    final Color iconColor = isDestructive 
        ? Colors.redAccent 
        : (isDark ? AppColors.secondary : AppColors.primary);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Material( // Ajouté pour l'effet splash au clic
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDestructive 
                  ? Colors.redAccent.withOpacity(0.1) 
                  : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon, 
              color: iconColor,
              size: 22,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: contentColor,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12, 
              color: isDestructive 
                  ? Colors.redAccent.withOpacity(0.7) 
                  : (isDark ? Colors.white54 : Colors.grey),
            ),
          ),
          // On cache la flèche si c'est une action destructive (Déconnexion)
          trailing: isDestructive 
            ? null 
            : Icon(
                Icons.chevron_right_rounded, 
                size: 20, 
                color: isDark ? Colors.white24 : Colors.black26,
              ),
        ),
      ),
    );
  }
}