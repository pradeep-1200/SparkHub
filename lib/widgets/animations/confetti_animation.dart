import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/text_styles.dart';
import '../../utils/constants/dimensions.dart';
import '../common/custom_button.dart';

class ConfettiSuccessDialog extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;

  const ConfettiSuccessDialog({
    Key? key,
    required this.title,
    required this.message,
    this.onClose,
  }) : super(key: key);

  @override
  State<ConfettiSuccessDialog> createState() => _ConfettiSuccessDialogState();
}

class _ConfettiSuccessDialogState extends State<ConfettiSuccessDialog>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationSequence();
  }

  void _setupAnimations() {
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.bounceOut),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _scaleController.forward();
    _confettiController.play();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _bounceController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 1.57, // radians - straight down
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.3,
              shouldLoop: false,
              colors: [
                ...AppColors.primaryGradient,
                ...AppColors.secondaryGradient,
                ...AppColors.accentGradient,
              ],
            ),
          ),
          
          // Dialog Content
          ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bounceAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.all(AppDimensions.marginLG),
                    padding: const EdgeInsets.all(AppDimensions.paddingXL),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Success Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.primaryGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check,
                            color: AppColors.white,
                            size: 40,
                          ),
                        ),
                        
                        const SizedBox(height: AppDimensions.spaceLG),
                        
                        // Title
                        Text(
                          widget.title,
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: AppDimensions.spaceMD),
                        
                        // Message
                        Text(
                          widget.message,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: AppDimensions.spaceLG),
                        
                        // Close Button
                        CustomButton(
                          text: 'Awesome!',
                          type: ButtonType.gradient,
                          gradientColors: AppColors.primaryGradient,
                          onPressed: () {
                            widget.onClose?.call();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
