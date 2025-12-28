// lib/config/api_config.dart
// Environment configuration using dart-define
// No more manual code changes needed!

class ApiConfig {
  // Production backend (Railway deployment)
  static const String productionUrl = 'https://storyforge-production.up.railway.app/api/narrative';

  // Development backend (local)
  static const String developmentUrl = 'http://localhost:8080/api/narrative';

  // Read environment from dart-define (defaults to development)
  // Usage:
  //   Development: flutter run (no flag needed)
  //   Production:  flutter run --dart-define=ENV=production
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  // Automatically select URL based on environment
  static String get baseUrl {
    switch (environment) {
      case 'production':
        return productionUrl;
      case 'development':
      default:
        return developmentUrl;
    }
  }

  // Helper to check if we're in production
  static bool get isProduction => environment == 'production';

  // Helper to check if we're in development
  static bool get isDevelopment => environment == 'development';

  // Helper method to print current environment
  static void printEnvironment() {
    print('🌐 API Environment: ${environment.toUpperCase()}');
    print('🔗 Base URL: $baseUrl');
    print('');
    if (isDevelopment) {
      print('💡 Running in DEVELOPMENT mode (localhost)');
      print('   To use production: flutter run --dart-define=ENV=production');
    } else {
      print('☁️  Running in PRODUCTION mode (Railway cloud)');
      print('   To use development: flutter run --dart-define=ENV=development');
    }
  }
}