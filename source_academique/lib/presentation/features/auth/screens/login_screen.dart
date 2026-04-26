import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:source_academique/core/constants/app_colors.dart';
import 'package:source_academique/core/constants/ui_dimensions.dart';
import 'package:source_academique/core/theme/glass_morphism.dart';
import 'package:source_academique/core/utils/validators.dart';
import 'package:source_academique/features/auth/presentation/bloc/auth_bloc.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
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
              margin: const EdgeInsets.all(UiDimensions.paddingMedium),
            ),
          );
        }
        
        if (state is AuthAuthenticated) {
          context.go('/');
        }
      },
      child: Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          child: Stack(
            children: [
              _buildAnimatedBackground(),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(UiDimensions.paddingLarge),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLogoAndTitle(),
                            const SizedBox(height: 48),
                            _buildLoginForm(),
                            const SizedBox(height: 24),
                            _buildAdditionalOptions(),
                            const SizedBox(height: 24),
                            _buildRegisterLink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                  color: AppColors.primary.withOpacity(0.6),
                  size: 300,
                  blur: 80,
                ),
              ),
              Positioned(
                bottom: -50 - (_animationController.value * 40),
                left: -50 + (_animationController.value * 20),
                child: _buildNeonCircle(
                  color: AppColors.secondary.withOpacity(0.4),
                  size: 280,
                  blur: 70,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.5 - 150,
                left: MediaQuery.of(context).size.width * 0.5 - 150,
                child: _buildNeonCircle(
                  color: AppColors.accent.withOpacity(0.2),
                  size: 300,
                  blur: 100,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNeonCircle({required Color color, required double size, required double blur}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: blur,
            spreadRadius: blur * 0.5,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Column(
      children: [
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientNeon,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.gradientNeon.createShader(bounds),
          child: const Text(
            'Source Académique',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hub de Connaissance Intelligent',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return GlassMorphism(
      blur: 20,
      opacity: 0.12,
      borderRadius: UiDimensions.radiusLarge,
      child: Padding(
        padding: const EdgeInsets.all(UiDimensions.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email ou Nom d\'utilisateur',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.7)),
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
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                textInputAction: TextInputAction.done,
                style: const TextStyle(color: Colors.white),
                onFieldSubmitted: (_) => _handleLogin(),
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.7)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
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
              ),
              const SizedBox(height: 16),
              // --- CORRECTION DE L'OVERFLOW ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
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
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Se souvenir de moi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(UiDimensions.radiusSmall),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  child: const Text('SE CONNECTER'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.white.withOpacity(0.2),
            thickness: 0.5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OU',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.white.withOpacity(0.2),
            thickness: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pas encore de compte ? ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterScreen(),
              ),
            );
          },
          child: ShaderMask(
            shaderCallback: (bounds) => AppColors.gradientNeon.createShader(bounds),
            child: const Text(
              'Inscrivez-vous',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
      
      if (_rememberMe) {
        // Stocker la préférence "remember me" (SharedPreferences)
        // À implémenter plus tard
      }
    }
  }
}