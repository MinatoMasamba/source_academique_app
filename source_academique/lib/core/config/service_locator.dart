// lib/core/config/service_locator.dart

import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:source_academique/core/network/dio_client.dart';
import 'package:source_academique/core/storage/local_db_manager.dart';
import 'package:source_academique/core/storage/secure_storage.dart';
import 'package:source_academique/features/auth/data/repositories/academic_repository.dart';
import 'package:source_academique/features/auth/data/repositories/auth_repository.dart';
import 'package:source_academique/features/auth/data/repositories/home_repository.dart';
import 'package:source_academique/features/auth/data/repositories/library_repository.dart';
import 'package:source_academique/features/auth/data/repositories/profile_repository.dart';
import 'package:source_academique/features/auth/data/repositories/student_space_repository.dart';
import 'package:source_academique/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:source_academique/presentation/features/home/presentation/bloc/home_bloc.dart';
import 'package:source_academique/presentation/features/library/presentations/bloc/library_bloc.dart';
import 'package:source_academique/presentation/features/profile/bloc/profile_bloc.dart';
import 'package:source_academique/presentation/features/space_stadent/presentation/bloc/student_space_bloc.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // ============================================================
  // STOCKAGE LOCAL
  // ============================================================
  
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => LocalDbManager());
  sl.registerLazySingleton(() => SecureStorage(sl<FlutterSecureStorage>()));

  // ============================================================
  // NETWORK
  // ============================================================
  
  sl.registerLazySingleton(() => DioClient(
        Dio(),
        sl<FlutterSecureStorage>(),
      ));
  sl.registerLazySingleton(() => sl<DioClient>().dio);

  // ============================================================
  // REPOSITORIES
  // ============================================================
  
  sl.registerLazySingleton(() => AcademicRepository(sl<DioClient>()));
  sl.registerLazySingleton(() => AuthRepository(
  sl<DioClient>(),
  sl<FlutterSecureStorage>(),
  sl<SharedPreferences>(),  // ← AJOUTER SharedPreferences
));
  sl.registerLazySingleton(() => HomeRepository(sl<DioClient>()));
  sl.registerLazySingleton(() => LibraryRepository(sl<DioClient>()));
  
  // Une seule déclaration de ProfileRepository (pas de duplication)
  sl.registerLazySingleton(() => ProfileRepository(
        sl<DioClient>(),
        sl<SharedPreferences>(),
      ));
  
  // ⭐ AJOUT : StudentSpaceRepository
  sl.registerLazySingleton(() => StudentSpaceRepository(sl<DioClient>()));

  // ============================================================
  // BLOCS
  // ============================================================
  
  sl.registerFactory(() => AuthBloc(sl<AuthRepository>()));
  sl.registerFactory(() => HomeBloc(
        homeRepository: sl<HomeRepository>(),
        localDb: sl<LocalDbManager>(),
      ));
  sl.registerFactory(() => LibraryBloc(sl<LibraryRepository>()));
  sl.registerFactory(() => ProfileBloc(repository: sl<ProfileRepository>()));
  
  // ⭐ AJOUT : StudentSpaceBloc
  // Note: StudentSpaceBloc a besoin de StudentSpaceRepository, LocalDbManager, et userId
  // userId sera passé lors de la création, donc on ne l'enregistre pas ici
  sl.registerFactory<StudentSpaceBloc>(
    () => StudentSpaceBloc(
      repository: sl<StudentSpaceRepository>(),
      localDb: sl<LocalDbManager>(),
      userId: 0, // Valeur temporaire, sera remplacée dans l'écran
    ),
  );
}