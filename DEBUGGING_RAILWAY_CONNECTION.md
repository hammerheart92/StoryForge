# Debugging Flutter Railway Connection Issue

## Issue Summary
Flutter mobile app shows "Cannot connect to server" when trying to connect to Railway backend at https://storyforge-production.up.railway.app

## Evidence Analyzed

### 1. Environment Configuration (api_config.dart)
- Uses `String.fromEnvironment('ENV')` to read dart-define values
- Correctly configured with production and development URLs
- Has proper fallback to 'development'

### 2. Service Layer (narrative_service.dart)
- Properly uses ApiConfig.baseUrl
- Has comprehensive error logging
- Includes status check endpoint

### 3. Build Configuration
- `run_prod.bat` correctly passes `--dart-define=ENV=production`
- Android manifest has INTERNET permission
- No network_security_config.xml found (this is OK for HTTPS)

### 4. Platform Details
- Android device: SM_A127F (Galaxy A12)
- Flutter: 3.38.4 (stable)
- Backend verified working via browser

## Root Cause Analysis

After systematic investigation, the most likely issues are:

### Primary Suspect: dart-define Not Propagating to Release/Profile Builds

**Problem**: `--dart-define` values are compile-time constants. If you run the app in debug mode without the flag, then later try to connect in production, the app still has the old compiled value.

**Evidence**:
- Works in web browser (likely debug mode with hot reload)
- Fails on mobile (likely release or profile build)
- Recent commits show environment configuration was just added

### Secondary Suspect: Build Cache Issues

**Problem**: Flutter's build cache might contain old compiled values even after adding --dart-define.

**Evidence**:
- Recent refactor to use dart-define
- No indication of clean build after the change

### Tertiary Suspect: Network Security (Less Likely)

**Problem**: Android 9+ blocks cleartext HTTP by default, but Railway uses HTTPS so this shouldn't be an issue.

**Status**: Unlikely because:
- Railway URL is HTTPS (not HTTP)
- Manifest has INTERNET permission
- Status check from browser works

## Solution Steps

### Step 1: Verify Current Environment
1. Run the app with the debug screen
2. Check what ENV value is actually being read
3. Verify the baseUrl matches expectations

### Step 2: Clean Build
```bash
cd frontend
flutter clean
flutter pub get
flutter run --dart-define=ENV=production
```

### Step 3: For Release Builds
If building release APK:
```bash
flutter build apk --dart-define=ENV=production --release
```

### Step 4: Verify dart-define Propagation
The debug screen will show:
- Current ENV value
- Resolved baseUrl
- Connection test results

## Prevention Measures

### 1. Add Build Scripts
Create separate scripts for different environments:

**run_dev.bat**:
```batch
flutter run --dart-define=ENV=development
```

**run_prod.bat** (already exists):
```batch
flutter run --dart-define=ENV=production
```

**build_prod_apk.bat**:
```batch
flutter build apk --dart-define=ENV=production --release
```

### 2. Add Startup Logging
The app already prints environment info via `NarrativeService.printCurrentEnvironment()` in the provider initialization.

### 3. Consider Environment Config File
For more complex scenarios, consider using flutter_dotenv or similar packages that load config at runtime rather than compile-time.

## Testing Checklist

- [ ] Run app with `flutter run --dart-define=ENV=production`
- [ ] Open debug screen (bug icon in app bar)
- [ ] Verify ENV shows "production"
- [ ] Verify Base URL shows Railway URL
- [ ] Click "Test Connection" button
- [ ] Verify backend status returns SUCCESS
- [ ] Try sending a narrative message
- [ ] Verify choices are received

## Key Learnings

1. **dart-define is compile-time**: Changes require rebuild, hot reload won't pick them up
2. **Always clean after environment changes**: `flutter clean` before switching environments
3. **Debug screens are essential**: Always include environment diagnostics in production apps
4. **Document build processes**: Clear instructions prevent configuration errors

## Next Steps

1. Test with the debug screen to confirm the diagnosis
2. Clean build with production flag
3. If issue persists, check backend logs for CORS or other server-side errors
4. Consider adding connection retry logic
5. Add better error messages with environment info
