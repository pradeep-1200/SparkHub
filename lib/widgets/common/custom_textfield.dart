import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/text_styles.dart';
import '../../utils/constants/dimensions.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  late Animation<Color?> _borderColorAnimation;

  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _setupAnimations();
    _focusNode.addListener(_onFocusChange);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _borderAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _borderColorAnimation = ColorTween(
      begin: AppColors.grey300,
      end: AppColors.primary,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: _isFocused ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              validator: widget.validator,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              obscureText: widget.obscureText,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingMD),
                        child: Icon(
                          widget.prefixIcon,
                          color: _isFocused ? AppColors.primary : AppColors.textSecondary,
                          size: 20,
                        ),
                      )
                    : null,
                suffixIcon: widget.suffixIcon != null
                    ? IconButton(
                        icon: Icon(
                          widget.suffixIcon,
                          color: _isFocused ? AppColors.primary : AppColors.textSecondary,
                        ),
                        onPressed: widget.onSuffixIconPressed,
                      )
                    : null,
                filled: true,
                fillColor: _isFocused
                    ? AppColors.primary.withOpacity(0.05)
                    : AppColors.grey50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  borderSide: BorderSide(
                    color: _borderColorAnimation.value ?? AppColors.grey300,
                    width: _borderAnimation.value,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  borderSide: BorderSide(
                    color: AppColors.grey300,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 2.0,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 1.0,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 2.0,
                  ),
                ),
                contentPadding: const EdgeInsets.all(AppDimensions.paddingMD),
              ),
            ),
          ],
        );
      },
    );
  }
}
