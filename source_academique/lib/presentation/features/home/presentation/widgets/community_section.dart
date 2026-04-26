// lib/presentation/features/home/presentation/widgets/community_section.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_academique/core/config/service_locator.dart';
import 'package:source_academique/core/storage/local_db_manager.dart';
import 'package:source_academique/features/auth/data/repositories/student_space_repository.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';
import 'package:source_academique/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:source_academique/presentation/features/home/presentation/widgets/section_header.dart';
import 'package:source_academique/presentation/features/space_stadent/presentation/bloc/student_space_bloc.dart';
import 'package:source_academique/presentation/features/space_stadent/presentation/bloc/student_space_state.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/posts/student_post_item.dart';

class CommunitySection extends StatelessWidget {
  final bool isDark;

  const CommunitySection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = sl<StudentSpaceBloc>();
        // On n'a pas besoin d'userId pour la communauté, on passe 0 (ignoré)
        // Mais comme le bloc est enregistré avec userId=0, on va créer une nouvelle instance manuellement
        final repository = sl<StudentSpaceRepository>();
        final localDb = sl<LocalDbManager>();
        final communityBloc = StudentSpaceBloc(repository: repository, localDb: localDb, userId: 0);
        communityBloc.add(FetchCommunityPosts());
        return communityBloc;
      },
      child: _CommunityView(isDark: isDark),
    );
  }
}

class _CommunityView extends StatelessWidget {
  final bool isDark;

  const _CommunityView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticated ? authState.user.id : null;

    return BlocBuilder<StudentSpaceBloc, StudentSpaceState>(
      builder: (context, state) {
        if (state.status == StudentSpaceStatus.loading) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == StudentSpaceStatus.error) {
          return Center(
            child: Column(
              children: [
                Text("Erreur: ${state.errorMessage}"),
                ElevatedButton(
                  onPressed: () => context.read<StudentSpaceBloc>().add(FetchCommunityPosts()),
                  child: const Text("Réessayer"),
                ),
              ],
            ),
          );
        }
        if (state.posts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: Text("Aucune publication pour le moment")),
          );
        }
        return Column(
          children: [
            SectionHeader(
              title: "Communauté",
              onSeeAll: () => Navigator.of(context).pushNamed('/community'),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                final post = state.posts[index];
                final isOwner = (post.user['id'] != null && currentUserId != null)
                    ? post.user['id'] == currentUserId
                    : false;
                return StudentPostItem(
                  key: ValueKey(post.shareableId),
                  post: post,
                  isOwner: isOwner,
                );
              },
            ),
          ],
        );
      },
    );
  }
}