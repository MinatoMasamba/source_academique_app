import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:source_academique/core/config/service_locator.dart';
import 'package:source_academique/core/constants/ui_dimensions.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
import 'package:source_academique/presentation/features/discovery/screens/all_discoveries_screen.dart';
import 'package:source_academique/presentation/features/home/logic/home_filters.dart';
import 'package:source_academique/presentation/features/home/presentation/bloc/home_bloc.dart';
import 'package:source_academique/presentation/features/home/presentation/widgets/community_section.dart';
import 'package:source_academique/presentation/features/home/presentation/widgets/home_app_bar.dart';
import 'package:source_academique/presentation/features/home/presentation/widgets/promo_banner.dart';
import 'package:source_academique/presentation/features/home/presentation/widgets/section_header.dart';
import 'package:source_academique/presentation/features/home/presentation/widgets/article_trend_item.dart';
import 'package:source_academique/presentation/features/home/presentation/widgets/discovery_card.dart';
import 'package:source_academique/presentation/features/home/presentation/widgets/faculty_filters.dart';
import 'package:source_academique/presentation/features/home/presentation/widgets/search_bar_custom.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("🏠 [HomeScreen] Construction de HomeScreen");
    return BlocProvider(
      create: (context) {
        print("🏠 [HomeScreen] Création du HomeBloc et envoi de FetchHomeData");
        return sl<HomeBloc>()..add(FetchHomeData());
      },
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() {
    print("🏠 [HomeView] createState -> _HomeViewState");
    return _HomeViewState();
  }
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFaculty = "Tous";

  @override
  void initState() {
    super.initState();
    print("🏠 [_HomeViewState.initState] Initialisation de l'état");
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    print("🔍 [_HomeViewState._onSearchChanged] Recherche: ${_searchController.text}");
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    print("🏠 [_HomeViewState.dispose] Nettoyage");
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    print("🏠 [_HomeViewState.build] Reconstruction avec isDark=$isDark");

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HomeAppBar(isDark: isDark),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          print("🏠 [_HomeViewState.build] BlocBuilder - état reçu: ${state.runtimeType}");
          
          if (state is HomeLoading) {
            print("⏳ [_HomeViewState] Affichage du loader");
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is HomeError) {
            print("❌ [_HomeViewState] Affichage erreur: ${state.message}");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erreur : ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      print("🔄 [_HomeViewState] Bouton réessayer cliqué");
                      context.read<HomeBloc>().add(FetchHomeData());
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          
          if (state is HomeLoaded) {
            print("✅ [_HomeViewState] HomeLoaded reçu - isFromCache: ${state.isFromCache}");
            final discoveries = state.discoveries.applyFilters(_searchQuery, _selectedFaculty);
            final recommended = state.recommended.applyFilters(_searchQuery, _selectedFaculty);
            final articles = state.articles.applyFilters(_searchQuery, _selectedFaculty);
            
            print("📊 [_HomeViewState] Après filtres - Découvertes: ${discoveries.length}, Recommandations: ${recommended.length}, Articles: ${articles.length}");

            return RefreshIndicator(
              onRefresh: () async {
                print("🔄 [_HomeViewState] Pull-to-refresh déclenché");
                context.read<HomeBloc>().add(RefreshHomeData());
                await context.read<HomeBloc>().stream.firstWhere(
                  (newState) => newState is HomeLoaded || newState is HomeError,
                );
                print("✅ [_HomeViewState] Rafraîchissement terminé");
              },
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.white.withOpacity(0.8),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SearchBarCustom(
                      controller: _searchController,
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 10),
                    FacultyFilters(
                      selectedFilter: _selectedFaculty,
                      onFilterSelected: (faculty) {
                        print("🏷️ [_HomeViewState] Filtre faculté changé: $faculty");
                        setState(() {
                          _selectedFaculty = faculty;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    PromoBanner(isDark: isDark),
                    const SizedBox(height: 25),
                    SectionHeader(title: "Découvertes pour vous",  onSeeAll: () => _navigateToAllDiscoveries(context),),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 260,
                      child: discoveries.isEmpty
                          ? const Center(child: Text("Aucune découverte"))
                          : ListView.builder(
                              padding: const EdgeInsets.only(left: UiDimensions.paddingLarge),
                              scrollDirection: Axis.horizontal,
                              itemCount: discoveries.length,
                              itemBuilder: (context, index) => DiscoveryCard(
                                document: discoveries[index],
                                onTap: () => _openDiscoveryDetailFromAcademic(discoveries[index]),
                              ),
                            ),
                    ),
                    const SizedBox(height: 25),
                    SectionHeader(title: "Recommandé pour vous", onSeeAll: () {}),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 260,
                      child: recommended.isEmpty
                          ? const Center(child: Text("Aucune recommandation"))
                          : ListView.builder(
                              padding: const EdgeInsets.only(left: UiDimensions.paddingLarge),
                              scrollDirection: Axis.horizontal,
                              itemCount: recommended.length,
                              itemBuilder: (context, index) => DiscoveryCard(
                                document: recommended[index],
                                onTap: () => _navigateToDocumentDetail(recommended[index]),
                              ),
                            ),
                    ),
                    const SizedBox(height: 25),
                    SectionHeader(title: "Articles tendance",  onSeeAll: () => _navigateToAllArticles(context),),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 160,
                      child: articles.isEmpty
                          ? const Center(child: Text("Aucun article"))
                          : ListView.builder(
                              padding: const EdgeInsets.only(left: UiDimensions.paddingLarge),
                              scrollDirection: Axis.horizontal,
                              itemCount: articles.length,
                              itemBuilder: (context, index) => ArticleTrendItem(
                                document: articles[index],
                                isDark: isDark,
                                onTap: () => _navigateToArticle(articles[index]),
                              ),
                            ),
                    ),
                    const SizedBox(height: 25),
                    CommunitySection(isDark: isDark),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          }
          
          print("⚠️ [_HomeViewState] État non géré: ${state.runtimeType}");
          return const SizedBox();
        },
      ),
    );
  }

  void _navigateToDocumentDetail(AcademicDocument document) {
    print("📄 [_HomeViewState] Navigation vers détail document: ${document.id}");
    context.push('/document/${document.id}', extra: document);
  }

  void _navigateToArticle(Article article) {
    print("📰 [_HomeViewState] Navigation vers article: ${article.id}");
    context.push('/article/${article.id}', extra: article);
  }
  void _navigateToAllArticles(BuildContext context) {
    print("📰 [_HomeViewState] Navigation vers tous les articles");
    context.push('/articles');
  }
  void _navigateToAllDiscoveries(BuildContext context) {
  print("🔍 [_HomeViewState] Navigation vers toutes les découvertes");
  context.push('/discoveries');
}
void _openDiscoveryDetail(Decouverte discovery) {
    print("🔍 [AllDiscoveriesScreen] Ouverture détail découverte: ${discovery.id}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiscoveryDetailScreen(discovery: discovery),
      ),
    );
  }
void _openDiscoveryDetailFromAcademic(AcademicDocument doc) {
  // Construction d’un objet Decouverte à partir des champs disponibles
  final discovery = Decouverte(
    id: int.tryParse(doc.id) ?? 0,
    lien: doc.fichierUrl ?? '',
    image: doc.coverImageUrl,
    description: doc.description,
    dateCreation: doc.dateAjout,
    domaine: null,
    domaineNom: doc.faculty,
  );
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DiscoveryDetailScreen(discovery: discovery),
    ),
  );
}
  
}