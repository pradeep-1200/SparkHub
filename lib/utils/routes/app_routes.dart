import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/onboarding_screen.dart';
import '../../screens/events/create_event_screen.dart';
import '../../screens/events/edit_event_screen.dart';
import '../../screens/events/event_details_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/splash/splash_screen.dart';

class AppRoutes {
  // Route names for type-safe navigation
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String eventDetails = '/event/:eventId';
  static const String createEvent = '/create-event';
  static const String editEvent = '/edit-event/:eventId';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: eventDetails,
        name: 'eventDetails',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return EventDetailsScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: createEvent,
        name: 'createEvent',
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        path: editEvent,
        name: 'editEvent',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return EditEventScreen(eventId: eventId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.error}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    ),
  );

  // Navigation helper methods
  static void goToHome(BuildContext context) {
    context.go(home);
  }

  static void goToLogin(BuildContext context) {
    context.go(login);
  }

  static void goToOnboarding(BuildContext context) {
    context.go(onboarding);
  }

  static void goToProfile(BuildContext context) {
    context.push(profile);
  }

  static void goToNotifications(BuildContext context) {
    context.push(notifications);
  }

  static void goToEventDetails(BuildContext context, String eventId) {
    context.push('/event/$eventId');
  }

  static void goToCreateEvent(BuildContext context) {
    context.push(createEvent);
  }

  static void goToEditEvent(BuildContext context, String eventId) {
    context.push('/edit-event/$eventId');
  }
}