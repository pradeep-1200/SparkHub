import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/badge_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/text_styles.dart';
import '../../utils/routes/app_routes.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late AnimationController _buttonController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonScale;

  bool _isProcessingRSVP = false;
  EventModel? _event;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadEventDetails();
  }

  void _initializeControllers() {
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  void _loadEventDetails() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      _event = eventProvider.events.firstWhere((e) => e.id == widget.eventId);
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer4<EventProvider, AuthProvider, UserProvider, BadgeProvider>(
        builder: (context, eventProvider, authProvider, userProvider, badgeProvider, child) {
          _event ??= eventProvider.events.firstWhere((e) => e.id == widget.eventId);

          if (_event == null) {
            return const LoadingWidget(message: 'Loading event details...');
          }

          return Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildSliverAppBar(context, authProvider),
                  _buildEventContent(authProvider.user!, userProvider, badgeProvider),
                ],
              ),
              _buildFloatingRSVPButton(authProvider.user!),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AuthProvider authProvider) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.white,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        if (authProvider.isAdmin)
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  AppRoutes.goToEditEvent(context, _event!.id);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit Event'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Event', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: Icon(Icons.more_vert, color: AppColors.textPrimary),
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getCategoryGradient(_event!.category),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Category badge
              Positioned(
                top: 100,
                left: AppDimensions.spaceLG,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(_event!.category),
                        size: 18,
                        color: _getCategoryColor(_event!.category),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _event!.category.name.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: _getCategoryColor(_event!.category),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Event title
              Positioned(
                bottom: 60,
                left: AppDimensions.spaceLG,
                right: AppDimensions.spaceLG,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _event!.title,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.schedule, color: AppColors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${DateFormat('EEEE, MMM dd').format(_event!.date)} • ${_event!.time}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildEventContent(user, UserProvider userProvider, BadgeProvider badgeProvider) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildEventInfo(),
          const SizedBox(height: AppDimensions.spaceLG),
          _buildDescription(),
          const SizedBox(height: AppDimensions.spaceLG),
          _buildAttendeesSection(),
          const SizedBox(height: AppDimensions.spaceLG),
          _buildLocationSection(context),
          const SizedBox(height: 100), // Space for floating button
        ]),
      ),
    );
  }

  Widget _buildEventInfo() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
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
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildInfoItem(
                Icons.people,
                'Attendees',
                '${_event!.attendees.length}/${_event!.maxAttendees}',
                AppColors.primary,
              ),
              _buildInfoItem(
                Icons.location_on,
                'Location',
                _event!.location.split(',').first,
                AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          Row(
            children: [
              _buildInfoItem(
                Icons.calendar_today,
                'Date',
                DateFormat('MMM dd').format(_event!.date),
                AppColors.accent,
              ),
              _buildInfoItem(
                Icons.access_time,
                'Time',
                _event!.time,
                AppColors.workshopColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.white, size: 20),
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.description, color: AppColors.white, size: 20),
              ),
              const SizedBox(width: AppDimensions.spaceMD),
              Text(
                'About This Event',
                style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          Text(
            _event!.description,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeesSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.secondaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.people, color: AppColors.white, size: 20),
              ),
              const SizedBox(width: AppDimensions.spaceMD),
              Text(
                'Attendees (${_event!.attendees.length})',
                style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          if (_event!.attendees.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingLG),
              child: Center(
                child: Text(
                  'No attendees yet. Be the first to join!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _event!.attendees.length > 16 ? 16 : _event!.attendees.length,
              itemBuilder: (context, index) {
                if (index == 15 && _event!.attendees.length > 16) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '+${_event!.attendees.length - 15}',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }
                return CircleAvatar(
                  backgroundColor: _getCategoryColor(_event!.category).withOpacity(0.8),
                  child: Text(
                    '${index + 1}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.accentGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.location_on, color: AppColors.white, size: 20),
              ),
              const SizedBox(width: AppDimensions.spaceMD),
              Text(
                'Location',
                style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          Text(
            _event!.location,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          CustomButton(
            text: 'Get Directions',
            type: ButtonType.outline,
            icon: Icons.directions,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Maps integration coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingRSVPButton(user) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAdmin || _event!.isPast) {
          return const SizedBox.shrink();
        }

        final isRegistered = _event!.attendees.contains(user.uid);
        final isFull = _event!.isFull && !isRegistered;

        return Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: ScaleTransition(
            scale: _buttonScale,
            child: CustomButton(
              text: isFull
                  ? 'Event Full'
                  : isRegistered
                      ? 'Cancel RSVP'
                      : 'Join Event',
              type: isFull ? ButtonType.text : ButtonType.gradient,
              size: ButtonSize.large,
              isFullWidth: true,
              isLoading: _isProcessingRSVP,
              gradientColors: isRegistered
                  ? [AppColors.error, AppColors.error.withOpacity(0.8)]
                  : AppColors.primaryGradient,
              onPressed: isFull ? null : () => _handleRSVP(user.uid, isRegistered),
              icon: isRegistered ? Icons.cancel : Icons.celebration,
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleRSVP(String userId, bool isCurrentlyRegistered) async {
    setState(() => _isProcessingRSVP = true);
    _buttonController.forward().then((_) => _buttonController.reverse());

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final badgeProvider = Provider.of<BadgeProvider>(context, listen: false);

      bool success;
      if (isCurrentlyRegistered) {
        success = await eventProvider.cancelRsvp(_event!.id, userId);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('RSVP cancelled successfully'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      } else {
        success = await eventProvider.rsvpToEvent(_event!.id, userId);
        if (success && mounted) {
          // Award points for joining event
          await userProvider.updateUserPoints(
            userId,
            AppConstants.pointsForEventAttendance,
          );

          // Check for new badges
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.user != null) {
            final newBadges = await badgeProvider.checkAndAwardBadges(
              authProvider.user!,
              userProvider,
            );

            String message = AppConstants.rsvpSuccessMessage;
            if (newBadges.isNotEmpty) {
              message += '\n🏆 ${newBadges.length} new badge${newBadges.length > 1 ? 's' : ''} earned!';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(eventProvider.errorMessage ?? 'Something went wrong'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingRSVP = false);
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${_event!.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final eventProvider = Provider.of<EventProvider>(context, listen: false);
              final success = await eventProvider.deleteEvent(_event!.id);

              if (mounted) {
                if (success) {
                  Navigator.of(context).pop(); // Go back to previous screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Event deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete event'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  List<Color> _getCategoryGradient(EventCategory category) {
    switch (category) {
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

  Color _getCategoryColor(EventCategory category) {
    switch (category) {
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

  IconData _getCategoryIcon(EventCategory category) {
    switch (category) {
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
}
