#!/bin/bash

echo ""
echo "========================================"
echo " Running StoryForge in DEVELOPMENT mode"
echo " Backend: Localhost (http://localhost:8080)"
echo "========================================"
echo ""

flutter run --dart-define=ENV=development
