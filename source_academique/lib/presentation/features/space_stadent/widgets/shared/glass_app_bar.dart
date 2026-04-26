// lib/presentation/features/space_stadent/widgets/shared/glass_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_academique/presentation/features/space_stadent/presentation/bloc/student_space_bloc.dart';
import 'package:source_academique/presentation/features/space_stadent/presentation/bloc/student_space_state.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? customActions;
  final bool showStats;

  const GlassAppBar({
    super.key,
    required this.title,
    this.customActions,
    this.showStats = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: isDark
              ? const ColorFilter.matrix(<double>[
                  1, 0, 0, 0, 0,
                  0, 1, 0, 0, 0,
                  0, 0, 1, 0, 0,
                  0, 0, 0, 0.8, 0,
                ])
              : const ColorFilter.matrix(<double>[
                  1, 0, 0, 0, 0,
                  0, 1, 0, 0, 0,
                  0, 0, 1, 0, 0,
                  0, 0, 0, 0.6, 0,
                ]),
          child: Container(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.7),
          ),
        ),
      ),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final List<Widget> actions = [];

    if (showStats) {
      actions.add(
        BlocBuilder<StudentSpaceBloc, StudentSpaceState>(
          builder: (context, state) {
            if (state.status == StudentSpaceStatus.success) {
              return Row(
                children: [
                  _buildStatIcon(Icons.favorite, state.totalLikes),
                  const SizedBox(width: 8),
                  _buildStatIcon(Icons.visibility, state.totalViews),
                  const SizedBox(width: 8),
                  _buildStatIcon(Icons.chat_bubble, state.totalComments),
                  const SizedBox(width: 8),
                ],
              );
            }
            return const SizedBox(width: 40);
          },
        ),
      );
    }

    if (customActions != null && customActions!.isNotEmpty) {
      actions.addAll(customActions!);
    }

    return actions;
  }

  Widget _buildStatIcon(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 2),
        Text(
          count > 999 ? '${(count / 1000).toStringAsFixed(1)}k' : count.toString(),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}