// lib/presentation/features/notification/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:source_academique/core/config/service_locator.dart';
import 'package:source_academique/core/constants/app_colors.dart';
import 'package:source_academique/features/auth/data/repositories/notification_repository.dart';
import 'package:source_academique/features/auth/data/repositories/home_repository.dart';
import 'package:source_academique/features/auth/data/repositories/student_space_repository.dart';
import 'package:source_academique/features/auth/domain/entities/notification.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
import 'package:source_academique/presentation/features/article/screens/article_detail_screen.dart';
import 'package:source_academique/presentation/features/document/screens/document_detail_screen.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/posts/post_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationService _notificationService;
  late HomeRepository _homeRepository;
  late StudentSpaceRepository _postRepository;
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    print("🔔 [_NotificationsScreenState.initState] Initialisation");
    _notificationService = NotificationService(sl());
    _homeRepository = sl<HomeRepository>();
    _postRepository = sl<StudentSpaceRepository>();
    _loadNotifications();
  }

  // ------------------------------------------------------------------
  // Chargement des notifications depuis l'API
  // ------------------------------------------------------------------
  Future<void> _loadNotifications() async {
    print("🔔 [_NotificationsScreenState._loadNotifications] Début chargement");
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final notifications = await _notificationService.fetchNotifications();
      print("✅ [_NotificationsScreenState._loadNotifications] ${notifications.length} notifications chargées");
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print("❌ [_NotificationsScreenState._loadNotifications] Erreur: $e");
      print("📚 StackTrace: $stackTrace");
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // ------------------------------------------------------------------
  // Filtres
  // ------------------------------------------------------------------
  List<AppNotification> get _filteredNotifications {
    if (_filterType == 'all') return _notifications;
    if (_filterType == 'unread') return _notifications.where((n) => !n.isRead).toList();
    final type = NotificationType.values.firstWhere(
      (t) => t.name == _filterType,
      orElse: () => NotificationType.post,
    );
    return _notifications.where((n) => n.type == type).toList();
  }

  // ------------------------------------------------------------------
  // Clic sur une notification
  // ------------------------------------------------------------------
  void _onNotificationTap(AppNotification notification) async {
    print("🔔 [_NotificationsScreenState._onNotificationTap] Tap sur notification: ${notification.id} (${notification.type})");
    // Marquer localement comme lue (pour l'UI)
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) _notifications[index].isRead = true;
    });
    // Appel API désactivé car endpoint 404 (à implémenter côté backend)
    // await _notificationService.markAsRead(notification.id);
    await _navigateToDetail(context, notification);
  }

  // ------------------------------------------------------------------
  // Navigation vers l'écran de détail selon le type
  // ------------------------------------------------------------------
  Future<void> _navigateToDetail(BuildContext context, AppNotification notification) async {
    print("🔔 [_NotificationsScreenState._navigateToDetail] Type: ${notification.type}, targetId: ${notification.targetId}");
    try {
      switch (notification.type) {
        case NotificationType.post:
          await _openPostDetail(notification.targetId);
          break;
        case NotificationType.article:
          await _openArticleDetail(notification.targetId);
          break;
        case NotificationType.projet:
          await _openProjectDetail(notification.targetId);
          break;
        case NotificationType.decouverte:
          _openDiscoveryDetail(notification);
          break;
        case NotificationType.document:
          _openDocumentDetail(notification);
          break;
        case NotificationType.studentFile:
          await _openFileUrl(notification.message);
          break;
      }
    } catch (e, stackTrace) {
      print("❌ [_NotificationsScreenState._navigateToDetail] Erreur: $e");
      print("📚 StackTrace: $stackTrace");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'ouverture : $e")),
        );
      }
    }
  }

  // --- POST (récupération complète via StudentSpaceRepository) ---
  Future<void> _openPostDetail(String targetId) async {
    print("📱 [_NotificationsScreenState._openPostDetail] Récupération du post $targetId");
    try {
      final post = await _postRepository.getPostById(targetId);
      if (post != null && mounted) {
        print("✅ [_NotificationsScreenState._openPostDetail] Post trouvé, navigation");
        context.push('/post/${post.shareableId}', extra: post);
      } else if (mounted) {
        print("⚠️ [_NotificationsScreenState._openPostDetail] Post introuvable");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post introuvable")),
        );
      }
    } catch (e) {
      print("❌ [_NotificationsScreenState._openPostDetail] Erreur: $e");
      rethrow;
    }
  }

  // --- ARTICLE (récupération complète via HomeRepository) ---
  Future<void> _openArticleDetail(String targetId) async {
    final id = int.tryParse(targetId);
    if (id == null) {
      print("⚠️ [_NotificationsScreenState._openArticleDetail] ID invalide: $targetId");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Identifiant d'article invalide")),
        );
      }
      return;
    }
    print("📰 [_NotificationsScreenState._openArticleDetail] Récupération article $id");
    try {
      final article = await _homeRepository.getArticleById(id);
      if (article != null && mounted) {
        print("✅ [_NotificationsScreenState._openArticleDetail] Article trouvé, navigation");
        context.push('/article/${article.id}', extra: article);
      } else if (mounted) {
        print("⚠️ [_NotificationsScreenState._openArticleDetail] Article introuvable");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Article introuvable")),
        );
      }
    } catch (e) {
      print("❌ [_NotificationsScreenState._openArticleDetail] Erreur: $e");
      rethrow;
    }
  }

  // --- PROJET (récupération complète via HomeRepository) ---
  Future<void> _openProjectDetail(String targetId) async {
    final id = int.tryParse(targetId);
    if (id == null) {
      print("⚠️ [_NotificationsScreenState._openProjectDetail] ID invalide: $targetId");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Identifiant de projet invalide")),
        );
      }
      return;
    }
    print("🚀 [_NotificationsScreenState._openProjectDetail] Récupération projet $id");
    try {
      final project = await _homeRepository.getProjectById(id);
      if (project != null && mounted) {
        print("✅ [_NotificationsScreenState._openProjectDetail] Projet trouvé, navigation");
        context.push('/project/${project.id}', extra: project);
      } else if (mounted) {
        print("⚠️ [_NotificationsScreenState._openProjectDetail] Projet introuvable");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Projet introuvable")),
        );
      }
    } catch (e) {
      print("❌ [_NotificationsScreenState._openProjectDetail] Erreur: $e");
      rethrow;
    }
  }

  // --- DÉCOUVERTE (objet partiel, mais navigation possible) ---
  void _openDiscoveryDetail(AppNotification notification) {
    print("💡 [_NotificationsScreenState._openDiscoveryDetail] Découverte ${notification.targetId}");
    final discovery = Decouverte(
      id: int.tryParse(notification.targetId) ?? 0,
      lien: '',
      image: notification.imageUrl,
      document: null,
      description: notification.message,
      dateCreation: notification.createdAt,
      domaine: null,
      domaineNom: '',
    );
    if (mounted) {
      context.push('/discovery/${notification.targetId}', extra: discovery);
    }
  }

  // --- DOCUMENT (objet partiel) ---
  void _openDocumentDetail(AppNotification notification) {
    print("📄 [_NotificationsScreenState._openDocumentDetail] Document ${notification.targetId}");
    final doc = AcademicDocument(
      id: notification.targetId,
      title: notification.title,
      faculty: '',
      badge: 'DOCUMENT',
      coverImageUrl: notification.imageUrl ?? '',
      rating: 0.0,
      reviewsCount: 0,
      description: notification.message,
      fileFormat: 'PDF',
      fileSize: '--',
      pagesCount: 0,
      author: '',
      totalViews: 0,
      promotion: '',
      dateAjout: notification.createdAt,
      fichierUrl: null,
      type: 'cours',
    );
    if (mounted) {
      context.push('/document/${notification.targetId}', extra: doc);
    }
  }

  // --- FICHIER ÉTUDIANT ---
  Future<void> _openFileUrl(String url) async {
    print("📂 [_NotificationsScreenState._openFileUrl] Ouverture fichier: $url");
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      print("✅ [_NotificationsScreenState._openFileUrl] Fichier ouvert");
    } else {
      print("⚠️ [_NotificationsScreenState._openFileUrl] Impossible d'ouvrir $url");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'ouvrir le fichier")),
        );
      }
    }
  }

  // ------------------------------------------------------------------
  // Actions de masse
  // ------------------------------------------------------------------
  Future<void> _markAllAsRead() async {
    print("🔔 [_NotificationsScreenState._markAllAsRead] Marquage global (local seulement)");
    setState(() {
      for (var n in _notifications) n.isRead = true;
    });
    // Appel API désactivé (404)
    // await _notificationService.markAllAsRead();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Toutes les notifications marquées comme lues (local)")),
      );
    }
  }

  void _clearAll() {
    print("🔔 [_NotificationsScreenState._clearAll] Suppression de toutes les notifications (local)");
    setState(() => _notifications = []);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Toutes les notifications effacées")),
      );
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  // ------------------------------------------------------------------
  // Construction UI
  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    print("🔔 [_NotificationsScreenState.build] Reconstruction, mode ${isDark ? 'sombre' : 'clair'}");

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        leading: _buildGlassBackButton(context),
        title: Row(
          children: [
            const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
            if (_unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
                child: Text("$_unreadCount", style: const TextStyle(fontSize: 11, color: Colors.white)),
              ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'mark_all') _markAllAsRead();
              if (value == 'clear_all') _clearAll();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'mark_all', child: Text("Tout marquer comme lu")),
              const PopupMenuItem(value: 'clear_all', child: Text("Effacer tout")),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
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
                            ElevatedButton(onPressed: _loadNotifications, child: const Text("Réessayer")),
                          ],
                        ),
                      )
                    : _notifications.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            itemCount: _filteredNotifications.length,
                            separatorBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(left: 80),
                              child: Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                            ),
                            itemBuilder: (context, index) {
                              final notification = _filteredNotifications[index];
                              return WhatsAppNotificationTile(
                                notification: notification,
                                onTap: () => _onNotificationTap(notification),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // Widgets réutilisables
  // ------------------------------------------------------------------
  Widget _buildFilterChips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final types = [
      {'value': 'all', 'label': 'Tout', 'icon': Icons.grid_view},
      {'value': 'unread', 'label': 'Non lus', 'icon': Icons.circle},
      {'value': 'post', 'label': 'Posts', 'icon': Icons.chat_bubble_outline},
      {'value': 'article', 'label': 'Articles', 'icon': Icons.article_outlined},
      {'value': 'decouverte', 'label': 'Découvertes', 'icon': Icons.lightbulb_outline},
      {'value': 'projet', 'label': 'Projets', 'icon': Icons.rocket_launch_outlined},
      {'value': 'document', 'label': 'Documents', 'icon': Icons.description_outlined},
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = _filterType == type['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type['label'] as String),
              selected: isSelected,
              onSelected: (_) => setState(() => _filterType = type['value'] as String),
              avatar: Icon(type['icon'] as IconData, size: 16),
              backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text("Rien de neuf pour l'instant !", style: TextStyle(color: Colors.grey)),
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

// ========== WIDGET NOTIFICATION STYLE WHATSAPP ==========
class WhatsAppNotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const WhatsAppNotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatWhatsAppDate(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: notification.isRead
                              ? Colors.grey
                              : (isDark ? AppColors.secondary : const Color(0xFF25D366)),
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                          decoration: const BoxDecoration(color: Color(0xFF25D366), shape: BoxShape.circle),
                          child: const Center(
                            child: Text("1", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
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

  Widget _buildAvatar() {
    IconData icon;
    Color backgroundColor;

    switch (notification.type) {
      case NotificationType.post:
        icon = Icons.chat_bubble_outline;
        backgroundColor = Colors.blue;
        break;
      case NotificationType.decouverte:
        icon = Icons.lightbulb_outline;
        backgroundColor = Colors.orange;
        break;
      case NotificationType.article:
        icon = Icons.article_outlined;
        backgroundColor = Colors.green;
        break;
      case NotificationType.projet:
        icon = Icons.rocket_launch_outlined;
        backgroundColor = Colors.purple;
        break;
      case NotificationType.document:
        icon = Icons.description_outlined;
        backgroundColor = Colors.red;
        break;
      case NotificationType.studentFile:
        icon = Icons.cloud_upload_outlined;
        backgroundColor = Colors.teal;
        break;
    }

    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(child: Icon(icon, color: backgroundColor, size: 30)),
    );
  }

  String _formatWhatsAppDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) {
      return DateFormat('HH:mm').format(date);
    } else if (today.difference(notificationDate).inDays == 1) {
      return "Hier";
    } else {
      return DateFormat('dd/MM/yy').format(date);
    }
  }
}