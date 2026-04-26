// lib/presentation/features/profile/bloc/profile_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_academique/features/auth/data/repositories/profile_repository.dart';
import 'package:source_academique/features/auth/domain/entities/profile_model.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    // Gestion du chargement du profil
    on<LoadProfile>((event, emit) async {
      // 1. D'abord le cache local
      final cachedProfile = repository.getCachedProfile();

      if (cachedProfile != null) {
        // On affiche immédiatement les données locales
        emit(ProfileLoaded(profile: cachedProfile, isFromCache: true));
      } else {
        emit(ProfileLoading());
      }

      // 2. Si on ne demande pas "cache only", on synchronise avec le serveur
      if (!event.useCacheOnly) {
        try {
          final remoteProfile = await repository.getMyProfile();
          if (remoteProfile != null) {
            // Mise à jour avec les données fraîches
            emit(ProfileLoaded(profile: remoteProfile, isFromCache: false));
          }
        } catch (e) {
          // Si aucune donnée n'a jamais été affichée, on émet une erreur
          if (state is! ProfileLoaded) {
            emit(ProfileError("Impossible de se connecter au serveur"));
          }
          // Sinon on reste silencieusement sur le cache
        }
      }
    });

    // Gestion de la mise à jour (texte / infos)
    on<UpdateProfileRequested>((event, emit) async {
      // Sauvegarde de l'état actuel
      ProfileLoaded? previousState;
      if (state is ProfileLoaded) {
        previousState = state as ProfileLoaded;
        // On passe en mode "mise à jour"
        emit(ProfileUpdating(
          profile: previousState.profile,
          isFromCache: previousState.isFromCache,
        ));
      }

      try {
        final updatedProfile = await repository.updateProfile(event.profileData); // ← utilise profileData
        if (updatedProfile != null) {
          emit(ProfileLoaded(profile: updatedProfile, isFromCache: false));
        } else {
          // Si la mise à jour échoue mais qu'on avait des données, on revient à l'état précédent
          if (previousState != null) {
            emit(ProfileLoaded(
              profile: previousState.profile,
              isFromCache: previousState.isFromCache,
            ));
          }
          emit(ProfileError("Échec de la mise à jour"));
        }
      } catch (e) {
        if (previousState != null) {
          emit(ProfileLoaded(
            profile: previousState.profile,
            isFromCache: previousState.isFromCache,
          ));
        }
        emit(ProfileError("Erreur lors de la mise à jour"));
      }
    });

    // Gestion de la photo
    on<UpdateProfilePhotoRequested>((event, emit) async {
      ProfileLoaded? previousState;
      if (state is ProfileLoaded) {
        previousState = state as ProfileLoaded;
        emit(ProfileUpdating(
          profile: previousState.profile,
          isFromCache: previousState.isFromCache,
        ));
      }

      try {
        final updatedProfile = await repository.updateProfilePhoto(event.imagePath); // ← utilise imagePath
        if (updatedProfile != null) {
          emit(ProfileLoaded(profile: updatedProfile, isFromCache: false));
        } else {
          if (previousState != null) {
            emit(ProfileLoaded(
              profile: previousState.profile,
              isFromCache: previousState.isFromCache,
            ));
          }
          emit(ProfileError("Échec de l'envoi de l'image"));
        }
      } catch (e) {
        if (previousState != null) {
          emit(ProfileLoaded(
            profile: previousState.profile,
            isFromCache: previousState.isFromCache,
          ));
        }
        emit(ProfileError("Erreur lors de l'upload"));
      }
    });
  }
}