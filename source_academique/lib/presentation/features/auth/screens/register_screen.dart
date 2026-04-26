import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:source_academique/core/config/service_locator.dart';
import 'package:source_academique/features/auth/data/repositories/academic_repository.dart';
import 'package:source_academique/features/auth/domain/entities/etablissement.dart';
import 'package:source_academique/features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/theme/glass_morphism.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/ui_dimensions.dart';
import '../../../../core/utils/validators.dart';

// ============================================================================
// CLASSE: RegisterScreen (StatefulWidget)
// ============================================================================
// DESCRIPTION: Écran d'inscription utilisateur avec gestion des champs,
//              téléchargement de photo, chargement des universités/facultés/départements,
//              et communication avec AuthBloc pour l'inscription.
// ============================================================================

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// ============================================================================
// CLASSE: _RegisterScreenState (State<RegisterScreen>)
// ============================================================================
// DESCRIPTION: État de l'écran d'inscription contenant la logique métier,
//              les contrôleurs de formulaire, et la gestion des appels API.
// ============================================================================

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  // ==========================================================================
  // SECTION 1: DÉCLARATION DES VARIABLES D'ÉTAT
  // ==========================================================================
  
  // Formulaire
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs de texte
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _whatsappController = TextEditingController();
  
  // Données académiques dynamiques
  List<Universite> _universities = [];
  List<Faculte> _faculties = [];
  List<Departement> _departments = [];
  
  // Valeurs sélectionnées
  Universite? _selectedUniversity;
  Faculte? _selectedFaculty;
  Departement? _selectedDepartment;
  String? _selectedPromotion;
  
  // États de chargement
  bool _isLoadingUniversities = false;
  bool _isLoadingFaculties = false;
  bool _isLoadingDepartments = false;
  
  // Photo de profil
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  
  // Liste des promotions
  final List<String> _promotions = [
    "PREPA - Préparatoire",
    "L1 - Licence 1",
    "L2 - Licence 2",
    "L3 - Licence 3",
    "M1 - Master 1",
    "M2 - Master 2",
    "Doctorat",
  ];
  
  // États UI
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  
  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ==========================================================================
  // SECTION 2: CYCLE DE VIE - initState()
  // ==========================================================================
  // MÉTHODE: initState()
  // DESCRIPTION: Initialise les animations et charge les universités au démarrage.
  // SUIVI: ✅ Appelée automatiquement lors de la création du widget.
  // ==========================================================================
  
  @override
  void initState() {
    print("🔷 [RegisterScreen.initState] Début de l'initialisation");
    super.initState();
    
    // Étape 1: Initialisation de l'animation
    print("🔹 [RegisterScreen.initState] Étape 1: Configuration des animations");
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    print("✅ [RegisterScreen.initState] Animations configurées avec succès");
    
    // Étape 2: Chargement des universités
    print("🔹 [RegisterScreen.initState] Étape 2: Démarrage du chargement des universités");
    _loadUniversities();
    
    print("✅ [RegisterScreen.initState] Initialisation terminée");
  }

  // ==========================================================================
  // SECTION 3: CYCLE DE VIE - dispose()
  // ==========================================================================
  // MÉTHODE: dispose()
  // DESCRIPTION: Nettoie les ressources (contrôleurs, animations).
  // SUIVI: ✅ Appelée automatiquement lors de la destruction du widget.
  // ==========================================================================
  
  @override
  void dispose() {
    print("🔷 [RegisterScreen.dispose] Nettoyage des ressources");
    
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _studentIdController.dispose();
    _whatsappController.dispose();
    _animationController.dispose();
    
    print("✅ [RegisterScreen.dispose] Ressources nettoyées avec succès");
    super.dispose();
  }

  // ==========================================================================
  // SECTION 4: CHARGEMENT DES UNIVERSITÉS
  // ==========================================================================
  // MÉTHODE: _loadUniversities()
  // DESCRIPTION: Appelle l'API pour récupérer la liste des universités.
  // SUIVI: ✅ Appelée dans initState().
  // ERREURS: Affiche un message d'erreur en cas d'échec.
  // ==========================================================================
  
  Future<void> _loadUniversities() async {
    print("🔷 [_RegisterScreenState._loadUniversities] Début du chargement des universités");
    
    setState(() {
      _isLoadingUniversities = true;
      print("🔹 [_RegisterScreenState._loadUniversities] _isLoadingUniversities = true");
    });
    
    final academicRepo = sl<AcademicRepository>();
    print("🔹 [_RegisterScreenState._loadUniversities] AcademicRepository récupéré via service_locator");
    
    try {
      print("🔹 [_RegisterScreenState._loadUniversities] Appel à academicRepo.getUniversities()");
      final univs = await academicRepo.getUniversities();
      print("📊 [_RegisterScreenState._loadUniversities] ${univs.length} universités reçues");
      
      setState(() {
        _universities = univs;
        _isLoadingUniversities = false;
        print("✅ [_RegisterScreenState._loadUniversities] Universités chargées avec succès");
      });
    } catch (e) {
      print("❌ [_RegisterScreenState._loadUniversities] ERREUR: ${e.toString()}");
      setState(() {
        _isLoadingUniversities = false;
        print("🔹 [_RegisterScreenState._loadUniversities] _isLoadingUniversities = false (après erreur)");
      });
      _showError("Impossible de charger les universités. Vérifiez votre connexion.");
    }
    
    print("🔷 [_RegisterScreenState._loadUniversities] Fin de l'exécution");
  }

  // ==========================================================================
  // SECTION 5: CHARGEMENT DES FACULTÉS
  // ==========================================================================
  // MÉTHODE: _loadFaculties(int universityId)
  // DESCRIPTION: Charge les facultés d'une université spécifique.
  // SUIVI: ✅ Appelée après sélection d'une université.
  // ERREURS: Affiche un message d'erreur en cas d'échec.
  // ==========================================================================
  
  Future<void> _loadFaculties(int universityId) async {
    print("🔷 [_RegisterScreenState._loadFaculties] Début - universityId: $universityId");
    
    setState(() {
      _isLoadingFaculties = true;
      print("🔹 [_RegisterScreenState._loadFaculties] _isLoadingFaculties = true");
    });
    
    final academicRepo = sl<AcademicRepository>();
    print("🔹 [_RegisterScreenState._loadFaculties] AcademicRepository récupéré");
    
    try {
      print("🔹 [_RegisterScreenState._loadFaculties] Appel à academicRepo.getFaculties($universityId)");
      final facs = await academicRepo.getFaculties(universityId);
      print("📊 [_RegisterScreenState._loadFaculties] ${facs.length} facultés reçues");
      
      setState(() {
        _faculties = facs;
        _isLoadingFaculties = false;
        print("✅ [_RegisterScreenState._loadFaculties] Facultés chargées avec succès");
      });
    } catch (e) {
      print("❌ [_RegisterScreenState._loadFaculties] ERREUR: ${e.toString()}");
      setState(() {
        _isLoadingFaculties = false;
      });
      _showError("Erreur chargement des facultés. Veuillez réessayer.");
    }
    
    print("🔷 [_RegisterScreenState._loadFaculties] Fin de l'exécution");
  }

  // ==========================================================================
  // SECTION 6: CHARGEMENT DES DÉPARTEMENTS
  // ==========================================================================
  // MÉTHODE: _loadDepartments(int facultyId)
  // DESCRIPTION: Charge les départements d'une faculté spécifique.
  // SUIVI: ✅ Appelée après sélection d'une faculté.
  // ERREURS: Affiche un message d'erreur en cas d'échec.
  // ==========================================================================
  
  Future<void> _loadDepartments(int facultyId) async {
    print("🔷 [_RegisterScreenState._loadDepartments] Début - facultyId: $facultyId");
    
    setState(() {
      _isLoadingDepartments = true;
      print("🔹 [_RegisterScreenState._loadDepartments] _isLoadingDepartments = true");
    });
    
    final academicRepo = sl<AcademicRepository>();
    print("🔹 [_RegisterScreenState._loadDepartments] AcademicRepository récupéré");
    
    try {
      print("🔹 [_RegisterScreenState._loadDepartments] Appel à academicRepo.getDepartments($facultyId)");
      final deps = await academicRepo.getDepartments(facultyId);
      print("📊 [_RegisterScreenState._loadDepartments] ${deps.length} départements reçus");
      
      setState(() {
        _departments = deps;
        _isLoadingDepartments = false;
        print("✅ [_RegisterScreenState._loadDepartments] Départements chargés avec succès");
      });
    } catch (e) {
      print("❌ [_RegisterScreenState._loadDepartments] ERREUR: ${e.toString()}");
      setState(() {
        _isLoadingDepartments = false;
      });
      _showError("Erreur chargement des départements. Veuillez réessayer.");
    }
    
    print("🔷 [_RegisterScreenState._loadDepartments] Fin de l'exécution");
  }

  // ==========================================================================
  // SECTION 7: AFFICHAGE DES ERREURS
  // ==========================================================================
  // MÉTHODE: _showError(String message)
  // DESCRIPTION: Affiche un SnackBar d'erreur à l'utilisateur.
  // SUIVI: ✅ Appelée en cas d'exception dans les méthodes de chargement.
  // ==========================================================================
  
  void _showError(String message) {
    print("🔴 [_RegisterScreenState._showError] Affichage erreur: $message");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ==========================================================================
  // SECTION 8: BUILD - CONSTRUCTION DE L'INTERFACE
  // ==========================================================================
  // MÉTHODE: build(BuildContext context)
  // DESCRIPTION: Construit l'interface utilisateur complète.
  // SUIVI: ✅ Appelée à chaque reconstruction de l'état.
  // ==========================================================================
  
  @override
  Widget build(BuildContext context) {
    print("🔷 [RegisterScreen.build] Construction de l'interface");
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print("🔹 [RegisterScreen.build] BlocListener - État reçu: ${state.runtimeType}");
        
        if (!mounted) {
          print("⚠️ [RegisterScreen.build] Widget non monté, ignore l'état");
          return;
        }
        
        // Gestion des erreurs d'authentification
        if (state is AuthError) {
          print("❌ [RegisterScreen.build] AuthError détecté: ${state.message}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.accent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        
        // Gestion de l'authentification réussie
        if (state is AuthAuthenticated) {
          print("✅ [RegisterScreen.build] AuthAuthenticated - Redirection vers l'accueil");
          
          // Méthode 1: Avec GoRouter (recommandée)
          if (context.mounted) {
            context.go('/');  // GoRouter redirige vers la route racine
          }
          
          // Méthode 2: Alternative si vous voulez vider la pile
          // if (context.mounted) {
          //   context.pushReplacement('/');
          // }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(UiDimensions.paddingLarge),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bouton retour
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () {
                              print("🔹 [RegisterScreen.build] Bouton retour pressé");
                              if (mounted) Navigator.pop(context);
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Titres
                          Text(
                            "Créer un compte",
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Rejoignez votre communauté académique",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Formulaire GlassMorphism
                          GlassMorphism(
                            blur: 20,
                            opacity: 0.12,
                            borderRadius: UiDimensions.radiusLarge,
                            child: Padding(
                              padding: const EdgeInsets.all(UiDimensions.paddingMedium),
                              child: Column(
                                children: [
                                  _buildProfilePhotoPicker(),
                                  const SizedBox(height: 20),
                                  
                                  // Nom et prénom
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          controller: _firstNameController,
                                          label: "Prénom",
                                          icon: Icons.person_outline,
                                          validator: (value) => Validators.validateRequired(value, "Le prénom"),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildTextField(
                                          controller: _lastNameController,
                                          label: "Nom",
                                          icon: Icons.person_outline,
                                          validator: (value) => Validators.validateRequired(value, "Le nom"),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  
                                  // Email
                                  _buildTextField(
                                    controller: _emailController,
                                    label: "Email institutionnel",
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: Validators.validateEmail,
                                  ),
                                  const SizedBox(height: 15),
                                  
                                  // Matricule
                                 // _buildTextField(
                                //  controller: _studentIdController,
                                  //label: "Matricule étudiant si possible",
                                  //  icon: Icons.badge_outlined,
                                  //  hint: "Ex: UNIKIN2024-001",
                                  //),
                                  //const SizedBox(height: 15),
                                  
                                  // WhatsApp
                                  _buildTextField(
                                    controller: _whatsappController,
                                    label: "Numéro WhatsApp",
                                    icon: Icons.phone_android_outlined,
                                    hint: "Ex: 0991234567 ou +243991234567",
                                    keyboardType: TextInputType.phone,
                                    validator: Validators.validatePhone,
                                  ),
                                  const SizedBox(height: 15),
                                  
                                  const Divider(height: 30, color: Colors.white10),
                                  
                                  // Université (dropdown dynamique)
                                  if (_isLoadingUniversities)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: LinearProgressIndicator(),
                                    )
                                  else
                                    _buildGlassDropdown(
                                      label: "Université",
                                      value: _selectedUniversity?.nom,
                                      items: _universities.map((u) => u.nom).toList(),
                                      onChanged: (val) async {
                                        print("🔹 [RegisterScreen] Université sélectionnée: $val");
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
                                    ),
                                  const SizedBox(height: 15),
                                  
                                  // Faculté
                                  if (_selectedUniversity != null) ...[
                                    if (_isLoadingFaculties)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8),
                                        child: LinearProgressIndicator(),
                                      )
                                    else
                                      _buildGlassDropdown(
                                        label: "Faculté",
                                        value: _selectedFaculty?.nom,
                                        items: _faculties.map((f) => f.nom ?? '').toList(),
                                        onChanged: (val) async {
                                          print("🔹 [RegisterScreen] Faculté sélectionnée: $val");
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
                                      ),
                                    const SizedBox(height: 15),
                                  ],
                                  
                                  // Département
                                  if (_selectedFaculty != null) ...[
                                    if (_isLoadingDepartments)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8),
                                        child: LinearProgressIndicator(),
                                      )
                                    else
                                      _buildGlassDropdown(
                                        label: "Département",
                                        value: _selectedDepartment?.nom,
                                        items: _departments.map((d) => d.nom).toList(),
                                        onChanged: (val) {
                                          print("🔹 [RegisterScreen] Département sélectionné: $val");
                                          if (val == null) return;
                                          setState(() {
                                            _selectedDepartment = _departments.firstWhere((d) => d.nom == val);
                                          });
                                        },
                                      ),
                                    const SizedBox(height: 15),
                                  ],
                                  
                                  // Promotion
                                  _buildGlassDropdown(
                                    label: "Promotion",
                                    value: _selectedPromotion,
                                    items: _promotions,
                                    onChanged: (val) {
                                      print("🔹 [RegisterScreen] Promotion sélectionnée: $val");
                                      if (mounted) {
                                        setState(() => _selectedPromotion = val);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  
                                  // Mot de passe
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: "Mot de passe",
                                    icon: Icons.lock_outline,
                                    obscure: !_isPasswordVisible,
                                    validator: Validators.validatePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () {
                                        if (mounted) {
                                          setState(() => _isPasswordVisible = !_isPasswordVisible);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  
                                  // Confirmation mot de passe
                                  _buildTextField(
                                    controller: _confirmPasswordController,
                                    label: "Confirmer le mot de passe",
                                    icon: Icons.lock_outline,
                                    obscure: !_isConfirmPasswordVisible,
                                    validator: (value) => Validators.validatePasswordConfirmation(
                                      value,
                                      _passwordController.text,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () {
                                        if (mounted) {
                                          setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Conditions
                                  _buildTermsAndConditions(),
                                  const SizedBox(height: 20),
                                  
                                  // Bouton inscription
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _handleRegister,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        "S'INSCRIRE",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Lien connexion
                                  _buildLoginLink(),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Indicateur de chargement
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthLoading) {
                  print("🔹 [RegisterScreen.build] Affichage de l'indicateur de chargement");
                  return Container(
                    color: Colors.black.withOpacity(0.7),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // SECTION 9: BACKGROUND ANIMÉ
  // ==========================================================================
  // MÉTHODE: _buildAnimatedBackground()
  // DESCRIPTION: Construit le fond d'écran avec animation et cercles néon.
  // ==========================================================================
  
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.bgDark,
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -100 + (_animationController.value * 50),
                right: -50 + (_animationController.value * 30),
                child: _buildNeonCircle(
                  color: AppColors.secondary.withOpacity(0.4),
                  size: 280,
                ),
              ),
              Positioned(
                bottom: -50 - (_animationController.value * 40),
                left: -50 + (_animationController.value * 20),
                child: _buildNeonCircle(
                  color: AppColors.primary.withOpacity(0.3),
                  size: 250,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // SECTION 10: CERCLE NÉON
  // ==========================================================================
  // MÉTHODE: _buildNeonCircle()
  // DESCRIPTION: Crée un cercle avec effet de lueur pour le fond animé.
  // ==========================================================================
  
  Widget _buildNeonCircle({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SECTION 11: SÉLECTEUR DE PHOTO DE PROFIL
  // ==========================================================================
  // MÉTHODE: _buildProfilePhotoPicker()
  // DESCRIPTION: Affiche le cercle de sélection de photo avec options caméra/galerie.
  // ==========================================================================
  
  Widget _buildProfilePhotoPicker() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              print("🔹 [RegisterScreen] Clic sur le sélecteur de photo");
              _showImagePickerOptions();
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradientNeon,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: _profileImage != null
                    ? Image.file(
                        _profileImage!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _profileImage != null ? "Changer la photo" : "Ajouter une photo",
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SECTION 12: OPTIONS DE SÉLECTION D'IMAGE
  // ==========================================================================
  // MÉTHODE: _showImagePickerOptions()
  // DESCRIPTION: Affiche une bottom sheet avec les options galerie et caméra.
  // ==========================================================================
  
  Future<void> _showImagePickerOptions() async {
    print("🔷 [_RegisterScreenState._showImagePickerOptions] Affichage des options");
    
    if (!mounted) {
      print("⚠️ [_RegisterScreenState._showImagePickerOptions] Widget non monté");
      return;
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionTile(
              icon: Icons.photo_library,
              label: "Choisir depuis la galerie",
              onTap: () {
                print("🔹 [_RegisterScreenState] Option galerie sélectionnée");
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const Divider(color: Colors.white24),
            _buildOptionTile(
              icon: Icons.camera_alt,
              label: "Prendre une photo",
              onTap: () {
                print("🔹 [_RegisterScreenState] Option caméra sélectionnée");
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // SECTION 13: TILE D'OPTION
  // ==========================================================================
  // MÉTHODE: _buildOptionTile()
  // DESCRIPTION: Construit une option individuelle dans la bottom sheet.
  // ==========================================================================
  
  Widget _buildOptionTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  // ==========================================================================
  // SECTION 14: SÉLECTION DE L'IMAGE
  // ==========================================================================
  // MÉTHODE: _pickImage(ImageSource source)
  // DESCRIPTION: Ouvre la galerie ou la caméra et récupère l'image sélectionnée.
  // SUIVI: ✅ Appelée via _showImagePickerOptions().
  // ERREURS: Capture et log les exceptions, pas d'affichage à l'utilisateur.
  // ==========================================================================
  
  Future<void> _pickImage(ImageSource source) async {
    print("🔷 [_RegisterScreenState._pickImage] Début - source: $source");
    
    try {
      print("🔹 [_RegisterScreenState._pickImage] Appel à _picker.pickImage()");
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (pickedFile != null && mounted) {
        print("📸 [_RegisterScreenState._pickImage] Image sélectionnée: ${pickedFile.path}");
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        print("✅ [_RegisterScreenState._pickImage] Image mise à jour dans l'état");
      } else {
        print("⚠️ [_RegisterScreenState._pickImage] Aucune image sélectionnée");
      }
      
      if (mounted) {
        Navigator.pop(context);
        print("🔹 [_RegisterScreenState._pickImage] Bottom sheet fermée");
      }
    } catch (e) {
      print("❌ [_RegisterScreenState._pickImage] ERREUR: ${e.toString()}");
      debugPrint("Erreur lors de la sélection de l'image: $e");
    }
    
    print("🔷 [_RegisterScreenState._pickImage] Fin de l'exécution");
  }

  // ==========================================================================
  // SECTION 15: CHAMP DE TEXTE
  // ==========================================================================
  // MÉTHODE: _buildTextField()
  // DESCRIPTION: Construit un champ de texte stylisé avec validation.
  // ==========================================================================
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    bool obscure = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
      ),
    );
  }

  // ==========================================================================
  // SECTION 16: DROPDOWN GLASSMORPHISM
  // ==========================================================================
  // MÉTHODE: _buildGlassDropdown()
  // DESCRIPTION: Construit un menu déroulant avec style glassmorphism.
  // ==========================================================================
  
  Widget _buildGlassDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor: AppColors.bgDark,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(
          label == "Université" ? Icons.school_outlined :
          label == "Faculté" ? Icons.account_balance_outlined :
          label == "Département" ? Icons.category_outlined :
          Icons.calendar_today_outlined,
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
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
            item,
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.7)),
    );
  }

  // ==========================================================================
  // SECTION 17: CONDITIONS D'UTILISATION
  // ==========================================================================
  // MÉTHODE: _buildTermsAndConditions()
  // DESCRIPTION: Affiche la case à cocher pour accepter les conditions.
  // ==========================================================================
  
  Widget _buildTermsAndConditions() {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              print("🔹 [RegisterScreen] Conditions acceptées: $value");
              if (mounted) {
                setState(() => _acceptTerms = value ?? false);
              }
            },
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.secondary;
              }
              return Colors.white.withOpacity(0.2);
            }),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: "J'accepte les ",
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
              children: [
                TextSpan(
                  text: "conditions d'utilisation",
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: " et la "),
                TextSpan(
                  text: "politique de confidentialité",
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // SECTION 18: LIEN DE CONNEXION
  // ==========================================================================
  // MÉTHODE: _buildLoginLink()
  // DESCRIPTION: Affiche le lien pour rediriger vers l'écran de connexion.
  // ==========================================================================
  
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Déjà un compte ? ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        GestureDetector(
          onTap: () {
            print("🔹 [RegisterScreen] Clic sur 'Se connecter'");
            if (mounted) Navigator.pop(context);
          },
          child: Text(
            'Se connecter',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // SECTION 19: GESTION DE L'INSCRIPTION
  // ==========================================================================
  // MÉTHODE: _handleRegister()
  // DESCRIPTION: Valide le formulaire, prépare les données et déclenche l'événement
  //              RegisterRequested vers AuthBloc.
  // SUIVI: ✅ Appelée lors du clic sur le bouton "S'INSCRIRE".
  // VALIDATIONS: - Formulaire valide
  //              - Conditions acceptées
  //              - Widget monté
  // ==========================================================================
  
  void _handleRegister() {
    print("🔷 [_RegisterScreenState._handleRegister] Début de l'inscription");
    
    // Étape 1: Validation du formulaire
    print("🔹 [_RegisterScreenState._handleRegister] Étape 1: Validation du formulaire");
    final isFormValid = _formKey.currentState!.validate();
    print("   - Formulaire valide: $isFormValid");
    
    // Étape 2: Vérification des conditions
    print("🔹 [_RegisterScreenState._handleRegister] Étape 2: Vérification des conditions");
    print("   - Conditions acceptées: $_acceptTerms");
    
    // Étape 3: Vérification du montage
    print("🔹 [_RegisterScreenState._handleRegister] Étape 3: Vérification du widget monté");
    print("   - Widget monté: $mounted");
    
    if (isFormValid && _acceptTerms && mounted) {
      print("✅ [_RegisterScreenState._handleRegister] Toutes les validations sont passées");
      
      // Étape 4: Construction des données utilisateur
      print("🔹 [_RegisterScreenState._handleRegister] Étape 4: Construction des données utilisateur");
      final userData = {
        "first_name": _firstNameController.text.trim(),
        "last_name": _lastNameController.text.trim(),
        "email": _emailController.text.trim(),
        "student_id": _studentIdController.text.trim(),
        "whatsapp": _whatsappController.text.trim(),
        "university_id": _selectedUniversity?.id,
        "faculty_id": _selectedFaculty?.id,
        "department_id": _selectedDepartment?.id,
        "promotion": _selectedPromotion,
        "password": _passwordController.text,
      };
      
      print("📊 [_RegisterScreenState._handleRegister] Données préparées:");
      print("   - Prénom: ${userData["first_name"]}");
      print("   - Nom: ${userData["last_name"]}");
      print("   - Email: ${userData["email"]}");
      print("   - Université ID: ${userData["university_id"]}");
      print("   - Faculté ID: ${userData["faculty_id"]}");
      print("   - Département ID: ${userData["department_id"]}");
      print("   - Promotion: ${userData["promotion"]}");
      print("   - Photo présente: ${_profileImage != null}");
      
      // Étape 5: Envoi de l'événement au Bloc
      print("🔹 [_RegisterScreenState._handleRegister] Étape 5: Envoi de RegisterRequested au AuthBloc");
      context.read<AuthBloc>().add(
        RegisterRequested(
          userData: userData,
          profilePhoto: _profileImage,
        ),
      );
      print("✅ [_RegisterScreenState._handleRegister] Événement envoyé avec succès");
      
    } else {
      // Gestion des erreurs de validation
      print("❌ [_RegisterScreenState._handleRegister] Échec des validations");
      
      if (!isFormValid) {
        print("   - Cause: Formulaire invalide");
        _showError("Veuillez corriger les erreurs dans le formulaire");
      } else if (!_acceptTerms) {
        print("   - Cause: Conditions non acceptées");
        _showError("Veuillez accepter les conditions d'utilisation");
      } else if (!mounted) {
        print("   - Cause: Widget non monté");
      }
    }
    
    print("🔷 [_RegisterScreenState._handleRegister] Fin de l'exécution");
  }
}