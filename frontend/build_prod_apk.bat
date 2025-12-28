@echo off
echo.
echo ========================================
echo  Building StoryForge APK (PRODUCTION)
echo  Backend: Railway Cloud
echo ========================================
echo.
echo Cleaning previous builds...
call flutter clean
echo.
echo Getting dependencies...
call flutter pub get
echo.
echo Building release APK with production environment...
call flutter build apk --dart-define=ENV=production --release
echo.
echo ========================================
echo  Build complete!
echo  APK location: build\app\outputs\flutter-apk\app-release.apk
echo ========================================
echo.
pause
