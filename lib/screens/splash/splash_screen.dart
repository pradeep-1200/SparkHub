import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;

  bool _hasNavigated = false;

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
    _logoController.forward();
    
    // Start text animation with slight delay
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _textController.forward();
    }
    
    // Wait for animations to mostly complete
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Start checking auth status
    if (mounted) {
      _checkAuthAndNavigate();
    }
  }

  void _checkAuthAndNavigate() async {
    if (_hasNavigated) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      debugPrint('🔍 Splash: Checking auth status...');
      debugPrint('🔍 Splash: isInitialized = ${authProvider.isInitialized}');
      debugPrint('🔍 Splash: isAuthenticated = ${authProvider.isAuthenticated}');
      
      // If already initialized, navigate immediately
      if (authProvider.isInitialized) {
        _performNavigation(authProvider);
        return;
      }

      // Wait for initialization with a reasonable timeout
      int attempts = 0;
      const maxAttempts = 30; // 3 seconds total (100ms * 30)
      
      while (!authProvider.isInitialized && attempts < maxAttempts && mounted) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
        
        if (authProvider.isInitialized) {
          debugPrint('✅ Splash: Auth initialized after ${attempts * 100}ms');
          break;
        }
      }

      if (!mounted) return;

      if (!authProvider.isInitialized) {
        debugPrint('⚠️ Splash: Timeout waiting for auth initialization');
        // Force initialization if it's taking too long
        authProvider.forceInitialization();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _performNavigation(authProvider);
      
    } catch (e) {
      debugPrint('❌ Splash: Error during auth check: $e');
      if (mounted) {
        // On error, navigate to onboarding as safe fallback
        _navigateTo(AppRoutes.onboarding);
      }
    }
  }

  void _performNavigation(AuthProvider authProvider) {
    if (_hasNavigated || !mounted) return;

    debugPrint('🚀 Splash: Performing navigation...');
    debugPrint('🚀 Splash: isAuthenticated = ${authProvider.isAuthenticated}');
    
    setState(() {
      _hasNavigated = true;
    });

    // Small delay for smooth visual transition
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      if (authProvider.isAuthenticated) {
        debugPrint('✅ Splash: Navigating to Home');
        _navigateTo(AppRoutes.home);
      } else {
        debugPrint('✅ Splash: Navigating to Onboarding');
        _navigateTo(AppRoutes.onboarding);
      }
    });
  }

  void _navigateTo(String route) {
    if (!mounted) return;
    
    try {
      if (route == AppRoutes.home) {
        AppRoutes.goToHome(context);
      } else {
        AppRoutes.goToOnboarding(context);
      }
    } catch (e) {
      debugPrint('❌ Splash: Navigation error: $e');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
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
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Transform.rotate(
            angle: _logoRotation.value * 0.1,
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
                  child: const Icon(
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
                
                // Loading indicator
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