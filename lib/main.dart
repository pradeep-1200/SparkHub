import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'providers/user_provider.dart';
import 'providers/badge_provider.dart';
import 'providers/notification_provider.dart';
import 'utils/constants/colors.dart';
import 'utils/routes/app_routes.dart';
import 'utils/helpers/error_handler.dart';
import 'utils/helpers/performance_helper.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize error handling
  ErrorHandler.initialize();

  // Initialize notifications
  await NotificationService().initialize();

  // Configure system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Performance optimizations
  PerformanceHelper.optimizeMemory();

  runApp(const SparkHubApp());
}

class SparkHubApp extends StatelessWidget {
  const SparkHubApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BadgeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp.router(
        title: 'SparkHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          splashFactory: InkRipple.splashFactory,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        routerConfig: AppRoutes.router,
        builder: (context, child) {
          // Global error boundary
          ErrorWidget.builder = (FlutterErrorDetails details) {
            return ErrorBoundary(error: details);
          };
          return child!;
        },
      ),
    );
  }
}

class ErrorBoundary extends StatelessWidget {
  final FlutterErrorDetails error;

  const ErrorBoundary({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'re working to fix this issue.\nPlease restart the app.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // In a real app, you might want to restart or navigate somewhere
                  SystemNavigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Restart App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
