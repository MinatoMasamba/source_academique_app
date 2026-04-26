import 'package:flutter/material.dart';

class SearchBarCustom extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSubmitted;

  const SearchBarCustom({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade300,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: isDark ? Colors.white54 : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: (_) => onSubmitted?.call(),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: "Rechercher un document...",
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Container(
            height: 25,
            width: 1,
            color: isDark ? Colors.white12 : Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Icon(
            Icons.camera_alt_outlined,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ],
      ),
    );
  }
}