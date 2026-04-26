import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileStats extends StatelessWidget {
  final String docsCount;
  final String score;
  final String followersCount;
  final bool isDark;

  const ProfileStats({
    super.key,
   this.docsCount = "0",
    this.score = "0",
    this.followersCount = "0",
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(docsCount, "Documents"),
          _buildVerticalDivider(),
          _buildStatItem(score, "Score"),
          _buildVerticalDivider(),
          _buildStatItem(followersCount, "Abonnés"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.secondary : AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: isDark ? Colors.white10 : Colors.grey.shade300,
    );
  }
}