import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/text_styles.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/routes/app_routes.dart';
import '../../widgets/common/gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _fadeController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _fadeOpacity;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    // Fade out animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _startSplashSequence() async {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Start logo animation
    await _logoController.forward();
    
    // Start text animation with slight delay
    await Future.delayed(const Duration(milliseconds: 300));
    await _textController.forward();
    
    // Wait and check authentication status
    await Future.delayed(const Duration(milliseconds: 1500));
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if user is authenticated
    if (authProvider.isAuthenticated) {
      await _fadeController.forward();
      if (mounted) AppRoutes.goToHome(context);
    } else {
      await _fadeController.forward();
      if (mounted) AppRoutes.goToOnboarding(context);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeOpacity,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeOpacity.value,
            child: GradientBackground(
              type: GradientType.primary,
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: _buildLogo(),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildTextContent(),
                    ),
                    const SizedBox(height: AppDimensions.spaceXL),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Transform.rotate(
            angle: _logoRotation.value * 0.1, // Subtle rotation
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.white.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Icon(
                    Icons.celebration,
                    size: 60,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextContent() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return SlideTransition(
          position: _textSlide,
          child: FadeTransition(
            opacity: _textOpacity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SparkHub',
                  style: AppTextStyles.logoText.copyWith(
                    color: AppColors.white,
                    fontSize: 36,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceSM),
                Text(
                  'Connect. Learn. Grow Together.',
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spaceLG),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
