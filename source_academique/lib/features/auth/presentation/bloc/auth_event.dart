part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final Map<String, dynamic> userData;
  final File? profilePhoto;  // ← AJOUTER
  const RegisterRequested({required this.userData, this.profilePhoto});
  @override
  List<Object?> get props => [userData, profilePhoto];
}

class LogoutRequested extends AuthEvent {}

class AppStarted extends AuthEvent {}