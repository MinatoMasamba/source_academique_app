// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:source_academique/core/config/router.dart';
import 'package:source_academique/core/config/service_locator.dart';
import 'package:source_academique/core/storage/local_db_manager.dart';
import 'package:source_academique/core/theme/app_theme.dart';
import 'package:source_academique/features/auth/data/repositories/academic_repository.dart';
import 'package:source_academique/features/auth/presentation/bloc/auth_bloc.dart';
// Importe le bloc de profil (ajuste le chemin selon ton projet)
import 'package:source_academique/presentation/features/profile/bloc/profile_bloc.dart';

void main() async {
  // 1. Obligatoire pour les appels asynchrones avant runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialisation complète de Hive (ouverture des boîtes)
  await LocalDbManager.init();
  final box = Hive.box('student_space_box');
  await box.delete('student_posts');
  print("🗑️ Cache des posts vidé");

  // 3. Enregistrement des dépendances (GetIt) - ATTENDRE la fin
  await setupLocator();  // ← AJOUTER "await" car setupLocator est async maintenant

  // 4. Lancement de l’application
  runApp(const SourceAcademiqueApp());
}

class SourceAcademiqueApp extends StatelessWidget {
  const SourceAcademiqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupération des Blocs depuis le service locator (GetIt / sl)
    final authBloc = sl<AuthBloc>();
    final profileBloc = sl<ProfileBloc>(); // On récupère l'instance du ProfileBloc

    return MultiBlocProvider(
      providers: [
        // Injection de l'AuthBloc
        BlocProvider.value(value: authBloc),
        RepositoryProvider.value(value: sl<AcademicRepository>()),
        // Injection du ProfileBloc pour qu'il soit disponible dans ProfileScreen
        BlocProvider.value(value: profileBloc),
      ],
      child: MaterialApp.router(
        title: 'Source Académique',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        // Configuration du routeur GoRouter avec écoute du Bloc
        routerConfig: AppRouter.router(authBloc),
      ),
    );
  }
}