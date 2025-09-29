import 'package:flutter/material.dart';
import '../../models/badge_model.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/text_styles.dart';
import '../../utils/constants/dimensions.dart';
import '../animations/pulse_animation.dart';

class BadgeCard extends StatelessWidget {
  final BadgeModel badge;
  final bool isEarned;
  final VoidCallback? onTap;

  const BadgeCard({
    Key? key,
    required this.badge,
    this.isEarned = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: isEarned
              ? Border.all(
                  color: _getBadgeColor().withOpacity(0.3),
                  width: 2,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge icon
              _buildBadgeIcon(),
              
              const SizedBox(height: AppDimensions.spaceMD),
              
              // Badge name
              Text(
                badge.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isEarned ? AppColors.textPrimary : AppColors.textLight,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: AppDimensions.spaceSM),
              
              // Badge description or points
              if (isEarned)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getBadgeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'EARNED',
                    style: AppTextStyles.caption.copyWith(
                      color: _getBadgeColor(),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                )
              else
                Text(
                  '${badge.pointsRequired} points',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeIcon() {
    final color = isEarned ? _getBadgeColor() : AppColors.grey400;
    
    Widget iconWidget = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: isEarned
            ? LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isEarned ? null : AppColors.grey100,
        shape: BoxShape.circle,
        boxShadow: isEarned
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(
        _getBadgeIcon(),
        color: isEarned ? AppColors.white : AppColors.grey400,
        size: 28,
      ),
    );

    return isEarned
        ? PulseAnimation(
            duration: const Duration(seconds: 3),
            child: iconWidget,
          )
        : iconWidget;
  }

  Color _getBadgeColor() {
    switch (badge.type) {
      case BadgeType.participation:
        return AppColors.primary;
      case BadgeType.achievement:
        return AppColors.secondary;
      case BadgeType.milestone:
        return AppColors.accent;
      case BadgeType.special:
        return AppColors.workshopColor;
    }
  }

  IconData _getBadgeIcon() {
    switch (badge.type) {
      case BadgeType.participation:
        return Icons.people;
      case BadgeType.achievement:
        return Icons.emoji_events;
      case BadgeType.milestone:
        return Icons.flag;
      case BadgeType.special:
        return Icons.star;
    }
  }
}
