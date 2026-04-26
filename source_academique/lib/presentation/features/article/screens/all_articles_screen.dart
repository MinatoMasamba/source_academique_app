// lib/presentation/features/article/screens/all_articles_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:source_academique/core/config/service_locator.dart';
import 'package:source_academique/core/constants/ui_dimensions.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';

import 'package:source_academique/features/auth/data/repositories/home_repository.dart';
import 'package:source_academique/presentation/features/home/presentation/widgets/article_trend_item.dart';
import 'package:source_academique/presentation/features/home/presentation/widgets/search_bar_custom.dart';

class AllArticlesScreen extends StatefulWidget {
  const AllArticlesScreen({super.key});

  @override
  State<AllArticlesScreen> createState() => _AllArticlesScreenState();
}

class _AllArticlesScreenState extends State<AllArticlesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final HomeRepository repository = sl<HomeRepository>();
  String _searchQuery = '';
  bool _isLoading = true;
  List<Article> _articles = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadArticles();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final articles = await repository.getArticles();
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
      print("📰 [AllArticlesScreen] ${_articles.length} articles chargés");
    } catch (e) {
      print("❌ [AllArticlesScreen] Erreur: $e");
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Article> get _filteredArticles {
    if (_searchQuery.isEmpty) return _articles;
    return _articles.where((a) => 
      a.titre.toLowerCase().contains(_searchQuery) ||
      a.description.toLowerCase().contains(_searchQuery) ||
      (a.categorie?.toLowerCase().contains(_searchQuery) ?? false)
    ).toList();
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: _buildGlassBackButton(context), // ← BOUTON GLASS AJOUTÉ
        title: const Text("Tous les articles"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(UiDimensions.paddingMedium),
            child: SearchBarCustom(
              controller: _searchController,
              onChanged: (_) {},
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Erreur: $_errorMessage"),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadArticles,
                              child: const Text("Réessayer"),
                            ),
                          ],
                        ),
                      )
                    : _filteredArticles.isEmpty
                        ? const Center(child: Text("Aucun article trouvé"))
                        : GridView.builder(
                            padding: const EdgeInsets.all(UiDimensions.paddingMedium),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _filteredArticles.length,
                            itemBuilder: (context, index) {
                              final article = _filteredArticles[index];
                              return ArticleTrendItem(
                                document: article, // ← CHANGÉ : 'article' au lieu de 'document'
                                onTap: () => _navigateToArticleDetail(article),
                                isDark: isDark,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // ========== BOUTON RETOUR GLASSMORPHISM ==========
  Widget _buildGlassBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }

  void _navigateToArticleDetail(Article article) {
    print("📰 [AllArticlesScreen] Navigation vers article: ${article.id}");
    context.push('/article/${article.id}', extra: article);
  }
}