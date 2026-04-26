// lib/presentation/features/profile/bloc/profile_event.dart
part of 'profile_bloc.dart';

abstract class ProfileEvent {
  const ProfileEvent();
}

/// Déclenché au chargement de l'écran ou pour rafraîchir
class LoadProfile extends ProfileEvent {
  final bool useCacheOnly;
  const LoadProfile({this.useCacheOnly = false});
}

/// Déclenché lors de la validation du formulaire d'édition
class UpdateProfileRequested extends ProfileEvent {
  final Map<String, dynamic> profileData;  // <-- champ correct
  const UpdateProfileRequested(this.profileData);
}

/// Déclenché spécifiquement pour l'upload d'image
class UpdateProfilePhotoRequested extends ProfileEvent {
  final String imagePath;  // <-- champ correct
  const UpdateProfilePhotoRequested(this.imagePath);
}