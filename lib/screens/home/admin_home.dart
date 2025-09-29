import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/event_model.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/text_styles.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/routes/app_routes.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/cards/event_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/custom_button.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerOpacity;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _setupAnimations();
    _loadData();
  }

  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeIn,
    ));

    _headerAnimationController.forward();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.loadLeaderboard();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer3<AuthProvider, EventProvider, UserProvider>(
        builder: (context, authProvider, eventProvider, userProvider, child) {
          if (authProvider.user == null) {
            return const LoadingWidget(message: 'Loading admin dashboard...');
          }

          return RefreshIndicator(
            onRefresh: () async {
              await eventProvider.loadUpcomingEvents();
              await userProvider.loadLeaderboard();
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildSliverAppBar(authProvider.user!),
                _buildAdminStats(eventProvider, userProvider),
                _buildQuickActions(),
                _buildSectionHeader('Manage Events', Icons.admin_panel_settings),
                _buildEventsList(eventProvider, authProvider.user!.uid),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(user) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: GradientBackground(
          type: GradientType.secondary,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: FadeTransition(
                opacity: _headerOpacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimensions.spaceLG),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: user.profileImageUrl != null
                              ? NetworkImage(user.profileImageUrl!)
                              : null,
                          backgroundColor: AppColors.white.withOpacity(0.2),
                          child: user.profileImageUrl == null
                              ? Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                                  style: AppTextStyles.h4.copyWith(
                                    color: AppColors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: AppDimensions.spaceMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'ADMIN',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.name,
                                style: AppTextStyles.h4.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'Manage events, engage community, and create amazing experiences! ✨',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminStats(EventProvider eventProvider, UserProvider userProvider) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppDimensions.marginMD),
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
              'Community Overview',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            Row(
              children: [
                _buildStatItem(
                  'Total Events',
                  eventProvider.events.length.toString(),
                  Icons.event,
                  AppColors.primary,
                ),
                _buildStatItem(
                  'Active Users',
                  userProvider.leaderboard.length.toString(),
                  Icons.people,
                  AppColors.secondary,
                ),
                _buildStatItem(
                  'Upcoming',
                  eventProvider.upcomingEvents.length.toString(),
                  Icons.upcoming,
                  AppColors.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
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
              child: Icon(
                icon,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              value,
              style: AppTextStyles.h5.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
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

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Row(
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
                text: 'View Analytics',
                type: ButtonType.outline,
                icon: Icons.analytics,
                onPressed: () {
                  // TODO: Navigate to analytics screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Analytics coming soon!')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.paddingLG,
          AppDimensions.paddingLG,
          AppDimensions.paddingLG,
          AppDimensions.paddingMD,
        ),
        child: Row(
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
              child: Icon(
                icon,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            Text(
              title,
              style: AppTextStyles.h5.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(EventProvider eventProvider, String userId) {
    if (eventProvider.isLoading) {
      return const SliverToBoxAdapter(
        child: LoadingWidget(message: 'Loading events...'),
      );
    }

    final events = eventProvider.events;

    if (events.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: EventCard(
                    event: events[index],
                    onTap: () => AppRoutes.goToEventDetails(
                      context,
                      events[index].id,
                    ),
                    showAdminActions: true,
                    userId: userId,
                    onEdit: () => AppRoutes.goToEditEvent(
                      context,
                      events[index].id,
                    ),
                    onDelete: () => _showDeleteConfirmation(events[index]),
                  ),
                ),
              ),
            );
          },
          childCount: events.length,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final eventProvider = Provider.of<EventProvider>(context, listen: false);
              final success = await eventProvider.deleteEvent(event.id);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Event deleted successfully' : 'Failed to delete event'),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.secondaryGradient.map((c) => c.withOpacity(0.1)).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_note,
              size: 60,
              color: AppColors.secondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          Text(
            'No Events Created',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'Start building your community by\ncreating your first event!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          CustomButton(
            text: 'Create First Event',
            type: ButtonType.gradient,
            gradientColors: AppColors.secondaryGradient,
            icon: Icons.add,
            onPressed: () => AppRoutes.goToCreateEvent(context),
          ),
        ],
      ),
    );
  }
}
