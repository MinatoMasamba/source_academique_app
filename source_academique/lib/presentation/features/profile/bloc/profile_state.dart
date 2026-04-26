// lib/presentation/features/profile/bloc/profile_state.dart
part of 'profile_bloc.dart';

abstract class ProfileState {
  const ProfileState();
}

/// État initial avant toute action
class ProfileInitial extends ProfileState {}

/// Chargement en cours (Shimmer effect ou Spinner)
class ProfileLoading extends ProfileState {}

/// Profil chargé avec succès
class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final bool isFromCache; // Indique si on affiche les données locales ou serveur

  const ProfileLoaded({
    required this.profile,
    this.isFromCache = false,
  });
}

/// En cas d'erreur (réseau ou autre)
class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}

// ============================================================================
// ÉTAT: ProfileUpdateSuccess
// DESCRIPTION: Mise à jour du profil réussie.
// ============================================================================

class ProfileUpdateSuccess extends ProfileState {
  final UserProfile profile;

  const ProfileUpdateSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

// ============================================================================
// ÉTAT: ProfileError
// DESCRIPTION: Erreur lors du chargement ou de la mise à jour.
// ============================================================================

/// État spécifique lors de la mise à jour (pour afficher un loader sur le bouton "Enregistrer")
class ProfileUpdating extends ProfileLoaded {
  const ProfileUpdating({required super.profile, required super.isFromCache});
}