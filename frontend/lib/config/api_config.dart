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
    print('');
    print('========================================');
    print('🌐 API ENVIRONMENT CONFIGURATION');
    print('========================================');
    print('Environment: ${environment.toUpperCase()}');
    print('Base URL: $baseUrl');
    print('Production URL: $productionUrl');
    print('Development URL: $developmentUrl');
    print('Is Production: $isProduction');
    print('Is Development: $isDevelopment');
    print('========================================');
    if (isDevelopment) {
      print('💡 Running in DEVELOPMENT mode (localhost)');
      print('   To switch: flutter run --dart-define=ENV=production');
      print('   Or use: clean_and_run_prod.bat');
    } else {
      print('☁️  Running in PRODUCTION mode (Railway cloud)');
      print('   To switch: flutter run --dart-define=ENV=development');
      print('   Or use: run_dev.bat');
    }
    print('========================================');
    print('');
  }
}