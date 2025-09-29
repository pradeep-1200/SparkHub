import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/badge_provider.dart';
import '../../providers/event_provider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/text_styles.dart';
import '../../utils/constants/dimensions.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/cards/badge_card.dart';
import '../../widgets/animations/pulse_animation.dart';
import 'participant_profile.dart';
import 'admin_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setupAnimations();
    _loadUserData();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  void _loadUserData() {
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
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user == null) {
          return const LoadingWidget(message: 'Loading profile...');
        }

        return Scaffold(
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildProfileHeader(authProvider.user!),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      authProvider.isAdmin 
                          ? const AdminProfile() 
                          : const ParticipantProfile(),
                      _buildStatsTab(),
                      _buildBadgesTab(),
                      _buildSettingsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      height: 280,
      child: Stack(
        children: [
          // Background gradient
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Profile content
          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLG),
                  child: Row(
                    children: [
                      Text(
                        'Profile',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.edit, color: AppColors.white),
                          onPressed: () => _showEditProfileDialog(user),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spaceMD),
                
                // Profile picture and info
                Column(
                  children: [
                    // Profile picture
                    PulseAnimation(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundImage: user.profileImageUrl != null
                              ? NetworkImage(user.profileImageUrl!)
                              : null,
                          backgroundColor: AppColors.white,
                          child: user.profileImageUrl == null
                              ? Text(
                                  user.name.isNotEmpty 
                                      ? user.name[0].toUpperCase() 
                                      : 'U',
                                  style: AppTextStyles.h2.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.spaceMD),
                    
                    // User info card
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.marginLG,
                      ),
                      padding: const EdgeInsets.all(AppDimensions.paddingLG),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user.name,
                                style: AppTextStyles.h4.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (user.isAdmin) ...[
                                const SizedBox(width: AppDimensions.spaceSM),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: AppColors.secondaryGradient,
                                    ),
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
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spaceSM),
                          Text(
                            user.email,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spaceSM),
                          Text(
                            'Member since ${DateFormat('MMM yyyy').format(user.createdAt)}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.marginLG),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodySmall,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Stats'),
          Tab(text: 'Badges'),
          Tab(text: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return Consumer2<UserProvider, EventProvider>(
      builder: (context, userProvider, eventProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Statistics',
                style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.spaceLG),
              
              // Stats grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: AppDimensions.spaceMD,
                mainAxisSpacing: AppDimensions.spaceMD,
                children: [
                  _buildStatCard(
                    'Events Joined',
                    userProvider.userStats['totalEvents']?.toString() ?? '0',
                    Icons.event,
                    AppColors.primary,
                  ),
                  _buildStatCard(
                    'Total Points',
                    userProvider.userStats['totalPoints']?.toString() ?? '0',
                    Icons.star,
                    AppColors.secondary,
                  ),
                  _buildStatCard(
                    'Badges Earned',
                    '${Provider.of<BadgeProvider>(context).userBadges.length}',
                    Icons.emoji_events,
                    AppColors.accent,
                  ),
                  _buildStatCard(
                    'Days Active',
                    '${DateTime.now().difference(Provider.of<AuthProvider>(context).user!.createdAt).inDays}',
                    Icons.calendar_today,
                    AppColors.workshopColor,
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spaceLG),
              
              // Progress section
              _buildProgressSection(userProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return AnimationConfiguration.synchronized(
      child: SlideAnimation(
        child: FadeInAnimation(
          child: Container(
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: AppDimensions.spaceMD),
                Text(
                  value,
                  style: AppTextStyles.h4.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceSM),
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(UserProvider userProvider) {
    final currentPoints = userProvider.userStats['totalPoints'] ?? 0;
    final nextBadge = Provider.of<BadgeProvider>(context).getNextBadge(currentPoints);
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.accentGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Achievement',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          
          if (nextBadge != null) ...[
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nextBadge.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${nextBadge.pointsRequired - currentPoints} points to go',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            
            // Progress bar
            LinearProgressIndicator(
              value: Provider.of<BadgeProvider>(context)
                  .getProgressTowardsBadge(nextBadge, currentPoints),
              backgroundColor: AppColors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              minHeight: 6,
            ),
          ] else ...[
            Text(
              'Congratulations! 🎉\nYou\'ve unlocked all available badges!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadgesTab() {
    return Consumer<BadgeProvider>(
      builder: (context, badgeProvider, child) {
        final userBadges = badgeProvider.userBadges;
        
        if (userBadges.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    size: 50,
                    color: AppColors.grey400,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceLG),
                Text(
                  'No Badges Yet',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceSM),
                Text(
                  'Participate in events to earn\nyour first badge!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return AnimationLimiter(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: AppDimensions.spaceMD,
              mainAxisSpacing: AppDimensions.spaceMD,
            ),
            itemCount: userBadges.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: 2,
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: BadgeCard(
                      badge: userBadges[index],
                      isEarned: true,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Settings',
            style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          
          _buildSettingsGroup([
            _buildSettingsItem(
              Icons.person,
              'Edit Profile',
              'Update your personal information',
              () => _showEditProfileDialog(Provider.of<AuthProvider>(context, listen: false).user!),
            ),
            _buildSettingsItem(
              Icons.notifications,
              'Notifications',
              'Manage your notification preferences',
              () => _showNotificationSettings(),
            ),
            _buildSettingsItem(
              Icons.privacy_tip,
              'Privacy',
              'Control your privacy settings',
              () => _showPrivacySettings(),
            ),
          ]),
          
          const SizedBox(height: AppDimensions.spaceLG),
          
          Text(
            'Support',
            style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          
          _buildSettingsGroup([
            _buildSettingsItem(
              Icons.help,
              'Help & FAQ',
              'Get answers to common questions',
              () => _showHelp(),
            ),
            _buildSettingsItem(
              Icons.feedback,
              'Send Feedback',
              'Help us improve SparkHub',
              () => _sendFeedback(),
            ),
            _buildSettingsItem(
              Icons.info,
              'About',
              'Learn more about SparkHub',
              () => _showAbout(),
            ),
          ]),
          
          const SizedBox(height: AppDimensions.spaceLG),
          
          // Sign out button
          CustomButton(
            text: 'Sign Out',
            type: ButtonType.outline,
            isFullWidth: true,
            icon: Icons.exit_to_app,
            onPressed: _signOut,
          ),
          
          const SizedBox(height: AppDimensions.spaceMD),
          
          // Delete account button
          CustomButton(
            text: 'Delete Account',
            type: ButtonType.text,
            isFullWidth: true,
            onPressed: _deleteAccount,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> items) {
    return Container(
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
      child: Column(children: items),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.textLight),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog(user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Profile editing functionality will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings coming soon!')),
    );
  }

  void _showPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy settings coming soon!')),
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help center coming soon!')),
    );
  }

  void _sendFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback form coming soon!')),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'SparkHub',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Built with ❤️ for the community',
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text('Connect. Learn. Grow Together.'),
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.deleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
