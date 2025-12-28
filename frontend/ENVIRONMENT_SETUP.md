# StoryForge Frontend - Environment Setup

## Overview

StoryForge uses compile-time environment configuration via Flutter's `--dart-define` feature. This allows switching between development (localhost) and production (Railway) backends without changing code.

## Important: How dart-define Works

**dart-define values are COMPILE-TIME constants**, which means:
- You MUST rebuild the app when switching environments
- Hot reload will NOT pick up environment changes
- Use `flutter clean` when in doubt

## Quick Start Scripts

### Development Mode (Localhost Backend)

Run against your local backend at `http://localhost:8080`:

```bash
# Windows
run_dev.bat

# Linux/Mac
flutter run --dart-define=ENV=development
```

### Production Mode (Railway Backend)

Run against Railway cloud backend at `https://storyforge-production.up.railway.app`:

```bash
# Windows (recommended - includes clean build)
clean_and_run_prod.bat

# Windows (fast run, assumes clean build)
run_prod.bat

# Linux/Mac
flutter clean && flutter pub get && flutter run --dart-define=ENV=production
```

### Building Production APK

Build a release APK for distribution:

```bash
# Windows
build_prod_apk.bat

# Linux/Mac
flutter clean
flutter pub get
flutter build apk --dart-define=ENV=production --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting Connection Issues

### Step 1: Use the Debug Screen

1. Run the app
2. Click the bug icon (🐛) in the app bar
3. Check the environment configuration:
   - ENV should show "production" or "development"
   - Base URL should match your intended backend
4. Click "Test Connection" to verify backend reachability

### Step 2: Common Issues and Solutions

#### Issue: App shows development URL when I want production

**Cause**: App was built without the production flag

**Solution**:
```bash
flutter clean
flutter run --dart-define=ENV=production
```

#### Issue: "Cannot connect to server" error

**Possible causes**:
1. Backend is not running (for localhost)
2. Wrong environment configured
3. Network connectivity issues
4. CORS issues (check backend logs)

**Solution**:
1. Verify backend is accessible in browser:
   - Dev: http://localhost:8080/api/narrative/status
   - Prod: https://storyforge-production.up.railway.app/api/narrative/status
2. Check debug screen shows correct URL
3. Do a clean build: `flutter clean && flutter run --dart-define=ENV=production`

#### Issue: Environment doesn't change after running with different flag

**Cause**: Build cache still has old compiled value

**Solution**:
```bash
flutter clean
flutter pub get
flutter run --dart-define=ENV=production
```

#### Issue: Works on web but not on mobile

**Cause**: Different build artifacts or network restrictions

**Solution**:
1. Clean build for mobile: `flutter clean`
2. Verify Android has INTERNET permission (already added)
3. Check if mobile device can reach the backend URL
4. Use debug screen to verify environment

### Step 3: Verify Backend Status

**Development (Localhost)**:
1. Start your Spring Boot backend
2. Open browser: http://localhost:8080/api/narrative/status
3. Should see: `{"status":"operational","message":"Narrative API is running"}`

**Production (Railway)**:
1. Open browser: https://storyforge-production.up.railway.app/api/narrative/status
2. Should see: `{"status":"operational","message":"Narrative API is running"}`

## Environment Configuration Details

### File: `lib/config/api_config.dart`

```dart
class ApiConfig {
  // URLs
  static const String productionUrl = 'https://storyforge-production.up.railway.app/api/narrative';
  static const String developmentUrl = 'http://localhost:8080/api/narrative';

  // Read from dart-define
  static const String environment = String.fromEnvironment('ENV', defaultValue: 'development');

  // Auto-select URL
  static String get baseUrl => environment == 'production' ? productionUrl : developmentUrl;
}
```

### How Services Use It

All services automatically use the correct URL:

```dart
class NarrativeService {
  final String baseUrl;

  NarrativeService({String? baseUrl})
    : baseUrl = baseUrl ?? ApiConfig.baseUrl;  // Auto-selects based on environment
}
```

## Best Practices

### 1. Always Clean When Switching Environments

```bash
flutter clean
flutter pub get
flutter run --dart-define=ENV=production
```

### 2. Check Console Output on Startup

Look for this in your console when the app starts:

```
========================================
🌐 API ENVIRONMENT CONFIGURATION
========================================
Environment: PRODUCTION
Base URL: https://storyforge-production.up.railway.app/api/narrative
...
========================================
```

### 3. Use the Debug Screen

Always verify your configuration using the in-app debug screen before reporting issues.

### 4. Document Your Build

When building for release, document which environment flag was used:

```bash
# Production APK for v1.0.0
flutter build apk --dart-define=ENV=production --release --build-number=1 --build-name=1.0.0
```

## Advanced: Environment-Specific Build Flavors

For more complex scenarios (staging, QA, production), consider Flutter build flavors. However, for this project, dart-define is sufficient.

## Need Help?

1. Check the debug screen (bug icon in app)
2. Review console output for environment configuration
3. Verify backend is accessible via browser
4. Try a clean build
5. Check `DEBUGGING_RAILWAY_CONNECTION.md` for detailed troubleshooting

## Reference

- Flutter dart-define: https://dart.dev/guides/environment-declarations
- StoryForge API Documentation: See backend README
- Debugging Guide: `DEBUGGING_RAILWAY_CONNECTION.md`
