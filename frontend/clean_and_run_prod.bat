@echo off
echo.
echo ========================================
echo  Clean Build + Run (PRODUCTION mode)
echo  Backend: Railway Cloud
echo ========================================
echo.
echo Step 1: Cleaning build cache...
call flutter clean
echo.
echo Step 2: Getting dependencies...
call flutter pub get
echo.
echo Step 3: Running app in production mode...
call flutter run --dart-define=ENV=production
