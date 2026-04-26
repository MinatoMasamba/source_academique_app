// lib/presentation/features/space_stadent/espace.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:source_academique/core/config/service_locator.dart';
import 'package:source_academique/core/constants/app_colors.dart';
import 'package:source_academique/core/constants/ui_dimensions.dart';
import 'package:source_academique/core/storage/local_db_manager.dart';
import 'package:source_academique/features/auth/data/repositories/student_space_repository.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
import 'package:source_academique/features/auth/domain/entities/resultat.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';
import 'package:source_academique/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:source_academique/presentation/features/space_stadent/create_post_screen.dart';
import 'package:source_academique/presentation/features/space_stadent/presentation/bloc/student_space_bloc.dart';
import 'package:source_academique/presentation/features/space_stadent/presentation/bloc/student_space_state.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/documents/composants/document_add_trigger.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/documents/saved_file_item.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/posts/student_post_item.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/shared/glass_app_bar.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/shared/student_glass_card.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/stats/student_progress_card.dart';

class StudentSpaceScreen extends StatelessWidget {
  const StudentSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Non authentifié')));
    }
    final userId = authState.user.id;

    return BlocProvider(
      create: (context) => StudentSpaceBloc(
        repository: sl<StudentSpaceRepository>(),
        localDb: sl<LocalDbManager>(),
        userId: userId,
      )..add(const FetchUserPosts()),
      child: const StudentSpaceView(),
    );
  }
}

class StudentSpaceView extends StatefulWidget {
  const StudentSpaceView({super.key});

  @override
  State<StudentSpaceView> createState() => _StudentSpaceViewState();
}

class _StudentSpaceViewState extends State<StudentSpaceView> {
  final double totalStorageGB = 2.0;
  final double usedStorageGB = 1.2;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: GlassAppBar(
        title: "Mon Espace",
        showStats: true,
        customActions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => _showStatsDialog(context),
            tooltip: "Statistiques",
          ),
        ],
      ),
      body: BlocBuilder<StudentSpaceBloc, StudentSpaceState>(
        builder: (context, state) {
          if (state.status == StudentSpaceStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == StudentSpaceStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erreur : ${state.errorMessage ?? "Inconnue"}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<StudentSpaceBloc>().add(const FetchUserPosts()),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          if (state.status == StudentSpaceStatus.success) {
            final posts = state.posts;
            final documents = state.documents.cast<StudentFile>();
            final results = state.academicResults.cast<Resultat>();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<StudentSpaceBloc>().add(const FetchUserPosts(refreshRemote: true));
                context.read<StudentSpaceBloc>().add(const FetchUserDocuments(refreshRemote: true));
                context.read<StudentSpaceBloc>().add(const FetchAcademicStats(refreshRemote: true));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          StudentProgressCard(
                            progress: state.globalProgress,
                            totalResults: results.length,
                            averageScore: _computeAverageScore(results),
                          ),
                          const SizedBox(height: 16),
                          _buildStorageCard(isDark),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Mes Documents",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${documents.length} document${documents.length > 1 ? 's' : ''}",
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                          DocumentAddTrigger(
                            onFileSelected: (file, fileName) {
                              context.read<StudentSpaceBloc>().add(
                                    UploadDocumentEvent(file.path, fileName),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (documents.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildEmptyDocumentsState(isDark),
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final doc = documents[index];
                            return Container(
                              width: 200,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: SavedFileItem(
                                file: doc,
                                onDelete: () => _confirmDeleteDocument(context, doc.id!),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Vos Post",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${posts.length} publication${posts.length > 1 ? 's' : ''}",
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  if (posts.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildEmptyState(isDark),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = posts[index];
                          final authState = context.read<AuthBloc>().state;
                          final currentUserId = authState is AuthAuthenticated ? authState.user.id : null;
                          final isOwner = post.user['id'] == currentUserId;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: StudentPostItem(post: post, isOwner: isOwner),
                          );
                        },
                        childCount: posts.length,
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      // FloatingActionButton plus haut (70px)
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120.0), // Ajuste la valeur pour monter le bouton
        child: FloatingActionButton(
          onPressed: () => _showPostEditorDialog(context),
          backgroundColor: AppColors.secondary,
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildStorageCard(bool isDark) {
    final progress = usedStorageGB / totalStorageGB;
    return StudentGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_done_rounded, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                "Stockage",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.white24 : Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation(Colors.blue),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${usedStorageGB.toStringAsFixed(1)} Go utilisés",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                "$totalStorageGB Go au total",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _computeAverageScore(List<Resultat> results) {
    if (results.isEmpty) return 0.0;
    double sum = 0.0;
    for (var r in results) {
      sum += (r.note / r.noteMaxima) * 20;
    }
    return sum / results.length;
  }

  Widget _buildEmptyState(bool isDark) {
    return StudentGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.post_add_outlined, size: 64, color: isDark ? Colors.white30 : Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "Aucune publication",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Commencez par partager quelque chose",
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDocumentsState(bool isDark) {
    return StudentGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.folder_open_outlined, size: 48, color: isDark ? Colors.white30 : Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              "Aucun document",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Ajoutez vos fichiers importants",
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatsDialog(BuildContext context) {
    final state = context.read<StudentSpaceBloc>().state;
    if (state.status != StudentSpaceStatus.success) return;

    final posts = state.posts;
    final totalPosts = posts.length;
    final totalLikes = posts.fold<int>(0, (sum, p) => sum + p.likesCount);
    final totalViews = posts.fold<int>(0, (sum, p) => sum + p.viewsCount);
    final totalComments = posts.fold<int>(0, (sum, p) => sum + p.commentsCount);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Mes Statistiques"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow(Icons.post_add, "Publications", totalPosts.toString()),
            const Divider(),
            _buildStatRow(Icons.favorite, "Likes reçus", totalLikes.toString()),
            const Divider(),
            _buildStatRow(Icons.visibility, "Vues totales", totalViews.toString()),
            const Divider(),
            _buildStatRow(Icons.chat_bubble, "Commentaires", totalComments.toString()),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fermer"))],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

 void _showPostEditorDialog(BuildContext context, {PostNews? post}) {
  final bloc = context.read<StudentSpaceBloc>();
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CreatePostScreen(
        post: post,
        onCreatePost: (content, filePaths) async {
          bloc.add(CreateStudentPost(content: content, mediaPaths: filePaths));
        },
        onUpdatePost: (shareableId, content) async {
          bloc.add(UpdatePostEvent(shareableId, content));
        },
      ),
    ),
  );
}
  void _confirmDeleteDocument(BuildContext context, int documentId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Supprimer le document"),
        content: const Text("Voulez-vous vraiment supprimer ce document ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Annuler")),
          TextButton(
            onPressed: () {
              context.read<StudentSpaceBloc>().add(DeleteDocumentEvent(documentId));
              Navigator.pop(dialogContext);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}