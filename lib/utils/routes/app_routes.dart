import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
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
    redirect: (BuildContext context, GoRouterState state) {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoading = authProvider.isLoading;

      final isOnSplash = state.matchedLocation == splash;
      final isOnAuth = [login, onboarding].contains(state.matchedLocation);

      // Show splash while loading
      if (isLoading && !isOnSplash) {
        return splash;
      }

      // Redirect unauthenticated users to login
      if (!isAuthenticated && !isOnAuth && !isOnSplash) {
        return login;
      }

      // Redirect authenticated users away from auth screens
      if (isAuthenticated && isOnAuth) {
        return home;
      }

      return null; // No redirect needed
    },
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
      ShellRoute(
        builder: (context, state, child) {
          return HomeScreen(child: child);
        },
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => Container(), // Will be handled by HomeScreen
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
        ],
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
    context.goNamed('home');
  }

  static void goToLogin(BuildContext context) {
    context.goNamed('login');
  }

  static void goToOnboarding(BuildContext context) {
    context.goNamed('onboarding');
  }

  static void goToProfile(BuildContext context) {
    context.goNamed('profile');
  }

  static void goToNotifications(BuildContext context) {
    context.goNamed('notifications');
  }

  static void goToEventDetails(BuildContext context, String eventId) {
    context.goNamed('eventDetails', pathParameters: {'eventId': eventId});
  }

  static void goToCreateEvent(BuildContext context) {
    context.goNamed('createEvent');
  }

  static void goToEditEvent(BuildContext context, String eventId) {
    context.goNamed('editEvent', pathParameters: {'eventId': eventId});
  }
}
