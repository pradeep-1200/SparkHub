import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/text_styles.dart';
import '../../utils/constants/dimensions.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/animations/pulse_animation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signInWithGoogle();

      if (!mounted) return;

      if (authProvider.errorMessage != null) {
        _showErrorSnackBar(authProvider.errorMessage!);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Sign in failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        type: GradientType.primary,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              children: [
                // Top section with logo and text
                Expanded(
                  flex: 3,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildTopSection(),
                  ),
                ),

                // Bottom section with login options
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildBottomSection(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated logo
        PulseAnimation(
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

        const SizedBox(height: AppDimensions.spaceLG),

        // App name
        Text(
          'SparkHub',
          style: AppTextStyles.logoText.copyWith(
            color: AppColors.white,
            fontSize: 36,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: AppDimensions.spaceSM),

        // Tagline
        Text(
          'Connect. Learn. Grow Together.',
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.white.withOpacity(0.9),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppDimensions.spaceLG),

        // Welcome text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLG),
          child: Text(
            'Join our vibrant community of learners and discover amazing events happening around you.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withOpacity(0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sign in header
          Text(
            'Welcome Back',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppDimensions.spaceSM),

          Text(
            'Sign in to continue your journey',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppDimensions.spaceLG),

          // Google Sign In Button
          CustomButton(
            text: _isLoading ? 'Signing in...' : 'Continue with Google',
            type: ButtonType.gradient,
            size: ButtonSize.large,
            icon: _isLoading ? null : Icons.g_mobiledata,
            isFullWidth: true,
            isLoading: _isLoading,
            gradientColors: AppColors.primaryGradient,
            onPressed: _handleGoogleSignIn,
          ),

          const SizedBox(height: AppDimensions.spaceLG),

          // Terms and privacy
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSM),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textLight,
                ),
                children: [
                  const TextSpan(text: 'By continuing, you agree to our '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
