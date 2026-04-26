import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:source_academique/core/constants/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;

  const HomeAppBar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isDark ? Colors.transparent : Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Icon(
            Icons.school_outlined,
            color: isDark ? AppColors.secondary : const Color(0xFF004D40),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            "Source Académique",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: Icon(
            Icons.notifications_none,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}