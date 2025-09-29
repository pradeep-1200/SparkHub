import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/text_styles.dart';
import '../../utils/constants/dimensions.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final bool showRSVPStatus;
  final bool showAdminActions;
  final String? userId;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventCard({
    Key? key,
    required this.event,
    required this.onTap,
    this.showRSVPStatus = false,
    this.showAdminActions = false,
    this.userId,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMD),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventImage(),
                _buildEventContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventImage() {
    return Container(
      height: AppDimensions.eventImageHeight,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusLG),
          topRight: Radius.circular(AppDimensions.radiusLG),
        ),
        gradient: LinearGradient(
          colors: _getCategoryGradient(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Category badge
          Positioned(
            top: AppDimensions.spaceMD,
            left: AppDimensions.spaceMD,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(),
                    size: 16,
                    color: _getCategoryColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getCategoryName(),
                    style: AppTextStyles.caption.copyWith(
                      color: _getCategoryColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Admin actions
          if (showAdminActions)
            Positioned(
              top: AppDimensions.spaceMD,
              right: AppDimensions.spaceMD,
              child: Row(
                children: [
                  _buildActionButton(
                    Icons.edit,
                    () => onEdit?.call(),
                    AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    Icons.delete,
                    () => onDelete?.call(),
                    AppColors.error,
                  ),
                ],
              ),
            ),

          // Event status indicator
          if (showRSVPStatus && userId != null)
            Positioned(
              top: AppDimensions.spaceMD,
              right: AppDimensions.spaceMD,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: event.attendees.contains(userId!)
                      ? AppColors.success
                      : AppColors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  event.attendees.contains(userId!)
                      ? Icons.check
                      : Icons.bookmark_border,
                  size: 16,
                  color: event.attendees.contains(userId!)
                      ? AppColors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),

          // Event illustration/pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusLG),
                  topRight: Radius.circular(AppDimensions.radiusLG),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Event title overlay
          Positioned(
            bottom: AppDimensions.spaceLG,
            left: AppDimensions.spaceLG,
            right: AppDimensions.spaceLG,
            child: Text(
              event.title,
              style: AppTextStyles.h5.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventContent() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and time
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${DateFormat('MMM dd').format(event.date)} • ${event.time}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spaceSM),
          
          // Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event.location,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spaceMD),
          
          // Description
          Text(
            event.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: AppDimensions.spaceMD),
          
          // Attendees info
          Row(
            children: [
              _buildAttendeesInfo(),
              const Spacer(),
              if (event.isUpcoming) _buildAvailabilityChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback? onPressed, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
          color: color,
        ),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }

  Widget _buildAttendeesInfo() {
    return Row(
      children: [
        Stack(
          children: [
            ...List.generate(
              (event.attendees.length > 3 ? 3 : event.attendees.length),
              (index) => Container(
                margin: EdgeInsets.only(left: index * 12.0),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Text(
          '${event.attendees.length} attending',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityChip() {
    final spotsLeft = event.maxAttendees - event.attendees.length;
    final isFull = spotsLeft <= 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFull ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isFull ? 'Full' : '$spotsLeft spots left',
        style: AppTextStyles.caption.copyWith(
          color: isFull ? AppColors.error : AppColors.success,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Color> _getCategoryGradient() {
    switch (event.category) {
      case EventCategory.workshop:
        return [AppColors.workshopColor, AppColors.workshopColor.withOpacity(0.8)];
      case EventCategory.meetup:
        return [AppColors.meetupColor, AppColors.meetupColor.withOpacity(0.8)];
      case EventCategory.hackathon:
        return [AppColors.hackathonColor, AppColors.hackathonColor.withOpacity(0.8)];
      case EventCategory.conference:
        return [AppColors.conferenceColor, AppColors.conferenceColor.withOpacity(0.8)];
      case EventCategory.seminar:
        return [AppColors.seminarColor, AppColors.seminarColor.withOpacity(0.8)];
    }
  }

  Color _getCategoryColor() {
    switch (event.category) {
      case EventCategory.workshop:
        return AppColors.workshopColor;
      case EventCategory.meetup:
        return AppColors.meetupColor;
      case EventCategory.hackathon:
        return AppColors.hackathonColor;
      case EventCategory.conference:
        return AppColors.conferenceColor;
      case EventCategory.seminar:
        return AppColors.seminarColor;
    }
  }

  IconData _getCategoryIcon() {
    switch (event.category) {
      case EventCategory.workshop:
        return Icons.build;
      case EventCategory.meetup:
        return Icons.people;
      case EventCategory.hackathon:
        return Icons.code;
      case EventCategory.conference:
        return Icons.mic;
      case EventCategory.seminar:
        return Icons.school;
    }
  }

  String _getCategoryName() {
    return event.category.name.toUpperCase();
  }
}
