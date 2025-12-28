// lib/config/api_config.dart
// Environment configuration for backend API URLs

class ApiConfig {
  // Production back-end (Railway deployment)
  static const String productionUrl = 'https://storyforge-production.up.railway.app/api/narrative';

  // Development back-end (Local)
  static const String developmentUrl = 'http://localhost:8080/api/narrative';

  // Current environment - Toggle this to switch between local and cloud
  static const bool isProduction = false;  // ← Set to true for partner demo, false for local dev

  // Get the appropriate URL based on environment
  static String get baseUrl => isProduction ? productionUrl : developmentUrl;

  // Helper method to print current environment
  static void printEnvironment() {
    print('🌐 API Environment: ${isProduction ? "PRODUCTION" : "DEVELOPMENT"}');
    print('🔗 Base URL: $baseUrl');
  }
}