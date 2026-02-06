// lib/config/api_config.dart
// Environment configuration using dart-define
// No more manual code changes needed!

class ApiConfig {
  // Production URLs
  static const String productionAuthBaseUrl = 'https://storyforge-production.up.railway.app';
  static const String productionNarrativeUrl = 'https://storyforge-production.up.railway.app/api/narrative';

  // Development URLs
  static const String developmentAuthBaseUrl = 'http://localhost:8080';
  static const String developmentNarrativeUrl = 'http://localhost:8080/api/narrative';

  // Read environment from dart-define (defaults to development)
  // Usage:
  //   Development: flutter run (no flag needed)
  //   Production:  flutter run --dart-define=ENV=production
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  // Auth Base URL (for /api/auth/* endpoints - NO suffix)
  static String get authBaseUrl {
    switch (environment) {
      case 'production':
        return productionAuthBaseUrl;
      case 'development':
      default:
        return developmentAuthBaseUrl;
    }
  }

  // Base URL (for narrative and saves - BACKWARD COMPATIBLE with existing code)
  static String get baseUrl {
    switch (environment) {
      case 'production':
        return productionNarrativeUrl;
      case 'development':
      default:
        return developmentNarrativeUrl;
    }
  }

  // Alias for clarity (same as baseUrl)
  static String get narrativeUrl => baseUrl;

  // Helper to check if we're in production
  static bool get isProduction => environment == 'production';

  // Helper to check if we're in development
  static bool get isDevelopment => environment == 'development';

  // Helper method to print current environment
  static void printEnvironment() {
    print('');
    print('========================================');
    print('🌍 API ENVIRONMENT CONFIGURATION');
    print('========================================');
    print('Environment: ${environment.toUpperCase()}');
    print('Auth Base URL: $authBaseUrl');
    print('Base URL (Narrative): $baseUrl');
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