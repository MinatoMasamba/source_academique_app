import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../presentation/bloc/auth_bloc.dart';
import '../../../core/theme/glass_morphism.dart';
import '../../../core/constants/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgDark, Color(0xFF1E1A3E)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassMorphism(
                blur: 15,
                opacity: 0.15,
                borderRadius: 32,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Bienvenue',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Connectez-vous à votre compte',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 32),
                      _buildEmailField(),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 24),
                      _buildLoginButton(context),
                      const SizedBox(height: 16),
                      _buildRegisterLink(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Mot de passe',
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: get email/password from controllers
          // final email = ...;
          // final password = ...;
          // context.read<AuthBloc>().add(LoginRequested(email, password));
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.primary,
        ),
        child: const Text('Se connecter'),
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Pas encore de compte ? ',
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/register'),
          child: const Text(
            'Inscrivez-vous',
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}