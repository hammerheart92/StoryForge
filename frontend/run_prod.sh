#!/bin/bash

echo ""
echo "========================================"
echo " Running StoryForge in PRODUCTION mode"
echo " Backend: Railway Cloud"
echo "========================================"
echo ""

flutter run --dart-define=ENV=production
