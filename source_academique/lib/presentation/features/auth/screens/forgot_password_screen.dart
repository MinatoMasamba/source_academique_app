import 'package:flutter/material.dart';
import 'package:source_academique/core/constants/app_colors.dart';
import 'package:source_academique/core/constants/ui_dimensions.dart';
import 'package:source_academique/core/theme/glass_morphism.dart';


class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Fond
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.bgDark, const Color(0xFF1A1A2E)],
              ),
            ),
          ),
          
          // Contenu
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(UiDimensions.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GlassMorphism(
                    blur: 20,
                    opacity: 0.12,
                    borderRadius: UiDimensions.radiusLarge,
                    child: Padding(
                      padding: const EdgeInsets.all(UiDimensions.paddingLarge),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.lock_reset_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Réinitialisation du mot de passe',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Entrez votre email institutionnel et nous vous enverrons un lien de réinitialisation',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                              prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.7)),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Un email de réinitialisation a été envoyé'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
                                ),
                              ),
                              child: const Text('ENVOYER'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}