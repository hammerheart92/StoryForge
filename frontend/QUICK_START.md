# StoryForge Flutter - Quick Start

## Running the App

### Development (Localhost Backend)

**Windows:**
```bash
run_dev.bat
```

**Linux/Mac:**
```bash
./run_dev.sh
```

### Production (Railway Backend)

**Windows (Recommended - includes clean build):**
```bash
clean_and_run_prod.bat
```

**Linux/Mac:**
```bash
./clean_and_run_prod.sh
```

## Building Release APK

**Windows:**
```bash
build_prod_apk.bat
```

**Linux/Mac:**
```bash
flutter clean
flutter pub get
flutter build apk --dart-define=ENV=production --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting

### Can't connect to server?

1. Click the bug icon (🐛) in the app
2. Check environment shows correct values
3. Click "Test Connection"
4. If wrong environment, do a clean build:
   ```bash
   flutter clean
   flutter run --dart-define=ENV=production
   ```

### Backend URLs

- **Development**: http://localhost:8080/api/narrative
- **Production**: https://storyforge-production.up.railway.app/api/narrative

### Verify Backend is Running

**Development:**
```bash
curl http://localhost:8080/api/narrative/status
```

**Production:**
```bash
curl https://storyforge-production.up.railway.app/api/narrative/status
```

## Important Notes

- Environment values are **compile-time constants**
- Always run `flutter clean` when switching environments
- Use the debug screen (bug icon) to verify configuration
- Check console output for environment info on startup

## Need More Help?

See: `ENVIRONMENT_SETUP.md` for detailed documentation
