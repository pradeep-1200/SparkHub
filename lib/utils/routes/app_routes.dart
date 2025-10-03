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
    debugLogDiagnostics: false,
    redirect: (context, state) {
      try {
        final authProvider = context.read<AuthProvider>();
        final isAuthenticated = authProvider.isAuthenticated;
        final isInitialized = authProvider.isInitialized;
        final authStatus = authProvider.status;
        
        // Always allow splash screen initially
        if (state.matchedLocation == splash && !isInitialized) {
          return null; // Stay on splash
        }
        
        // If not initialized yet, redirect to splash
        if (!isInitialized) {
          return splash;
        }
        
        // If authenticated and on splash/auth screens, go to home
        if (isAuthenticated) {
          if (state.matchedLocation == splash || 
              state.matchedLocation == onboarding || 
              state.matchedLocation == login) {
            return home;
          }
          return null; // Allow navigation to other authenticated routes
        }
        
        // If not authenticated and not on auth screens, redirect to onboarding
        if (!isAuthenticated && 
            state.matchedLocation != splash &&
            state.matchedLocation != onboarding && 
            state.matchedLocation != login) {
          return onboarding;
        }
        
        // If on splash and initialized but not authenticated, go to onboarding
        if (state.matchedLocation == splash && isInitialized && !isAuthenticated) {
          return onboarding;
        }
        
        return null; // No redirect needed
      } catch (e) {
        debugPrint('Router redirect error: $e');
        return splash; // Safe fallback
      }
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
          final eventId = state.pathParameters['eventId'] ?? '';
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
          final eventId = state.pathParameters['eventId'] ?? '';
          return EditEventScreen(eventId: eventId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  // Navigation helper methods
  static void goToHome(BuildContext context) => context.go(home);
  static void goToLogin(BuildContext context) => context.go(login);
  static void goToOnboarding(BuildContext context) => context.go(onboarding);
  static void goToProfile(BuildContext context) => context.push(profile);
  static void goToNotifications(BuildContext context) => context.push(notifications);
  static void goToEventDetails(BuildContext context, String eventId) => context.push('/event/$eventId');
  static void goToCreateEvent(BuildContext context) => context.push(createEvent);
  static void goToEditEvent(BuildContext context, String eventId) => context.push('/edit-event/$eventId');
}
