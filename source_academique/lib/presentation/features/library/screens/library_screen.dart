import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:source_academique/core/config/service_locator.dart';
import 'package:source_academique/core/constants/app_colors.dart';
import 'package:source_academique/core/constants/ui_dimensions.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
import 'package:source_academique/presentation/features/home/presentation/widgets/search_bar_custom.dart';
import 'package:source_academique/presentation/features/library/presentations/bloc/library_bloc.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LibraryBloc>()..add(const FetchLibraryDocuments(selectedType: 'Tous')),
      child: const LibraryView(),
    );
  }
}

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'Tous';

  final List<Map<String, dynamic>> _documentTypes = const [
    {"name": "Tous", "icon": Icons.grid_view},
    {"name": "Cours", "icon": Icons.menu_book_rounded},
    {"name": "TP", "icon": Icons.assignment_outlined},
    {"name": "Examen", "icon": Icons.history_edu_rounded},
    {"name": "Interro", "icon": Icons.timer_outlined},
    {"name": "Note", "icon": Icons.note_alt_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    context.read<LibraryBloc>().add(SearchLibraryDocuments(_searchController.text));
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ma Bibliothèque", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: UiDimensions.paddingLarge),
            child: SearchBarCustom(
              controller: _searchController,
              onChanged: (_) {},
            ),
          ),
          const SizedBox(height: 20),
          _buildTypeFilters(isDark),
          const SizedBox(height: 15),
          Expanded(
            child: BlocBuilder<LibraryBloc, LibraryState>(
              builder: (context, state) {
                if (state is LibraryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is LibraryError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Erreur : ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<LibraryBloc>().add(const FetchLibraryDocuments(selectedType: 'Tous')),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is LibraryLoaded) {
                  final docs = state.documents;
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? "Aucun document disponible"
                                : "Aucun résultat pour \"${_searchController.text}\"",
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                          ),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) => _LibraryCard(document: docs[index], isDark: isDark),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilters(bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: UiDimensions.paddingLarge),
        itemCount: _documentTypes.length,
        itemBuilder: (context, index) {
          final typeName = _documentTypes[index]["name"];
          final isSelected = _selectedType == typeName;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedType = typeName);
              context.read<LibraryBloc>().add(FilterByDocumentType(typeName));
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.secondary : const Color(0xFF004D40))
                    : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  typeName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Carte d'affichage d'un document académique
class _LibraryCard extends StatelessWidget {
  final AcademicDocument document;
  final bool isDark;

  const _LibraryCard({required this.document, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/document/${document.id}', extra: document),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zone image + badge format
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      image: DecorationImage(
                        image: NetworkImage(document.coverImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getFormatColor(document.fileFormat).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        document.fileFormat,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    document.author.isNotEmpty ? document.author : "Auteur inconnu",
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        document.fileSize.isNotEmpty ? document.fileSize : "--",
                        style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
                      ),
                      Icon(Icons.more_vert, size: 16, color: isDark ? Colors.white38 : Colors.black38),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFormatColor(String format) {
    switch (format.toUpperCase()) {
      case 'PDF': return Colors.redAccent;
      case 'ZIP': return Colors.orange;
      case 'TXT': return Colors.blueGrey;
      default: return AppColors.primary;
    }
  }
}