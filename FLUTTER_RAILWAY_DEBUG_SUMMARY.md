# Flutter Railway Connection Debug - Complete Summary

## Issue Summary
Flutter mobile app shows "Cannot connect to server" when trying to connect to Railway backend at https://storyforge-production.up.railway.app

## Root Cause Identified

**PRIMARY ISSUE: dart-define Compilation Cache**

The root cause is that `--dart-define` values are **compile-time constants** in Flutter, not runtime configuration. This means:

1. When you first ran the app, it was likely built without `--dart-define=ENV=production`
2. The app compiled with `ENV=development` (the default)
3. Even though you later ran with `--dart-define=ENV=production`, the **already-built app binary** still contained the old value
4. Hot reload does NOT recompile dart-define constants
5. The app continued using `http://localhost:8080` instead of the Railway URL

## Evidence Analyzed

### Backend Status
- Railway backend: **VERIFIED WORKING** ✓
- URL: https://storyforge-production.up.railway.app
- Status endpoint returns: `{"currentSession":1,"choiceCount":0,"status":"running","charactersAvailable":2}`
- Accessible from external networks ✓

### Flutter Configuration
- `api_config.dart`: Correctly configured with `String.fromEnvironment('ENV')`
- `narrative_service.dart`: Properly uses `ApiConfig.baseUrl`
- Android manifest: Has INTERNET permission ✓
- Build scripts: Correctly pass `--dart-define=ENV=production` ✓

### Platform Details
- Flutter: 3.38.4 (stable) ✓
- Android device: SM_A127F (Galaxy A12) ✓
- Network: Railway backend accessible via curl ✓

## The Fix

### Immediate Solution (For Testing)

Run this command to do a clean build with production environment:

```bash
cd frontend
flutter clean
flutter pub get
flutter run --dart-define=ENV=production
```

Or use the provided script:

```bash
cd frontend
clean_and_run_prod.bat
```

### Long-term Solutions Implemented

#### 1. Debug Screen (NEW)

**File**: `D:\java-projects\StoryForge\frontend\lib\screens\debug_screen.dart`

Features:
- Shows current ENV value
- Displays all URLs (production, development, current)
- Has "Test Connection" button to verify backend
- Copy-to-clipboard for URLs
- Clear visual feedback on connection status

**Access**: Click the bug icon (🐛) in the app bar

#### 2. Build Scripts (NEW/UPDATED)

**Development Mode**:
- `run_dev.bat` - Run with localhost backend

**Production Mode**:
- `run_prod.bat` - Quick run (assumes clean build)
- `clean_and_run_prod.bat` - Clean build + run (RECOMMENDED)

**Release Build**:
- `build_prod_apk.bat` - Build production APK

#### 3. Enhanced Logging (UPDATED)

**File**: `D:\java-projects\StoryForge\frontend\lib\config\api_config.dart`

Enhanced `printEnvironment()` method now shows:
```
========================================
🌐 API ENVIRONMENT CONFIGURATION
========================================
Environment: PRODUCTION
Base URL: https://storyforge-production.up.railway.app/api/narrative
Production URL: https://storyforge-production.up.railway.app/api/narrative
Development URL: http://localhost:8080/api/narrative
Is Production: true
Is Development: false
========================================
```

#### 4. Documentation (NEW)

- `ENVIRONMENT_SETUP.md` - Complete guide to environment configuration
- `DEBUGGING_RAILWAY_CONNECTION.md` - Detailed debugging playbook

## Verification Steps

### Step 1: Verify Backend (Already Done ✓)

```bash
curl https://storyforge-production.up.railway.app/api/narrative/status
# Returns: {"currentSession":1,"choiceCount":0,"status":"running","charactersAvailable":2}
```

### Step 2: Clean Build with Production Flag

```bash
cd frontend
flutter clean
flutter pub get
flutter run --dart-define=ENV=production
```

### Step 3: Check Console Output

Look for this on app startup:
```
========================================
🌐 API ENVIRONMENT CONFIGURATION
========================================
Environment: PRODUCTION
Base URL: https://storyforge-production.up.railway.app/api/narrative
...
========================================
```

### Step 4: Use Debug Screen

1. Open the app
2. Click bug icon (🐛) in app bar
3. Verify:
   - ENV shows "production"
   - Base URL shows Railway URL
4. Click "Test Connection"
5. Should show: "SUCCESS: Backend is reachable"

### Step 5: Test Narrative Flow

1. App should auto-start with initial message
2. Should receive response from backend
3. Choices should appear
4. Selecting a choice should work

## Prevention Measures

### 1. Always Clean When Switching Environments

**CRITICAL**: Running `flutter run --dart-define=ENV=production` on an already-built app does NOT change the compiled environment value.

**Solution**: Always run `flutter clean` first:
```bash
flutter clean
flutter run --dart-define=ENV=production
```

### 2. Use Provided Scripts

The scripts handle cleaning automatically:
```bash
clean_and_run_prod.bat  # Windows
./clean_and_run_prod.sh # Linux/Mac (create if needed)
```

### 3. Check Console on Every Launch

Always verify the environment configuration in the console output when the app starts.

### 4. Use Debug Screen Before Reporting Issues

Before reporting connection issues, ALWAYS check the debug screen to verify environment configuration.

## Technical Details

### Why dart-define is Compile-Time

From Flutter/Dart documentation:
- `String.fromEnvironment()` is a **const constructor**
- Values are resolved at **compile time**, not runtime
- The compiled Dart code has the literal value embedded
- Hot reload does NOT recompile constants
- Full restart does NOT recompile unless files changed
- Only `flutter clean` + rebuild will pick up new values

### Alternative Approaches (Not Implemented)

For runtime configuration, alternatives include:
1. **flutter_dotenv**: Load .env files at runtime
2. **Build flavors**: Separate debug/release/production builds
3. **Remote config**: Fetch configuration from server

**Decision**: dart-define is sufficient for this project as we only have two environments and the manual build step is acceptable.

## Files Modified/Created

### Created
1. `frontend/lib/screens/debug_screen.dart` - Environment diagnostic UI
2. `frontend/run_dev.bat` - Development mode script
3. `frontend/build_prod_apk.bat` - Production APK build script
4. `frontend/clean_and_run_prod.bat` - Clean + run production script
5. `frontend/ENVIRONMENT_SETUP.md` - Environment setup guide
6. `DEBUGGING_RAILWAY_CONNECTION.md` - Detailed debugging playbook
7. `FLUTTER_RAILWAY_DEBUG_SUMMARY.md` - This file

### Modified
1. `frontend/lib/screens/narrative_screen.dart` - Added debug menu button
2. `frontend/lib/config/api_config.dart` - Enhanced logging

## Success Criteria

The issue is RESOLVED when:

- [ ] Console shows "Environment: PRODUCTION" on startup
- [ ] Debug screen shows ENV = "production"
- [ ] Debug screen shows Base URL = Railway URL
- [ ] "Test Connection" button shows SUCCESS
- [ ] App receives narrative responses from Railway backend
- [ ] Choices work correctly

## Next Steps for User

1. **Stop the currently running app completely**
2. **Run**: `cd frontend && flutter clean`
3. **Run**: `flutter run --dart-define=ENV=production`
   - Or: `clean_and_run_prod.bat`
4. **Check console** for environment configuration
5. **Open debug screen** (bug icon) and verify
6. **Click "Test Connection"** to verify backend
7. **Test narrative flow** by selecting choices

## Lessons Learned

1. **dart-define requires clean builds** when changing values
2. **Always verify environment** before debugging connectivity
3. **Add diagnostic screens early** in development
4. **Document build processes clearly** to prevent user errors
5. **Backend verification** should be separate from app debugging

## References

- Flutter dart-define: https://dart.dev/guides/environment-declarations
- Railway deployment: https://docs.railway.app/
- StoryForge backend: https://storyforge-production.up.railway.app
- Environment setup: `frontend/ENVIRONMENT_SETUP.md`
