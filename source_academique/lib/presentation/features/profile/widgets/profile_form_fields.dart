// lib/features/profile/widgets/profile_glass_dropdown.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Un Dropdown stylisé pour le parcours académique
class ProfileGlassDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final bool isDark;
  final bool enabled;
  final bool isLoading;
  final String? hintText;

  const ProfileGlassDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
    this.enabled = true,
    this.isLoading = false,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      isExpanded: true,
      isDense: true,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 12,
        ),
        hintText: hintText ?? "Sélectionner $label",
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : Colors.grey.shade400,
          fontSize: 13,
        ),
        filled: true,
        fillColor: isDark
            ? (enabled ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.02))
            : (enabled ? Colors.grey.shade50 : Colors.grey.shade100),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
        ),
        suffixIcon: isLoading
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.secondary,
                  ),
                ),
              )
            : null,
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        );
      }).toList(),
      onChanged: enabled && !isLoading ? onChanged : null,
      icon: Icon(
        Icons.arrow_drop_down_circle_outlined,
        color: enabled && !isLoading
            ? (isDark ? Colors.white38 : Colors.black38)
            : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
        size: 20,
      ),
      iconSize: 20,
      menuMaxHeight: 300,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
    );
  }
}



/// Une carte d'information qui affiche une donnée ou un champ d'édition
class ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final bool isEditing;
  final VoidCallback? onEdit;
  final Color? iconColor;
  final Widget? trailing;

  const ProfileInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.isEditing = false,
    this.onEdit,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isValueEmpty = value.isEmpty || value == "Non renseigné";
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? (isEditing ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.03))
            : (isEditing ? Colors.grey.shade50 : Colors.white),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark
              ? (isEditing ? Colors.white24 : Colors.white10)
              : (isEditing ? AppColors.secondary.withOpacity(0.3) : Colors.grey.shade100),
          width: isEditing ? 1.2 : 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.secondary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? AppColors.secondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isValueEmpty ? FontWeight.w400 : FontWeight.w600,
                    color: isValueEmpty
                        ? (isDark ? Colors.white38 : Colors.grey.shade500)
                        : (isDark ? Colors.white : Colors.black87),
                    fontStyle: isValueEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isEditing && onEdit != null)
            Container(
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.edit_note_rounded,
                  size: 18,
                  color: AppColors.secondary,
                ),
                onPressed: onEdit,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

