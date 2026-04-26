// lib/presentation/features/space_stadent/screens/create_post_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:source_academique/core/constants/app_colors.dart';
import 'package:source_academique/features/auth/domain/entities/student_post.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/shared/student_glass_card.dart';

class CreatePostScreen extends StatefulWidget {
  final PostNews? post;
  final Future<void> Function(String content, List<String> filePaths)? onCreatePost;
  final Future<void> Function(String shareableId, String content)? onUpdatePost;

  const CreatePostScreen({
    super.key,
    this.post,
    this.onCreatePost,
    this.onUpdatePost,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late TextEditingController _contentController;
  final List<PlatformFile> _selectedFiles = [];
  bool _isLoading = false;
  late bool _isEditing;
  String _errorMessage = '';
  String _successMessage = '';
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.post != null;
    _contentController = TextEditingController(text: widget.post?.titre ?? "");
    print("🟢 [CreatePostScreen] initState - Mode: ${_isEditing ? 'Édition' : 'Création'}");
  }

  @override
  void dispose() {
    _contentController.dispose();
    print("🔴 [CreatePostScreen] dispose - Écran détruit");
    super.dispose();
  }

  Future<void> _pickFiles() async {
    print("📁 [PickFiles] Début sélection de fichiers");
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx', 'ppt', 'pptx'],
      );
      
      if (result != null && result.files.isNotEmpty) {
        print("✅ [PickFiles] ${result.files.length} fichiers sélectionnés");
        setState(() {
          _selectedFiles.addAll(result.files);
          _errorMessage = '';
        });
      } else {
        print("⚠️ [PickFiles] Aucun fichier sélectionné");
      }
    } catch (e, stackTrace) {
      print("❌ [PickFiles] Erreur: $e");
      print("📚 StackTrace: $stackTrace");
      setState(() {
        _errorMessage = "Erreur lors de la sélection: $e";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _removeFile(int index) {
    print("🗑️ [RemoveFile] Suppression fichier index $index: ${_selectedFiles[index].name}");
    setState(() {
      _selectedFiles.removeAt(index);
      _errorMessage = '';
    });
  }

  Future<void> _submitPost() async {
    final content = _contentController.text.trim();
    print("📝 [SubmitPost] Début soumission - Contenu: ${content.length} caractères, Fichiers: ${_selectedFiles.length}");
    
    // Validation
    if (content.isEmpty && _selectedFiles.isEmpty) {
      print("⚠️ [SubmitPost] Validation échouée: pas de contenu et pas de fichiers");
      setState(() {
        _errorMessage = "Ajoutez du texte ou un fichier";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ajoutez du texte ou un fichier"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isUploading = true;
      _errorMessage = '';
      _uploadProgress = 0.0;
    });

    try {
      // Traitement des fichiers
      final List<String> filePaths = [];
      print("📂 [SubmitPost] Traitement de ${_selectedFiles.length} fichiers");
      
      for (int i = 0; i < _selectedFiles.length; i++) {
        final file = _selectedFiles[i];
        print("📄 [SubmitPost] Fichier ${i+1}/${_selectedFiles.length}: ${file.name} (${_formatFileSize(file.size)})");
        
        setState(() {
          _uploadProgress = (i + 1) / _selectedFiles.length;
        });
        
        if (kIsWeb) {
          if (file.bytes != null) {
            print("🌐 [SubmitPost] Web: fichier ${file.name} prêt (${file.bytes?.length} bytes)");
            // TODO: Upload des bytes vers le serveur
          } else {
            print("⚠️ [SubmitPost] Web: fichier ${file.name} sans données");
          }
        } else {
          if (file.path != null) {
            print("📱 [SubmitPost] Mobile/Desktop: chemin ${file.path}");
            filePaths.add(file.path!);
          } else {
            print("⚠️ [SubmitPost] Mobile/Desktop: chemin null pour ${file.name}");
          }
        }
      }
      
      print("🎯 [SubmitPost] Appel du callback...");
      if (_isEditing) {
        if (widget.onUpdatePost != null) {
          print("✏️ [SubmitPost] Mode Édition - ID: ${widget.post!.shareableId}");
          await widget.onUpdatePost!(widget.post!.shareableId, content);
        } else {
          throw Exception("Callback onUpdatePost non fourni");
        }
      } else {
        if (widget.onCreatePost != null) {
          print("✨ [SubmitPost] Mode Création - Contenu: ${content.substring(0, content.length > 50 ? 50 : content.length)}...");
          await widget.onCreatePost!(content, filePaths);
        } else {
          throw Exception("Callback onCreatePost non fourni");
        }
      }
      
      setState(() {
        _successMessage = _isEditing ? "Post modifié avec succès" : "Post publié avec succès";
        _uploadProgress = 1.0;
      });
      
      print("✅ [SubmitPost] Succès - $_successMessage");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_successMessage),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e, stackTrace) {
      print("❌ [SubmitPost] Erreur: $e");
      print("📚 StackTrace: $stackTrace");
      setState(() {
        _errorMessage = "Erreur: ${e.toString()}";
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
        });
      }
      print("🏁 [SubmitPost] Fin du processus");
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    print("🎨 [CreatePostScreen] build - Mode: ${_isEditing ? 'Édition' : 'Création'}");

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Modifier la publication" : "Nouvelle publication"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            print("🔙 [AppBar] Retour arrière");
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child: Text(
              _isEditing ? "Modifier" : "Publier",
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Zone de saisie du texte
                StudentGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _contentController,
                        maxLines: 10,
                        minLines: 3,
                        autofocus: true,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: "Quoi de neuf ?",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: InputBorder.none,
                        ),
                      ),
                      if (_errorMessage.isNotEmpty && !_isLoading) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, size: 16, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Zone d'aperçu des fichiers sélectionnés
                if (_selectedFiles.isNotEmpty) ...[
                  const Text(
                    "Pièces jointes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._selectedFiles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    final fileSize = _formatFileSize(file.size);
                    
                    return StudentGlassCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          _buildFileIcon(file.name),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  file.name,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  fileSize,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20, color: Colors.red),
                            onPressed: () => _removeFile(index),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                // Bouton d'ajout de fichiers
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _isLoading ? null : _pickFiles,
                  child: StudentGlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.attach_file, color: _isLoading ? Colors.grey : AppColors.secondary),
                        const SizedBox(width: 8),
                        Text(
                          "Ajouter des fichiers",
                          style: TextStyle(color: _isLoading ? Colors.grey : AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                ),

                // Info sur les formats acceptés
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    "Formats acceptés : Images, PDF, DOC, DOCX, PPT",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ),
          
          // Overlay de chargement avec progression
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: Center(
                child: StudentGlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        _isEditing ? "Modification en cours..." : "Publication en cours...",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (_selectedFiles.isNotEmpty) ...[
                        LinearProgressIndicator(
                          value: _uploadProgress,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation(Colors.green),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${(_uploadProgress * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    IconData icon;
    Color color;

    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        icon = Icons.image;
        color = Colors.green;
        break;
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description;
        color = Colors.blue;
        break;
      case 'ppt':
      case 'pptx':
        icon = Icons.slideshow;
        color = Colors.orange;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}