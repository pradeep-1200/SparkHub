import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/text_styles.dart';
import '../../utils/routes/app_routes.dart';
import '../../widgets/cards/event_card.dart';

class ParticipantProfile extends StatelessWidget {
  const ParticipantProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, EventProvider, UserProvider>(
      builder: (context, authProvider, eventProvider, userProvider, child) {
        final user = authProvider.user!;
        final userEvents = eventProvider.getUserJoinedEvents(user.uid);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickStats(context, userProvider),
              const SizedBox(height: AppDimensions.spaceLG),
              _buildRecentActivity(context, userEvents),
              const SizedBox(height: AppDimensions.spaceLG),
              _buildUpcomingEvents(context, userEvents),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context, UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Journey',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          Row(
            children: [
              _buildQuickStatItem(
                'Events',
                userProvider.userStats['totalEvents']?.toString() ?? '0',
                Icons.event,
              ),
              _buildQuickStatItem(
                'Points',
                userProvider.userStats['totalPoints']?.toString() ?? '0',
                Icons.star,
              ),
              _buildQuickStatItem(
                'Rank',
                '#${userProvider.getUserRank(Provider.of<AuthProvider>(context, listen: false).user!.uid)}',
                Icons.leaderboard,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.white, size: 24),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            value,
            style: AppTextStyles.h5.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, List<dynamic> userEvents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, color: AppColors.primary, size: 24),
            const SizedBox(width: AppDimensions.spaceSM),
            Text(
              'Recent Activity',
              style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        
        if (userEvents.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 48,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  Text(
                    'No events yet',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Join your first event to get started!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: userEvents.take(5).length,
              itemBuilder: (context, index) {
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: AppDimensions.marginMD),
                  child: EventCard(
                    event: userEvents[index],
                    onTap: () => AppRoutes.goToEventDetails(
                      context,
                      userEvents[index].id,
                    ),
                    showRSVPStatus: true,
                    userId: Provider.of<AuthProvider>(context, listen: false).user!.uid,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildUpcomingEvents(BuildContext context, List<dynamic> userEvents) {
    final upcomingEvents = userEvents.where((event) => event.isUpcoming).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.upcoming, color: AppColors.secondary, size: 24),
            const SizedBox(width: AppDimensions.spaceSM),
            Text(
              'Upcoming Events',
              style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (upcomingEvents.isNotEmpty)
              Text(
                '${upcomingEvents.length} event${upcomingEvents.length > 1 ? 's' : ''}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        
        if (upcomingEvents.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_available,
                    size: 48,
                    color: AppColors.secondary.withOpacity(0.6),
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  Text(
                    'No upcoming events',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Check the home screen for new events to join!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          AnimationLimiter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcomingEvents.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
                        child: EventCard(
                          event: upcomingEvents[index],
                          onTap: () => AppRoutes.goToEventDetails(
                            context,
                            upcomingEvents[index].id,
                          ),
                          showRSVPStatus: true,
                          userId: Provider.of<AuthProvider>(context, listen: false).user!.uid,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
