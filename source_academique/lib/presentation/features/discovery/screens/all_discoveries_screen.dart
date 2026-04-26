// lib/presentation/features/discovery/screens/all_discoveries_screen.dart
import 'package:flutter/material.dart';
import 'package:source_academique/core/constants/app_colors.dart';
import 'package:source_academique/core/utils/image_utils.dart';
import 'package:source_academique/features/auth/data/repositories/home_repository.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:source_academique/core/config/service_locator.dart';
import 'package:source_academique/core/constants/ui_dimensions.dart';
import 'package:source_academique/presentation/features/home/presentation/widgets/search_bar_custom.dart';

class AllDiscoveriesScreen extends StatefulWidget {
  const AllDiscoveriesScreen({super.key});

  @override
  State<AllDiscoveriesScreen> createState() => _AllDiscoveriesScreenState();
}

class _AllDiscoveriesScreenState extends State<AllDiscoveriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  List<Decouverte> _discoveries = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadDiscoveries();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _loadDiscoveries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repository = sl<HomeRepository>();
      final discoveries = await repository.getAllDiscoveries();
      setState(() {
        _discoveries = discoveries;
        _isLoading = false;
      });
      print("🔍 [AllDiscoveriesScreen] ${_discoveries.length} découvertes chargées");
    } catch (e) {
      print("❌ [AllDiscoveriesScreen] Erreur: $e");
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Decouverte> get _filteredDiscoveries {
    if (_searchQuery.isEmpty) return _discoveries;
    return _discoveries.where((d) =>
      d.description.toLowerCase().contains(_searchQuery) ||
      d.domaineNom.toLowerCase().contains(_searchQuery)
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
        leading: _buildGlassBackButton(context),
        title: const Text("Toutes les découvertes"),
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
                              onPressed: _loadDiscoveries,
                              child: const Text("Réessayer"),
                            ),
                          ],
                        ),
                      )
                    : _filteredDiscoveries.isEmpty
                        ? const Center(child: Text("Aucune découverte trouvée"))
                        : GridView.builder(
                            padding: const EdgeInsets.all(UiDimensions.paddingMedium),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _filteredDiscoveries.length,
                            itemBuilder: (context, index) {
                              final discovery = _filteredDiscoveries[index];
                              return _DiscoveryCard(
                                discovery: discovery,
                                onTap: () => _openDiscoveryDetail(discovery),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

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

  void _openDiscoveryDetail(Decouverte discovery) {
    print("🔍 [AllDiscoveriesScreen] Ouverture détail découverte: ${discovery.id}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiscoveryDetailScreen(discovery: discovery),
      ),
    );
  }
}

// ========== CARTE AVEC TEXTE FLOTTANT SUR L'IMAGE ==========
class _DiscoveryCard extends StatelessWidget {
  final Decouverte discovery;
  final VoidCallback onTap;

  const _DiscoveryCard({required this.discovery, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Choix de l'image : priorité à discovery.image (personnalisée) sinon image par défaut thématique
    final String imageUrl =ImageUtils.getDefaultImage('decouverte', seed: discovery.id.hashCode);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Image de fond
              Image.network(
                imageUrl,
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),
              // Overlay semi-transparent pour améliorer la lisibilité du texte
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
              // Texte flottant (en bas de la carte)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      discovery.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      discovery.domaineNom,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white70),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== ÉCRAN DE DÉTAIL (inchangé, sauf correction d'import) ==========
class DiscoveryDetailScreen extends StatefulWidget {
  final Decouverte discovery;

  const DiscoveryDetailScreen({super.key, required this.discovery});

  @override
  State<DiscoveryDetailScreen> createState() => _DiscoveryDetailScreenState();
}

class _DiscoveryDetailScreenState extends State<DiscoveryDetailScreen> {
  static const List<String> _mois = [
    'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
    'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
  ];

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} ${_mois[date.month - 1]} ${date.year}";
  }

  Future<void> _openLink() async {
    final uri = Uri.parse(widget.discovery.lien);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Le lien semble brisé ou inaccessible."),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: size.height * 0.45,
            stretch: true,
            pinned: true,
            backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
            elevation: 0,
            leading: _buildGlassBackButton(context),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    ImageUtils.getDefaultImage('decouverte', seed: widget.discovery.id.hashCode),
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          isDark ? AppColors.bgDark : AppColors.bgLight,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AnimatedSlideFade(
                    delayMs: 100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: AppColors.secondary.withOpacity(0.5), blurRadius: 8),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.discovery.domaineNom.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(widget.discovery.dateCreation),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _AnimatedSlideFade(
                    delayMs: 250,
                    child: Text(
                      widget.discovery.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        height: 1.8,
                        color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (widget.discovery.lien.isNotEmpty)
                    _AnimatedSlideFade(
                      delayMs: 400,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: AppColors.gradientNeon,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: _openLink,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Explorer la source",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
}

class _AnimatedSlideFade extends StatelessWidget {
  final Widget child;
  final int delayMs;

  const _AnimatedSlideFade({required this.child, required this.delayMs});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: FutureBuilder(
        future: Future.delayed(Duration(milliseconds: delayMs)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }
          return child;
        },
      ),
    );
  }
}