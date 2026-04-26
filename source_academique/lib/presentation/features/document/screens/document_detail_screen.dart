import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:source_academique/core/utils/my_widget_factory.dart';
import 'package:source_academique/core/utils/share_utils.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';
import 'package:source_academique/presentation/features/document/screens/pdf_preview_screen.dart';
import 'package:source_academique/presentation/features/document/widgets/doc_header.dart';
import 'package:source_academique/presentation/features/document/widgets/doc_meta_section.dart';
import 'package:source_academique/presentation/features/document/widgets/download_progress_button.dart';

class DocumentDetailScreen extends StatelessWidget {
  final AcademicDocument document;

  DocumentDetailScreen({super.key, required this.document}) {
    print("📄 [DocumentDetailScreen] Constructeur - document: ${document.title} (id: ${document.id}) ( url: ${document.fichierUrl} )");
  }

  @override
  Widget build(BuildContext context) {
    print("📄 [DocumentDetailScreen.build] Début construction pour document: ${document.title}");
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasValidUrl = document.fichierUrl != null && document.fichierUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          DocHeader(
            id: document.id,
            imageUrl: document.coverImageUrl,
            onShare: () {
              print("📤 [DocumentDetailScreen] Appel de onShare pour document: ${document.title}");
              try {
                ShareUtils.shareDocument(document.title, document.fichierUrl ?? "");
                print("✅ [DocumentDetailScreen] Partage déclenché avec succès");
              } catch (e, stackTrace) {
                print("❌ [DocumentDetailScreen] Erreur lors du partage: $e");
                print("📚 StackTrace: $stackTrace");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erreur de partage: $e")),
                );
              }
            },
          ),
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -30, 0),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32), // Réduit le padding bottom
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DocMetaSection(
                      title: document.title,
                      type: document.type,
                      size: document.fileSize,
                      format: document.fileFormat,
                      pages: document.pagesCount,
                    ),
                    const SizedBox(height: 24),
                    
                    // Carte d'aperçu
                    _buildPreviewCard(context, theme, isDark, hasValidUrl),
                    
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 24),
                    
                    Text(
                      "DESCRIPTION", 
                      style: theme.textTheme.labelLarge?.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      )
                    ),
                    const SizedBox(height: 16),
                    HtmlWidget(
                      document.description.isNotEmpty 
                          ? document.description 
                          : "Aucune description disponible pour ce document.",
                      factoryBuilder: () {
                        print("🔧 [DocumentDetailScreen] Création du MathWidgetFactory pour le HTML");
                        return MathWidgetFactory();
                      },
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        fontSize: 15,
                      ),
                      onTapUrl: (url) async {
                        print("🔗 [DocumentDetailScreen] Clic sur lien: $url");
                        return false;
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // --- Section des boutons d'action (anciennement footer) ---
                    _buildActionButtons(context, hasValidUrl),

                    const SizedBox(height: 32),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool hasValidUrl) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        // Pas d'ombre ici car intégré dans le contenu
      ),
      child: Row(
        children: [
          // Bouton carré Aperçu
          _buildSquareButton(
            context,
            Icons.remove_red_eye_outlined,
            hasValidUrl
                ? () {
                    print("👁️ [DocumentDetailScreen] Bouton Aperçu cliqué pour: ${document.title}");
                    _openDocumentPreview(context, document.title, document.fichierUrl);
                  }
                : null,
          ),
          const SizedBox(width: 16),
          // Bouton Télécharger
          Expanded(
            child: DownloadProgressButton(
              fileUrl: document.fichierUrl ?? "",
              fileName: "${document.title}.${document.fileFormat.toLowerCase()}",
              onDownloadComplete: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Document téléchargé !")),
                );
              },
              onError: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Erreur de téléchargement"), backgroundColor: Colors.red),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareButton(BuildContext context, IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: onTap == null ? Colors.grey : null),
      ),
    );
  }

  // --- CARTE D'APERÇU AVEC GESTION D'ERREUR ---
  Widget _buildPreviewCard(BuildContext context, ThemeData theme, bool isDark, bool hasValidUrl) {
    IconData fileIcon = Icons.insert_drive_file;
    Color iconColor = Colors.grey;
    final format = document.fileFormat.toUpperCase();

    // Choix de l'icône selon le format
    if (format == 'PDF') {
      fileIcon = Icons.picture_as_pdf_rounded;
      iconColor = Colors.redAccent;
    } else if (format == 'DOC' || format == 'DOCX') {
      fileIcon = Icons.description_rounded;
      iconColor = Colors.blueAccent;
    } else if (format == 'PPT' || format == 'PPTX') {
      fileIcon = Icons.co_present_rounded;
      iconColor = Colors.orangeAccent;
    } else if (format == 'TXT') {
      fileIcon = Icons.text_snippet_rounded;
      iconColor = Colors.greenAccent;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.grey.shade900, Colors.grey.shade800]
              : [Colors.grey.shade50, Colors.grey.shade100],
        ),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasValidUrl
              ? () {
                  print("👁️ [DocumentDetailScreen] Carte Aperçu cliquée pour: ${document.title}");
                  _openDocumentPreview(context, document.title, document.fichierUrl);
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          splashColor: theme.colorScheme.primary.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icône avec effet de lueur
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        iconColor.withOpacity(0.2),
                        iconColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    fileIcon, 
                    size: 32, 
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasValidUrl ? "Ouvrir l'aperçu" : "Document indisponible",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasValidUrl
                            ? "Format $format • ${document.fileSize}"
                            : "Aucun fichier joint à ce document",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasValidUrl)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.block,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- OUVERTURE DU DOCUMENT AVEC GESTION D'ERREUR ---
  void _openDocumentPreview(BuildContext context, String title, String? url) {
    print("🔍 [DocumentDetailScreen._openDocumentPreview] Tentative d'ouverture du document: $title");
    print("   URL: $url");

    if (url == null || url.isEmpty) {
      print("⚠️ [DocumentDetailScreen._openDocumentPreview] URL du document est null ou vide");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Le lien du document n'est pas disponible.",
            style: TextStyle(fontSize: 14),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      print("✅ [DocumentDetailScreen._openDocumentPreview] Navigation vers PdfPreviewScreen");
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            print("📖 [DocumentDetailScreen] Construction de PdfPreviewScreen pour: $title");
            return PdfPreviewScreen(
              title: title,
              pdfUrl: url,
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } catch (e, stackTrace) {
      print("❌ [DocumentDetailScreen._openDocumentPreview] Erreur lors de la navigation: $e");
      print("📚 StackTrace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Impossible d'ouvrir le document: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}