import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/text_styles.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/routes/app_routes.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  
  int _currentPage = 0;
  final int _totalPages = 3;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Discover Amazing Events',
      subtitle: 'Find workshops, meetups, and conferences\nthat match your interests',
      icon: Icons.explore,
      gradient: AppColors.primaryGradient,
    ),
    OnboardingData(
      title: 'Connect with Community',
      subtitle: 'Meet like-minded people and build\nmeaningful connections',
      icon: Icons.people,
      gradient: AppColors.secondaryGradient,
    ),
    OnboardingData(
      title: 'Grow Together',
      subtitle: 'Earn points, unlock badges, and\ncelebrate achievements',
      icon: Icons.emoji_events,
      gradient: AppColors.accentGradient,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      AppRoutes.goToLogin(context);
    }
  }

  void _skipToLogin() {
    AppRoutes.goToLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        type: GradientType.sunset,
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _skipToLogin,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
              ),

              // PageView
              Expanded(
                flex: 4,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _totalPages,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_onboardingData[index]);
                  },
                ),
              ),

              // Page indicators and buttons
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLG),
                  child: Column(
                    children: [
                      // Page indicators
                      _buildPageIndicators(),
                      
                      const SizedBox(height: AppDimensions.spaceLG),
                      
                      // Navigation buttons
                      _buildNavigationButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: data.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: data.gradient.first.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    data.icon,
                    size: 80,
                    color: AppColors.white,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: AppDimensions.spaceXL),
          
          // Title
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Text(
                    data.title,
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: AppDimensions.spaceLG),
          
          // Subtitle
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Text(
                    data.subtitle,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.white
                : AppColors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        // Previous button
        if (_currentPage > 0)
          Expanded(
            child: CustomButton(
              text: 'Previous',
              type: ButtonType.outline,
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        
        if (_currentPage > 0) const SizedBox(width: AppDimensions.spaceMD),
        
        // Next button
        Expanded(
          flex: _currentPage > 0 ? 1 : 2,
          child: CustomButton(
            text: _currentPage == _totalPages - 1 ? 'Get Started' : 'Next',
            type: ButtonType.gradient,
            gradientColors: [
              AppColors.white.withOpacity(0.9),
              AppColors.white,
            ],
            onPressed: _nextPage,
          ),
        ),
      ],
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });
}
