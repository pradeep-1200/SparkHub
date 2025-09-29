import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/text_styles.dart';
import '../../utils/constants/dimensions.dart';

enum ButtonType { primary, secondary, outline, text, gradient }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final List<Color>? gradientColors;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.gradientColors,
    this.borderRadius,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonHeight = _getButtonHeight();
    final textStyle = _getTextStyle();
    final buttonPadding = padding ?? _getDefaultPadding();

    Widget buttonChild = _buildButtonContent(textStyle);

    // Handle gradient type
    if (type == ButtonType.gradient) {
      return Container(
        height: buttonHeight,
        width: isFullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors ?? AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppDimensions.radiusMD,
          ),
          boxShadow: onPressed != null && !isLoading
              ? [
                  BoxShadow(
                    color: (gradientColors ?? AppColors.primaryGradient)
                        .first
                        .withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed != null && !isLoading ? onPressed : null,
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppDimensions.radiusMD,
            ),
            child: Container(
              padding: buttonPadding,
              alignment: Alignment.center,
              child: buttonChild,
            ),
          ),
        ),
      );
    }

    // Handle other button types
    return SizedBox(
      height: buttonHeight,
      width: isFullWidth ? double.infinity : null,
      child: _buildStandardButton(buttonChild, textStyle, buttonPadding),
    );
  }

  Widget _buildStandardButton(
    Widget buttonChild,
    TextStyle textStyle,
    EdgeInsetsGeometry buttonPadding,
  ) {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: onPressed != null && !isLoading ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppDimensions.radiusMD,
              ),
            ),
            elevation: 2,
            shadowColor: AppColors.primary.withOpacity(0.3),
          ),
          child: buttonChild,
        );

      case ButtonType.secondary:
        return ElevatedButton(
          onPressed: onPressed != null && !isLoading ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.white,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppDimensions.radiusMD,
              ),
            ),
            elevation: 2,
            shadowColor: AppColors.secondary.withOpacity(0.3),
          ),
          child: buttonChild,
        );

      case ButtonType.outline:
        return OutlinedButton(
          onPressed: onPressed != null && !isLoading ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: buttonPadding,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppDimensions.radiusMD,
              ),
            ),
          ),
          child: buttonChild,
        );

      case ButtonType.text:
        return TextButton(
          onPressed: onPressed != null && !isLoading ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppDimensions.radiusMD,
              ),
            ),
          ),
          child: buttonChild,
        );

      default:
        return ElevatedButton(
          onPressed: onPressed != null && !isLoading ? onPressed : null,
          child: buttonChild,
        );
    }
  }

  Widget _buildButtonContent(TextStyle textStyle) {
    if (isLoading) {
      return SizedBox(
        height: _getLoadingSize(),
        width: _getLoadingSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.outline || type == ButtonType.text
                ? AppColors.primary
                : AppColors.white,
          ),
        ),
      );
    }

    List<Widget> children = [];
    
    if (icon != null) {
      children.add(Icon(
        icon,
        size: _getIconSize(),
      ));
      children.add(SizedBox(width: AppDimensions.spaceSM));
    }
    
    children.add(Text(
      text,
      style: textStyle,
      textAlign: TextAlign.center,
    ));

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  double _getButtonHeight() {
    switch (size) {
      case ButtonSize.small:
        return AppDimensions.buttonHeightSM;
      case ButtonSize.medium:
        return AppDimensions.buttonHeightMD;
      case ButtonSize.large:
        return AppDimensions.buttonHeightLG;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return AppTextStyles.buttonSmall;
      case ButtonSize.medium:
        return AppTextStyles.buttonMedium;
      case ButtonSize.large:
        return AppTextStyles.buttonLarge;
    }
  }

  EdgeInsetsGeometry _getDefaultPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMD,
          vertical: AppDimensions.paddingSM,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLG,
          vertical: AppDimensions.paddingMD,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXL,
          vertical: AppDimensions.paddingLG,
        );
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return AppDimensions.iconXS;
      case ButtonSize.medium:
        return AppDimensions.iconSM;
      case ButtonSize.large:
        return AppDimensions.iconMD;
    }
  }
}

// Floating Action Button with gradient
class GradientFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final List<Color>? gradientColors;
  final double? elevation;
  final String? heroTag;

  const GradientFloatingActionButton({
    Key? key,
    this.onPressed,
    required this.child,
    this.gradientColors,
    this.elevation,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (gradientColors ?? AppColors.primaryGradient)
                .first
                .withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        heroTag: heroTag,
        child: child,
      ),
    );
  }
}
