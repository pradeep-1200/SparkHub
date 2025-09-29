import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/badge_provider.dart';
import '../../models/event_model.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/text_styles.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/routes/app_routes.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/cards/event_card.dart';
import '../../widgets/common/loading_widget.dart';

class ParticipantHome extends StatefulWidget {
  const ParticipantHome({Key? key}) : super(key: key);

  @override
  State<ParticipantHome> createState() => _ParticipantHomeState();
}

class _ParticipantHomeState extends State<ParticipantHome>
    with TickerProviderStateMixin {
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final badgeProvider = Provider.of<BadgeProvider>(context, listen: false);

      if (authProvider.user != null) {
        userProvider.loadUserStats(authProvider.user!.uid);
        badgeProvider.loadUserBadges(authProvider.user!);
      }
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
      body: Consumer4<AuthProvider, EventProvider, UserProvider, BadgeProvider>(
        builder: (context, authProvider, eventProvider, userProvider, badgeProvider, child) {
          if (authProvider.user == null) {
            return const LoadingWidget(message: 'Loading your profile...');
          }

          return RefreshIndicator(
            onRefresh: () async {
              await eventProvider.loadUpcomingEvents();
              await userProvider.loadUserStats(authProvider.user!.uid);
              await badgeProvider.loadUserBadges(authProvider.user!);
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildSliverAppBar(authProvider.user!),
                _buildUserStats(userProvider, badgeProvider),
                _buildSectionHeader('Upcoming Events', Icons.event),
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
          type: GradientType.primary,
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
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
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
                              Text(
                                'Welcome back,',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.white.withOpacity(0.8),
                                ),
                              ),
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
                      'Discover amazing events and grow together with our community! 🚀',
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

  Widget _buildUserStats(UserProvider userProvider, BadgeProvider badgeProvider) {
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
              'Your Progress',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            Row(
              children: [
                _buildStatItem(
                  'Events Joined',
                  userProvider.userStats['totalEvents']?.toString() ?? '0',
                  Icons.event,
                  AppColors.primary,
                ),
                _buildStatItem(
                  'Points Earned',
                  userProvider.userStats['totalPoints']?.toString() ?? '0',
                  Icons.star,
                  AppColors.secondary,
                ),
                _buildStatItem(
                  'Badges',
                  badgeProvider.userBadges.length.toString(),
                  Icons.emoji_events,
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
                  colors: AppColors.primaryGradient,
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

    final upcomingEvents = eventProvider.upcomingEvents;

    if (upcomingEvents.isEmpty) {
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
                    event: upcomingEvents[index],
                    onTap: () => AppRoutes.goToEventDetails(
                      context,
                      upcomingEvents[index].id,
                    ),
                    showRSVPStatus: true,
                    userId: userId,
                  ),
                ),
              ),
            );
          },
          childCount: upcomingEvents.length,
        ),
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
                colors: AppColors.primaryGradient.map((c) => c.withOpacity(0.1)).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy,
              size: 60,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          Text(
            'No Events Yet',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'Check back later for exciting events\nfrom our community!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
