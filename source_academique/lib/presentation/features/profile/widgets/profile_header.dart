import 'package:flutter/material.dart';
import 'package:source_academique/core/constants/app_colors.dart';
import 'package:source_academique/features/auth/domain/entities/profile_model.dart';
import '../../../../core/utils/validators.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final bool isEditing;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final VoidCallback onImagePick;
  final bool isDark;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.isEditing,
    required this.firstNameController,
    required this.lastNameController,
    required this.onImagePick,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradientNeon,
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                backgroundImage: profile.photoUrl != null 
                    ? NetworkImage(profile.photoUrl!) 
                    : const NetworkImage('https://via.placeholder.com/300x200') as ImageProvider,
                onBackgroundImageError: (_, __) => const Icon(Icons.person, size: 50),
              ),
            ),
            if (isEditing)
              GestureDetector(
                onTap: onImagePick,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? AppColors.bgDark : Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (isEditing)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: firstNameController,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(labelText: "Prénom", floatingLabelAlignment: FloatingLabelAlignment.center),
                    validator: (value) => Validators.validateRequired(value, "Prénom"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: lastNameController,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(labelText: "Nom", floatingLabelAlignment: FloatingLabelAlignment.center),
                    validator: (value) => Validators.validateRequired(value, "Nom"),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              Text(
                "${profile.firstName} ${profile.lastName}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.promotion ?? "Étudiant",
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
      ],
    );
  }
}