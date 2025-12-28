#!/bin/bash

echo ""
echo "========================================"
echo " Clean Build + Run (PRODUCTION mode)"
echo " Backend: Railway Cloud"
echo "========================================"
echo ""

echo "Step 1: Cleaning build cache..."
flutter clean
echo ""

echo "Step 2: Getting dependencies..."
flutter pub get
echo ""

echo "Step 3: Running app in production mode..."
flutter run --dart-define=ENV=production
