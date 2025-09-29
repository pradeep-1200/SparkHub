import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/text_styles.dart';
import '../../utils/routes/app_routes.dart';
import '../../widgets/common/custom_button.dart';

class AdminProfile extends StatelessWidget {
  const AdminProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, EventProvider, UserProvider>(
      builder: (context, authProvider, eventProvider, userProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdminStats(eventProvider, userProvider),
              const SizedBox(height: AppDimensions.spaceLG),
              _buildQuickActions(context),
              const SizedBox(height: AppDimensions.spaceLG),
              _buildEventChart(eventProvider),
              const SizedBox(height: AppDimensions.spaceLG),
              _buildTopUsers(userProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdminStats(EventProvider eventProvider, UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.secondaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Dashboard',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          Row(
            children: [
              _buildAdminStatItem(
                'Total Events',
                eventProvider.events.length.toString(),
                Icons.event,
              ),
              _buildAdminStatItem(
                'Active Users',
                userProvider.leaderboard.length.toString(),
                Icons.people,
              ),
              _buildAdminStatItem(
                'This Month',
                eventProvider.events
                    .where((e) => e.createdAt.month == DateTime.now().month)
                    .length
                    .toString(),
                Icons.calendar_month,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminStatItem(String label, String value, IconData icon) {
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Create Event',
                type: ButtonType.gradient,
                gradientColors: AppColors.primaryGradient,
                icon: Icons.add_circle_outline,
                onPressed: () => AppRoutes.goToCreateEvent(context),
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            Expanded(
              child: CustomButton(
                text: 'Analytics',
                type: ButtonType.outline,
                icon: Icons.analytics,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Analytics coming soon!')),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventChart(EventProvider eventProvider) {
    final events = eventProvider.events;
    final categoryData = <String, int>{};

    for (final event in events) {
      final category = event.category.name;
      categoryData[category] = (categoryData[category] ?? 0) + 1;
    }

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
          Text(
            'Events by Category',
            style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          
          if (categoryData.isEmpty)
            Center(
              child: Text(
                'No events created yet',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: categoryData.entries.map((entry) {
                    final index = categoryData.keys.toList().indexOf(entry.key);
                    final colors = [
                      AppColors.primary,
                      AppColors.secondary,
                      AppColors.accent,
                      AppColors.workshopColor,
                      AppColors.meetupColor,
                    ];
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.value}',
                      color: colors[index % colors.length],
                      radius: 60,
                      titleStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          
          const SizedBox(height: AppDimensions.spaceMD),
          
          // Legend
          Wrap(
            spacing: AppDimensions.spaceMD,
            runSpacing: AppDimensions.spaceSM,
            children: categoryData.entries.map((entry) {
              final index = categoryData.keys.toList().indexOf(entry.key);
              final colors = [
                AppColors.primary,
                AppColors.secondary,
                AppColors.accent,
                AppColors.workshopColor,
                AppColors.meetupColor,
              ];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    entry.key.toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUsers(UserProvider userProvider) {
    final topUsers = userProvider.leaderboard.take(5).toList();

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
          Text(
            'Top Contributors',
            style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          
          if (topUsers.isEmpty)
            Center(
              child: Text(
                'No active users yet',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topUsers.length,
              separatorBuilder: (context, index) => Divider(
                color: AppColors.grey200,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final user = topUsers[index];
                final rank = index + 1;
                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: user.profileImageUrl != null
                            ? NetworkImage(user.profileImageUrl!)
                            : null,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: user.profileImageUrl == null
                            ? Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: rank <= 3 
                                ? [AppColors.warning, AppColors.textSecondary, AppColors.accent][rank - 1]
                                : AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 2),
                          ),
                          child: Text(
                            '$rank',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    user.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${user.joinedEvents.length} events joined',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.accentGradient,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${user.points} pts',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
