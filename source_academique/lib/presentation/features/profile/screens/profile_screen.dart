// lib/features/profile/presentation/screens/profile_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:source_academique/core/config/service_locator.dart';
import 'package:source_academique/features/auth/data/repositories/academic_repository.dart';

// Modèles et Services
import 'package:source_academique/features/auth/domain/entities/etablissement.dart';
import 'package:source_academique/features/auth/domain/entities/profile_model.dart';
import 'package:source_academique/features/auth/presentation/bloc/auth_bloc.dart';

// Constantes et Widgets
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/ui_dimensions.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_form_fields.dart';

import 'package:permission_handler/permission_handler.dart';

// ============================================================================
// CLASSE: ProfileScreen (StatefulWidget)
// ============================================================================
// DESCRIPTION: Écran de profil utilisateur permettant de visualiser et modifier
//              les informations personnelles, académiques et la photo de profil.
// ============================================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// ============================================================================
// CLASSE: _ProfileScreenState (State<ProfileScreen>)
// ============================================================================
// DESCRIPTION: État de l'écran de profil contenant la logique de modification,
//              chargement des données académiques, et gestion des mises à jour.
// ============================================================================

class _ProfileScreenState extends State<ProfileScreen> {
  // ==========================================================================
  // SECTION 1: DÉCLARATION DES VARIABLES D'ÉTAT
  // ==========================================================================
  
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Contrôleurs de texte
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;
  late TextEditingController _whatsappController;

  // Données pour les dropdowns dynamiques
  List<Universite> _universities = [];
  List<Faculte> _faculties = [];
  List<Departement> _departments = [];

  // Valeurs sélectionnées
  Universite? _selectedUniversity;
  Faculte? _selectedFaculty;
  Departement? _selectedDepartment;
  String? _selectedPromotion;

  // États de chargement des dropdowns
  bool _isLoadingUniversities = false;
  bool _isLoadingFaculties = false;
  bool _isLoadingDepartments = false;

  // ✅ Liste des promotions alignée avec le modèle Django
  final List<String> _promotions = [
    "PREPA",
    "L1",
    "L2",
    "L3",
    "M1",
    "M2",
    "Doctorat",
  ];

  // ✅ Map pour l'affichage des libellés complets
  final Map<String, String> _promotionDisplayMap = {
    "PREPA": "PREPA - Préparatoire",
    "L1": "L1 - Licence 1",
    "L2": "L2 - Licence 2",
    "L3": "L3 - Licence 3",
    "M1": "M1 - Master 1",
    "M2": "M2 - Master 2",
    "Doctorat": "Doctorat",
  };

  // ==========================================================================
  // SECTION 2: CYCLE DE VIE - initState()
  // ==========================================================================
  // MÉTHODE: initState()
  // DESCRIPTION: Initialise les contrôleurs et déclenche le chargement du profil.
  // SUIVI: ✅ Appelée automatiquement lors de la création du widget.
  // ==========================================================================
  
  @override
  void initState() {
    super.initState();
    print("🔷 [ProfileScreen.initState] Début de l'initialisation");
    
    // Étape 1: Initialisation des contrôleurs
    print("🔹 [ProfileScreen.initState] Étape 1: Initialisation des contrôleurs");
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _bioController = TextEditingController();
    _whatsappController = TextEditingController();
    print("✅ Contrôleurs initialisés");
    
    // Étape 2: Chargement du profil via ProfileBloc
    print("🔹 [ProfileScreen.initState] Étape 2: Déclenchement du chargement du profil");
    context.read<ProfileBloc>().add(const LoadProfile());
    print("✅ Événement LoadProfile envoyé");
    
    print("✅ [ProfileScreen.initState] Initialisation terminée");
  }

  // ==========================================================================
  // SECTION 3: CYCLE DE VIE - dispose()
  // ==========================================================================
  // MÉTHODE: dispose()
  // DESCRIPTION: Nettoie les contrôleurs pour éviter les fuites mémoire.
  // SUIVI: ✅ Appelée automatiquement lors de la destruction du widget.
  // ==========================================================================
  
  @override
  void dispose() {
    print("🔷 [ProfileScreen.dispose] Nettoyage des ressources");
    
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _whatsappController.dispose();
    
    print("✅ [ProfileScreen.dispose] Ressources nettoyées");
    super.dispose();
  }

  // ==========================================================================
  // SECTION 4: SYNCHRONISATION DES CONTRÔLEURS
  // ==========================================================================
  // MÉTHODE: _syncControllers(ProfileLoaded state)
  // DESCRIPTION: Met à jour les contrôleurs avec les données du profil chargé.
  // SUIVI: ✅ Appelée via BlocListener lors de ProfileLoaded.
  // ==========================================================================
  
  void _syncControllers(ProfileLoaded state) {
    print("🔷 [ProfileScreen._syncControllers] Synchronisation des contrôleurs");
    
    _firstNameController.text = state.profile.firstName;
    _lastNameController.text = state.profile.lastName;
    _bioController.text = state.profile.description ?? "";
    _whatsappController.text = state.profile.whatsapp;
    
    // ✅ Conversion de la promotion (ex: "L1 - Licence 1" -> "L1")
    String? promotionCode = state.profile.promotion;
    if (promotionCode != null && promotionCode.contains(" - ")) {
      promotionCode = promotionCode.split(" - ").first;
      print("📊 Promotion convertie: ${state.profile.promotion} -> $promotionCode");
    }
    
    if (promotionCode != null && _promotions.contains(promotionCode)) {
      _selectedPromotion = promotionCode;
      print("✅ Promotion sélectionnée: $_selectedPromotion");
    } else {
      _selectedPromotion = null;
      print("⚠️ Promotion non reconnue: ${state.profile.promotion}");
    }
    
    print("📊 Champs texte synchronisés");

    // Pré-sélectionner les valeurs académiques depuis le profil
    if (state.profile.universityName.isNotEmpty) {
      _selectedUniversity = Universite(
        id: 0,
        nom: state.profile.universityName,
      );
      print("🏛️ Université pré-sélectionnée: ${state.profile.universityName}");
    }
    if (state.profile.faculty.isNotEmpty) {
      _selectedFaculty = Faculte(
        id: 0,
        nom: state.profile.faculty,
      );
      print("📚 Faculté pré-sélectionnée: ${state.profile.faculty}");
    }
    if (state.profile.department.isNotEmpty) {
      _selectedDepartment = Departement(
        id: 0,
        nom: state.profile.department,
      );
      print("📖 Département pré-sélectionné: ${state.profile.department}");
    }

    // Charger les données académiques en fonction du profil
    _loadInitialAcademicData(state.profile);
    
    print("✅ [ProfileScreen._syncControllers] Synchronisation terminée");
  }

  // ==========================================================================
  // SECTION 5: CHARGEMENT INITIAL DES DONNÉES ACADÉMIQUES
  // ==========================================================================
  // MÉTHODE: _loadInitialAcademicData(UserProfile profile)
  // DESCRIPTION: Charge les universités, facultés et départements depuis l'API
  //              pour initialiser les dropdowns avec les valeurs du profil.
  // SUIVI: ✅ Appelée dans _syncControllers().
  // ERREURS: Affiche un message d'erreur en cas d'échec.
  // ==========================================================================
  
  Future<void> _loadInitialAcademicData(UserProfile profile) async {
    print("🔷 [ProfileScreen._loadInitialAcademicData] Début du chargement");
    print("📊 Profil reçu: Université='${profile.universityName}', Faculté='${profile.faculty}', Département='${profile.department}'");
    
    final academicRepo = sl<AcademicRepository>();
    
    // Étape 1: Chargement des universités
    setState(() => _isLoadingUniversities = true);
    print("🔹 Étape 1: Chargement des universités");
    
    try {
      final univs = await academicRepo.getUniversities();
      setState(() {
        _universities = univs;
        _isLoadingUniversities = false;
      });
      print("✅ ${univs.length} universités chargées");

      // Étape 2: Recherche et sélection de l'université
      if (profile.universityName.isNotEmpty && _universities.isNotEmpty) {
        print("🔹 Étape 2: Recherche de l'université '${profile.universityName}'");
        _selectedUniversity = _universities.firstWhere(
          (u) => u.nom == profile.universityName,
          orElse: () {
            print("⚠️ Université '${profile.universityName}' non trouvée, sélection de la première");
            return _universities.first;
          },
        );
        print("✅ Université sélectionnée: ${_selectedUniversity!.nom} (ID: ${_selectedUniversity!.id})");

        // Étape 3: Chargement des facultés
        if (_selectedUniversity!.id != null) {
          await _loadFaculties(_selectedUniversity!.id!);
        }

        // Étape 4: Recherche et sélection de la faculté
        if (profile.faculty.isNotEmpty && _faculties.isNotEmpty) {
          print("🔹 Étape 4: Recherche de la faculté '${profile.faculty}'");
          _selectedFaculty = _faculties.firstWhere(
            (f) => f.nom == profile.faculty,
            orElse: () {
              print("⚠️ Faculté '${profile.faculty}' non trouvée, sélection de la première");
              return _faculties.first;
            },
          );
          print("✅ Faculté sélectionnée: ${_selectedFaculty!.nom} (ID: ${_selectedFaculty!.id})");

          // Étape 5: Chargement des départements
          if (_selectedFaculty!.id != null) {
            await _loadDepartments(_selectedFaculty!.id!);
          }

          // Étape 6: Recherche et sélection du département
          if (profile.department.isNotEmpty && _departments.isNotEmpty) {
            print("🔹 Étape 6: Recherche du département '${profile.department}'");
            _selectedDepartment = _departments.firstWhere(
              (d) => d.nom == profile.department,
              orElse: () {
                print("⚠️ Département '${profile.department}' non trouvé, sélection du premier");
                return _departments.first;
              },
            );
            print("✅ Département sélectionné: ${_selectedDepartment!.nom} (ID: ${_selectedDepartment!.id})");
          }
        }
      }
    } catch (e) {
      print("❌ [ProfileScreen._loadInitialAcademicData] ERREUR: ${e.toString()}");
      setState(() => _isLoadingUniversities = false);
      _showError("Impossible de charger les données académiques");
    }
    
    print("✅ [ProfileScreen._loadInitialAcademicData] Chargement terminé");
  }

  // ==========================================================================
  // SECTION 6: CHARGEMENT DES FACULTÉS
  // ==========================================================================
  // MÉTHODE: _loadFaculties(int universityId)
  // DESCRIPTION: Charge les facultés d'une université spécifique.
  // SUIVI: ✅ Appelée après sélection d'une université.
  // ERREURS: Log l'erreur, désactive l'indicateur de chargement.
  // ==========================================================================
  
  Future<void> _loadFaculties(int universityId) async {
    print("🔷 [ProfileScreen._loadFaculties] Début - universityId: $universityId");
    
    setState(() => _isLoadingFaculties = true);
    final academicRepo = sl<AcademicRepository>();
    
    try {
      final facs = await academicRepo.getFaculties(universityId);
      setState(() {
        _faculties = facs;
        _isLoadingFaculties = false;
      });
      print("✅ ${facs.length} facultés chargées");
    } catch (e) {
      print("❌ [ProfileScreen._loadFaculties] ERREUR: ${e.toString()}");
      setState(() => _isLoadingFaculties = false);
      _showError("Erreur chargement des facultés");
    }
    
    print("🔷 [ProfileScreen._loadFaculties] Fin");
  }

  // ==========================================================================
  // SECTION 7: CHARGEMENT DES DÉPARTEMENTS
  // ==========================================================================
  // MÉTHODE: _loadDepartments(int facultyId)
  // DESCRIPTION: Charge les départements d'une faculté spécifique.
  // SUIVI: ✅ Appelée après sélection d'une faculté.
  // ERREURS: Log l'erreur, désactive l'indicateur de chargement.
  // ==========================================================================
  
  Future<void> _loadDepartments(int facultyId) async {
    print("🔷 [ProfileScreen._loadDepartments] Début - facultyId: $facultyId");
    
    setState(() => _isLoadingDepartments = true);
    final academicRepo = sl<AcademicRepository>();
    
    try {
      final deps = await academicRepo.getDepartments(facultyId);
      setState(() {
        _departments = deps;
        _isLoadingDepartments = false;
      });
      print("✅ ${deps.length} départements chargés");
    } catch (e) {
      print("❌ [ProfileScreen._loadDepartments] ERREUR: ${e.toString()}");
      setState(() => _isLoadingDepartments = false);
      _showError("Erreur chargement des départements");
    }
    
    print("🔷 [ProfileScreen._loadDepartments] Fin");
  }

  // ==========================================================================
  // SECTION 8: AFFICHAGE DES ERREURS
  // ==========================================================================
  // MÉTHODE: _showError(String message)
  // DESCRIPTION: Affiche un SnackBar d'erreur à l'utilisateur.
  // SUIVI: ✅ Appelée en cas d'exception.
  // ==========================================================================
  
  void _showError(String message) {
    print("🔴 [ProfileScreen._showError] $message");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ==========================================================================
  // SECTION 9: MÉTHODE UTILITAIRE - AFFICHAGE PROMOTION
  // ==========================================================================
  // MÉTHODE: _getPromotionDisplay(String? code)
  // DESCRIPTION: Convertit un code promotion (ex: "L1") en libellé complet.
  // ==========================================================================
  
  String _getPromotionDisplay(String? code) {
    if (code == null) return "Non spécifié";
    return _promotionDisplayMap[code] ?? code;
  }

  // ==========================================================================
  // SECTION 10: BUILD - CONSTRUCTION DE L'INTERFACE
  // ==========================================================================
  // MÉTHODE: build(BuildContext context)
  // DESCRIPTION: Construit l'interface utilisateur complète du profil.
  // SUIVI: ✅ Appelée à chaque reconstruction de l'état.
  // ==========================================================================
  
  @override
  Widget build(BuildContext context) {
    print("🔷 [ProfileScreen.build] Construction de l'interface");
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        print("🔹 [ProfileScreen.build] BlocListener - État reçu: ${state.runtimeType}");
        
        if (state is ProfileLoaded) {
          print("✅ ProfileLoaded - Synchronisation des contrôleurs");
          _syncControllers(state);
        }
        
        if (state is ProfileUpdateSuccess) {
          print("✅ ProfileUpdateSuccess - Mise à jour réussie");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profil mis à jour avec succès"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        if (state is ProfileError) {
          print("❌ ProfileError - ${state.message}");
          _showError(state.message);
        }
      },
      builder: (context, state) {
        // Gestion de l'état de chargement
        if (state is ProfileLoading && state is! ProfileLoaded) {
          print("⏳ État ProfileLoading - Affichage du loader");
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = (state is ProfileLoaded) ? state.profile : null;

        if (profile == null) {
          print("⚠️ Profil null - Affichage de l'erreur");
          return const Scaffold(
            body: Center(child: Text("Erreur de chargement du profil")),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Mon Profil"),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.check_circle : Icons.edit_rounded),
                color: _isEditing ? AppColors.secondary : null,
                onPressed: () => _handleEditToggle(profile),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              print("🔄 Pull-to-refresh déclenché");
              context.read<ProfileBloc>().add(const LoadProfile());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(UiDimensions.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. HEADER avec photo de profil
                    ProfileHeader(
                      profile: profile,
                      isEditing: _isEditing,
                      isDark: isDark,
                      firstNameController: _firstNameController,
                      lastNameController: _lastNameController,
                      onImagePick: _showImagePicker,
                    ),
                    const SizedBox(height: 25),

                    // 2. STATS
                    ProfileStats(
                      docsCount: profile.documentsCount.toString(),
                      score: profile.averageRating.toStringAsFixed(1),
                      followersCount: '0',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 30),

                    // 3. INFOS PERSONNELLES
                    _buildSectionTitle("Informations", isDark),
                    const SizedBox(height: 12),
                    ProfileInfoCard(
                      icon: Icons.phone,
                      label: "WhatsApp",
                      value: _whatsappController.text.isEmpty ? "Non renseigné" : _whatsappController.text,
                      isDark: isDark,
                      isEditing: _isEditing,
                      onEdit: () => _editSingleField("WhatsApp", _whatsappController),
                    ),
                    ProfileInfoCard(
                      icon: Icons.email_outlined,
                      label: "Email",
                      value: profile.email,
                      isDark: isDark,
                      isEditing: false,
                    ),
                    const SizedBox(height: 20),

                    // 4. PARCOURS ACADÉMIQUE
                    _buildSectionTitle("Parcours Académique", isDark),
                    const SizedBox(height: 12),
                    _isEditing 
                        ? _buildAcademicEditors(isDark) 
                        : _buildAcademicDisplay(profile, isDark),
                    const SizedBox(height: 25),

                    // 5. BIOGRAPHIE
                    _buildSectionTitle("À propos", isDark),
                    const SizedBox(height: 12),
                    _buildBioField(isDark),
                    const SizedBox(height: 30),

                    // 6. MENU DE NAVIGATION
                    ProfileMenuTile(
                      icon: Icons.history_edu_rounded,
                      title: "Mes Publications",
                      subtitle: "Documents partagés",
                      isDark: isDark,
                      onTap: () => context.push('/my-posts'),
                    ),
                    ProfileMenuTile(
                      icon: Icons.favorite_border_rounded,
                      title: "Favoris",
                      subtitle: "Documents enregistrés",
                      isDark: isDark,
                      onTap: () => context.push('/favorites'),
                    ),
                    ProfileMenuTile(
                      icon: Icons.download_for_offline_outlined,
                      title: "Téléchargements",
                      subtitle: "Documents hors-ligne",
                      isDark: isDark,
                      onTap: () => context.push('/downloads'),
                    ),
                    ProfileMenuTile(
                      icon: Icons.settings_outlined,
                      title: "Paramètres",
                      subtitle: "Sécurité et thème",
                      isDark: isDark,
                      onTap: () => context.push('/settings'),
                    ),
                    const Divider(height: 40),
                    ProfileMenuTile(
                      icon: Icons.logout,
                      title: "Déconnexion",
                      subtitle: "Quitter l'application",
                      isDark: isDark,
                      onTap: _showLogoutDialog,
                      isDestructive: true,
                    ),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // SECTION 11: GESTION DU MODE ÉDITION
  // ==========================================================================
  // MÉTHODE: _handleEditToggle(UserProfile profile)
  // DESCRIPTION: Bascule entre mode affichage et mode édition.
  //              En mode édition, soumet les modifications via ProfileBloc.
  // SUIVI: ✅ Appelée via le bouton d'édition dans l'AppBar.
  // ==========================================================================
  
  void _handleEditToggle(UserProfile profile) {
    print("🔷 [ProfileScreen._handleEditToggle] _isEditing: $_isEditing");
    
    if (_isEditing) {
      // Validation et sauvegarde
      print("🔹 Mode édition -> Sauvegarde des modifications");
      if (_formKey.currentState!.validate()) {
        print("✅ Formulaire valide - Envoi de UpdateProfileRequested");
        
        final updateData = {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'description': _bioController.text,
          'numero_whatsapp': _whatsappController.text,
          'promotion': _selectedPromotion,
          'university_id': _selectedUniversity?.id,
          'faculty_id': _selectedFaculty?.id,
          'department_id': _selectedDepartment?.id,
        };
        
        print("📊 Données envoyées: $updateData");
        context.read<ProfileBloc>().add(UpdateProfileRequested(updateData));
        setState(() => _isEditing = false);
        print("✅ Mode édition désactivé");
      } else {
        print("❌ Formulaire invalide - Sauvegarde annulée");
      }
    } else {
      print("🔹 Mode affichage -> Activation du mode édition");
      setState(() => _isEditing = true);
      print("✅ Mode édition activé");
    }
  }

  // ==========================================================================
  // SECTION 12: GESTION DE LA DÉCONNEXION
  // ==========================================================================
  // MÉTHODE: _showLogoutDialog()
  // DESCRIPTION: Affiche une boîte de dialogue de confirmation de déconnexion.
  // SUIVI: ✅ Appelée via le menu de déconnexion.
  // ==========================================================================
  
  void _showLogoutDialog() {
    print("🔷 [ProfileScreen._showLogoutDialog] Affichage du dialogue de déconnexion");
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () {
              print("🔹 Annulation de la déconnexion");
              Navigator.pop(context);
            },
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              print("🔹 Confirmation de déconnexion - Envoi de LogoutRequested");
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pop(context);
              print("✅ Déconnexion en cours...");
            },
            child: const Text("Déconnexion", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SECTION 13: SÉLECTEUR DE PHOTO
  // ==========================================================================
  // MÉTHODE: _showImagePicker()
  // DESCRIPTION: Ouvre la galerie pour sélectionner une photo de profil.
  // SUIVI: ✅ Appelée via ProfileHeader.
  // ERREURS: Affiche un message d'erreur si la galerie ne peut pas être ouverte.
  // ==========================================================================
  
  Future<void> _showImagePicker() async {
    print("🔷 [ProfileScreen._showImagePicker] Ouverture de la galerie");
    
    try {
      // Vérification des permissions
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        print("❌ Permission refusée pour accéder à la galerie");
        _showError("Permission refusée pour accéder à la galerie");
        return;
      }
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        print("📸 Image sélectionnée: ${image.path}");
        final file = File(image.path);
        if (await file.exists()) {
          print("✅ Fichier valide - Envoi de UpdateProfilePhotoRequested");
          context.read<ProfileBloc>().add(UpdateProfilePhotoRequested(image.path));
        } else {
          print("❌ Fichier introuvable");
          _showError("Fichier introuvable, réessayez");
        }
      } else {
        print("⚠️ Aucune image sélectionnée");
      }
    } catch (e) {
      print("❌ [ProfileScreen._showImagePicker] ERREUR: ${e.toString()}");
      _showError("Impossible d'ouvrir la galerie");
    }
  }

  // ==========================================================================
  // SECTION 14: ÉDITION D'UN CHAMP INDIVIDUEL
  // ==========================================================================
  // MÉTHODE: _editSingleField(String label, TextEditingController controller)
  // DESCRIPTION: Affiche un dialogue pour modifier un champ simple.
  // SUIVI: ✅ Appelée via ProfileInfoCard en mode édition.
  // ==========================================================================
  
  void _editSingleField(String label, TextEditingController controller) {
    print("🔷 [ProfileScreen._editSingleField] Édition du champ: $label");
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Modifier $label"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: label),
          keyboardType: label == "WhatsApp" ? TextInputType.phone : TextInputType.text,
        ),
        actions: [
          TextButton(
            onPressed: () {
              print("🔹 Annulation de l'édition de $label");
              Navigator.pop(context);
            },
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              print("🔹 Validation de l'édition de $label - Nouvelle valeur: ${controller.text}");
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SECTION 15: TITRE DE SECTION
  // ==========================================================================
  // MÉTHODE: _buildSectionTitle(String title, bool isDark)
  // DESCRIPTION: Construit un titre de section stylisé.
  // ==========================================================================
  
  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: isDark ? Colors.white54 : Colors.black54,
      ),
    );
  }

  // ==========================================================================
  // SECTION 16: CHAMP BIOGRAPHIE
  // ==========================================================================
  // MÉTHODE: _buildBioField(bool isDark)
  // DESCRIPTION: Construit le champ de texte pour la biographie.
  // ==========================================================================
  
  Widget _buildBioField(bool isDark) {
    return TextFormField(
      controller: _bioController,
      maxLines: 3,
      enabled: _isEditing,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: "Parlez-nous de vous...",
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
      ),
    );
  }

  // ==========================================================================
  // SECTION 17: AFFICHAGE ACADÉMIQUE (MODE LECTURE)
  // ==========================================================================
  // MÉTHODE: _buildAcademicDisplay(UserProfile profile, bool isDark)
  // DESCRIPTION: Affiche les informations académiques en mode lecture seule.
  // ==========================================================================
  
  Widget _buildAcademicDisplay(UserProfile profile, bool isDark) {
    return Column(
      children: [
        ProfileInfoCard(
          icon: Icons.school,
          label: "Université",
          value: _selectedUniversity?.nom ?? profile.universityName,
          isDark: isDark,
        ),
        ProfileInfoCard(
          icon: Icons.account_balance,
          label: "Faculté",
          value: _selectedFaculty?.nom ?? profile.faculty,
          isDark: isDark,
        ),
        ProfileInfoCard(
          icon: Icons.category,
          label: "Département",
          value: _selectedDepartment?.nom ?? profile.department,
          isDark: isDark,
        ),
        ProfileInfoCard(
          icon: Icons.trending_up,
          label: "Promotion",
          value: _getPromotionDisplay(_selectedPromotion ?? profile.promotion),
          isDark: isDark,
        ),
      ],
    );
  }

  // ==========================================================================
  // SECTION 18: ÉDITEURS ACADÉMIQUES (MODE ÉDITION)
  // ==========================================================================
  // MÉTHODE: _buildAcademicEditors(bool isDark)
  // DESCRIPTION: Affiche les dropdowns pour modifier les informations académiques.
  // ==========================================================================
  
  Widget _buildAcademicEditors(bool isDark) {
    print("🔷 [ProfileScreen._buildAcademicEditors] Construction des dropdowns");
    
    return Column(
      children: [
        // Université
        if (_isLoadingUniversities)
          const Padding(
            padding: EdgeInsets.all(12),
            child: LinearProgressIndicator(),
          )
        else
          ProfileGlassDropdown(
            label: "Université",
            value: _selectedUniversity?.nom,
            items: _universities.map((u) => u.nom).toList(),
            onChanged: (val) async {
              print("🔹 Université sélectionnée: $val");
              if (val == null) return;
              final selected = _universities.firstWhere((u) => u.nom == val);
              setState(() {
                _selectedUniversity = selected;
                _selectedFaculty = null;
                _selectedDepartment = null;
                _faculties = [];
                _departments = [];
              });
              if (selected.id != null) {
                await _loadFaculties(selected.id!);
              }
            },
            isDark: isDark,
            enabled: _universities.isNotEmpty,
          ),
        const SizedBox(height: 15),

        // Faculté
        if (_isLoadingFaculties)
          const Padding(
            padding: EdgeInsets.all(12),
            child: LinearProgressIndicator(),
          )
        else if (_selectedUniversity != null)
          ProfileGlassDropdown(
            label: "Faculté",
            value: _selectedFaculty?.nom,
            items: _faculties.map((f) => f.nom ?? '').toList(),
            onChanged: (val) async {
              print("🔹 Faculté sélectionnée: $val");
              if (val == null) return;
              final selected = _faculties.firstWhere((f) => f.nom == val);
              setState(() {
                _selectedFaculty = selected;
                _selectedDepartment = null;
                _departments = [];
              });
              if (selected.id != null) {
                await _loadDepartments(selected.id!);
              }
            },
            isDark: isDark,
            enabled: _faculties.isNotEmpty,
          ),
        const SizedBox(height: 15),

        // Département
        if (_isLoadingDepartments)
          const Padding(
            padding: EdgeInsets.all(12),
            child: LinearProgressIndicator(),
          )
        else if (_selectedFaculty != null)
          ProfileGlassDropdown(
            label: "Département",
            value: _selectedDepartment?.nom,
            items: _departments.map((d) => d.nom).toList(),
            onChanged: (val) {
              print("🔹 Département sélectionné: $val");
              if (val == null) return;
              setState(() {
                _selectedDepartment = _departments.firstWhere((d) => d.nom == val);
              });
            },
            isDark: isDark,
            enabled: _departments.isNotEmpty,
          ),
        const SizedBox(height: 15),

        // Promotion avec affichage des libellés complets
        ProfileGlassDropdown(
          label: "Promotion",
          value: _selectedPromotion,
          items: _promotions,
          displayValueMapper: _getPromotionDisplay,
          onChanged: (val) {
            print("🔹 Promotion sélectionnée: $val");
            setState(() => _selectedPromotion = val);
          },
          isDark: isDark,
        ),
      ],
    );
  }
}

// ============================================================================
// WIDGET: ProfileGlassDropdown (VERSION AMÉLIORÉE)
// ============================================================================
// DESCRIPTION: Dropdown personnalisé avec style glassmorphism pour le profil.
// ============================================================================

class ProfileGlassDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final bool isDark;
  final bool enabled;
  final String? Function(String?)? displayValueMapper;

  const ProfileGlassDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
    this.enabled = true,
    this.displayValueMapper,
  });

  String _getDisplayValue(String? val) {
    if (val == null) return '';
    if (displayValueMapper != null) {
      return displayValueMapper!(val) ?? val;
    }
    return val;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor: isDark ? AppColors.bgDark : Colors.white,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        prefixIcon: Icon(
          label == "Université" ? Icons.school_outlined :
          label == "Faculté" ? Icons.account_balance_outlined :
          label == "Département" ? Icons.category_outlined :
          Icons.trending_up_outlined,
          color: isDark ? Colors.white70 : Colors.black54,
          size: 20,
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            _getDisplayValue(item),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.black54),
    );
  }
}