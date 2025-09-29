class AppConstants {
  // App info
  static const String appName = 'SparkHub';
  static const String appTagline = 'Connect. Learn. Grow Together.';
  static const String appVersion = '1.0.0';

  // Default values
  static const int defaultEventMaxAttendees = 50;
  static const int defaultLeaderboardLimit = 10;
  static const int defaultEventsPerPage = 20;
  
  // Points system
  static const int pointsForEventAttendance = 10;
  static const int pointsForEventCreation = 25;
  static const int pointsForFirstEvent = 15;
  static const int pointsForEventCompletion = 20;
  
  // Badge requirements
  static const int newbieBadgeRequirement = 0;
  static const int activeLearnerBadgeRequirement = 50;
  static const int communityStarBadgeRequirement = 100;
  static const int eventMasterBadgeRequirement = 200;
  static const int socialButterfly = 300;
  
  // Event categories
  static const List<String> eventCategories = [
    'Workshop',
    'Meetup',
    'Hackathon',
    'Conference',
    'Seminar',
  ];

  // Time formats
  static const String timeFormat = 'HH:mm';
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'hh:mm a';

  // Notification topics
  static const String allUsersTopicName = 'all_users';
  static const String participantsTopicName = 'participants';
  static const String adminsTopicName = 'admins';

  // Storage paths
  static const String eventImagesPath = 'event_images';
  static const String userAvatarsPath = 'user_avatars';
  static const String badgeIconsPath = 'badge_icons';

  // API endpoints (if using external APIs)
  static const String baseUrl = 'https://api.sparkhub.app';
  
  // Animation assets
  static const String confettiAnimation = 'assets/animations/confetti.json';
  static const String badgeUnlockAnimation = 'assets/animations/badge_unlock.json';
  static const String loadingAnimation = 'assets/animations/loading.json';

  // Error messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection.';
  static const String authErrorMessage = 'Authentication failed. Please try again.';
  static const String permissionErrorMessage = 'Permission denied. Please check app settings.';

  // Success messages
  static const String eventCreatedMessage = 'Event created successfully! 🎉';
  static const String eventUpdatedMessage = 'Event updated successfully! ✨';
  static const String rsvpSuccessMessage = 'Successfully registered for the event! 🎯';
  static const String badgeEarnedMessage = 'Congratulations! You earned a new badge! 🏆';

  // Validation
  static const int minEventTitleLength = 3;
  static const int maxEventTitleLength = 100;
  static const int minEventDescriptionLength = 10;
  static const int maxEventDescriptionLength = 500;
  static const int maxEventImageSizeMB = 5;

  // Regex patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';

  // Deep link schemes
  static const String deepLinkScheme = 'sparkhub';
  static const String eventDeepLinkPrefix = 'sparkhub://event/';
  static const String userDeepLinkPrefix = 'sparkhub://user/';

  // Social sharing
  static const String shareEventText = 'Check out this amazing event on SparkHub: ';
  static const String shareAppText = 'Join me on SparkHub - the best community event platform! Download now: ';

  // Feature flags
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enablePerformanceMonitoring = true;
}
