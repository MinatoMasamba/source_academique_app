import 'package:flutter/material.dart';
import 'package:source_academique/core/constants/app_colors.dart';

class FacultyFilters extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const FacultyFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final List<Map<String, dynamic>> categories = const [
    {"name": "Tous", "icon": Icons.grid_view},
    {"name": "POLY", "icon": Icons.precision_manufacturing_outlined},
    {"name": "DROIT", "icon": Icons.medical_services_outlined},
    {"name": "MED", "icon": Icons.gavel_outlined},
    {"name": "SCIEN", "icon": Icons.science_outlined},
    // Ajoutez d'autres facultés si nécessaire
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 30,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final item = categories[index];
          final isSelected = selectedFilter == item["name"];

          final Color activeColor = isDark ? AppColors.secondary : const Color(0xFF004D40);
          final Color inactiveBg = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
          final Color textColor = isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : Colors.black87);

          return GestureDetector(
            onTap: () => onFilterSelected(item["name"]),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : inactiveBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? Colors.white10 : Colors.grey.shade300),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(item["icon"], size: 16, color: textColor),
                  const SizedBox(width: 8),
                  Text(
                    item["name"],
                    style: TextStyle(
                      color: textColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}