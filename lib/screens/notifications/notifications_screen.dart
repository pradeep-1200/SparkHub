import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/notification_provider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/text_styles.dart';
import '../../utils/constants/dimensions.dart';
import '../../widgets/common/gradient_background.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildNotificationsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 160,
      child: Stack(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.accentGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Notifications',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Consumer<NotificationProvider>(
                        builder: (context, provider, child) {
                          if (provider.unreadCount > 0) {
                            return TextButton(
                              onPressed: () => provider.markAllAsRead(),
                              child: Text(
                                'Mark All Read',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceSM),
                  Consumer<NotificationProvider>(
                    builder: (context, provider, child) {
                      return Text(
                        provider.unreadCount > 0
                            ? '${provider.unreadCount} unread notification${provider.unreadCount > 1 ? 's' : ''}'
                            : 'You\'re all caught up! 🎉',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        final notifications = provider.notifications;

        if (notifications.isEmpty) {
          return _buildEmptyState();
        }

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildNotificationItem(notifications[index]),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMD),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: !notification.isRead
            ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: _getNotificationColor(notification.type),
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatTime(notification.createdAt),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          if (!notification.isRead) {
            Provider.of<NotificationProvider>(context, listen: false)
                .markAsRead(notification.id);
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 60,
              color: AppColors.grey400,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          Text(
            'No Notifications',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'You\'ll receive notifications about\nevents and community updates here.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(type) {
    switch (type.toString()) {
      case 'NotificationType.event':
        return AppColors.primary;
      case 'NotificationType.badge':
        return AppColors.secondary;
      case 'NotificationType.reminder':
        return AppColors.warning;
      case 'NotificationType.achievement':
        return AppColors.success;
      default:
        return AppColors.accent;
    }
  }

  IconData _getNotificationIcon(type) {
    switch (type.toString()) {
      case 'NotificationType.event':
        return Icons.event;
      case 'NotificationType.badge':
        return Icons.emoji_events;
      case 'NotificationType.reminder':
        return Icons.schedule;
      case 'NotificationType.achievement':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
