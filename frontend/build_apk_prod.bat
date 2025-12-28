@echo off
echo.
echo ========================================
echo  Building APK for PRODUCTION (Railway)
echo ========================================
echo.
echo Cleaning previous build...
flutter clean
echo.
echo Building release APK...
flutter build apk --release --dart-define=ENV=production
echo.
echo ========================================
echo  BUILD COMPLETE!
echo ========================================
echo.
echo APK Location:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo This APK connects to Railway backend.
echo Send this to your partner for testing!
echo.
pause