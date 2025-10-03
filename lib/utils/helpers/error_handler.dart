import 'dart:developer' as developer;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class ErrorHandler {
  static void initialize() {
    // Set up global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if (kReleaseMode) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      } else {
        developer.log(
          'Flutter Error: ${details.exception}',
          name: 'SparkHub',
          error: details.exception,
          stackTrace: details.stack,
        );
      }
    };

    // Handle platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kReleaseMode) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } else {
        developer.log(
          'Platform Error: $error',
          name: 'SparkHub',
          error: error,
          stackTrace: stack,
        );
      }
      return true;
    };
  }

  static void logError(dynamic error, [StackTrace? stackTrace]) {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    } else {
      developer.log(
        'Error: $error',
        name: 'SparkHub',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void logInfo(String message) {
    if (!kReleaseMode) {
      developer.log(message, name: 'SparkHub');
    }
  }

  static void setUserId(String userId) {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.setUserIdentifier(userId);
    }
  }

  static void setCustomKey(String key, dynamic value) {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.setCustomKey(key, value);
    }
  }
}
