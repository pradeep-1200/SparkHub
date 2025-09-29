import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/text_styles.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/app_constants.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool showLottie;
  final Color? color;
  final double size;

  const LoadingWidget({
    Key? key,
    this.message,
    this.showLottie = false,
    this.color,
    this.size = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showLottie)
            SizedBox(
              width: size,
              height: size,
              child: Lottie.asset(
                AppConstants.loadingAnimation,
                fit: BoxFit.cover,
              ),
            )
          else
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? AppColors.primary,
                ),
              ),
            ),
          
          if (message != null) ...[
            const SizedBox(height: AppDimensions.spaceLG),
            Text(
              message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class OverlayLoadingWidget extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;

  const OverlayLoadingWidget({
    Key? key,
    this.message,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.black.withOpacity(0.5),
      child: LoadingWidget(
        message: message,
        color: AppColors.white,
      ),
    );
  }
}
