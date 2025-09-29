import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/text_styles.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/routes/app_routes.dart';
import '../../widgets/common/gradient_background.dart';
import 'participant_home.dart';
import 'admin_home.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;

  const HomeScreen({Key? key, required this.child}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _setupAnimations();
    _initializeProviders();
  }

  void _setupAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));

    _fabAnimationController.forward();
  }

  void _initializeProviders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);

      eventProvider.initializeEventsStream();
      notificationProvider.initialize();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return const SizedBox.shrink();
        }

        final isAdmin = authProvider.isAdmin;

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              isAdmin ? const AdminHome() : const ParticipantHome(),
              const ProfileScreenContent(),
              const NotificationsScreenContent(),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(isAdmin),
          floatingActionButton: isAdmin ? _buildAdminFAB() : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(bool isAdmin) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.white,
            AppColors.grey50,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          height: AppDimensions.bottomNavHeight,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.home, color: AppColors.white),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.secondaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person, color: AppColors.white),
              ),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  final unreadCount = notificationProvider.unreadCount;
                  return Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text(unreadCount > 99 ? '99+' : unreadCount.toString()),
                    child: Icon(Icons.notifications_outlined),
                  );
                },
              ),
              selectedIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.accentGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Consumer<NotificationProvider>(
                  builder: (context, notificationProvider, child) {
                    final unreadCount = notificationProvider.unreadCount;
                    return Badge(
                      isLabelVisible: unreadCount > 0,
                      label: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      child: Icon(Icons.notifications, color: AppColors.white),
                    );
                  },
                ),
              ),
              label: 'Notifications',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminFAB() {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => AppRoutes.goToCreateEvent(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(
            Icons.add,
            color: AppColors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

// Placeholder content widgets that will be implemented in next steps
class ProfileScreenContent extends StatelessWidget {
  const ProfileScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Screen - Coming Next'));
  }
}

class NotificationsScreenContent extends StatelessWidget {
  const NotificationsScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Notifications Screen - Coming Next'));
  }
}
