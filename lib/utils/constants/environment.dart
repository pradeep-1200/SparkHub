enum Environment { development, staging, production }

class EnvironmentConfig {
  static const Environment _environment = Environment.production;

  static Environment get environment => _environment;
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;

  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://dev-api.sparkhub.app';
      case Environment.staging:
        return 'https://staging-api.sparkhub.app';
      case Environment.production:
        return 'https://api.sparkhub.app';
    }
  }

  static String get firebaseProjectId {
    switch (_environment) {
      case Environment.development:
        return 'sparkhub-dev';
      case Environment.staging:
        return 'sparkhub-staging';
      case Environment.production:
        return 'sparkhub-prod';
    }
  }

  static bool get enableLogging => !isProduction;
  static bool get enableAnalytics => isProduction;
  static bool get enableCrashReporting => isProduction;
}
