# Flutter Development Setup Guide for Windows

**Target:** StoryForge Frontend Development  
**Platform:** Windows 10/11  
**Last Updated:** January 30, 2026

---

## Overview

This guide covers complete Flutter development environment setup for working on StoryForge's mobile frontend. After completing this setup, you'll be able to:
- Run Flutter commands (`flutter pub get`, `flutter run`, etc.)
- Build and test the StoryForge Flutter app
- Use Android emulators or physical devices
- Integrate assets (images, fonts, etc.)

**Estimated Setup Time:** 1-2 hours (depending on download speeds)

---

## Prerequisites

### System Requirements
- **OS:** Windows 10 (64-bit) or Windows 11
- **Disk Space:** At least 10 GB free space
- **RAM:** Minimum 8 GB (16 GB recommended)
- **Internet:** Required for downloads and initial setup

### Required Software
You'll install:
1. Flutter SDK
2. Android Studio (includes Android SDK)
3. Git (already installed ✓)
4. Visual Studio Code or Android Studio (IDE)

---

## Installation Steps

### Step 1: Download Flutter SDK

#### 1.1 Download
1. Go to: https://docs.flutter.dev/get-started/install/windows
2. Click **"Download Flutter SDK"** button
3. Download the latest stable release (`.zip` file)
   - Example: `flutter_windows_3.x.x-stable.zip` (~2 GB)

#### 1.2 Extract Flutter SDK
1. Choose installation location (recommendation):
   ```
   C:\flutter
   ```
   **IMPORTANT:** Do NOT install in:
   - `C:\Program Files\` (requires admin privileges)
   - Paths with spaces or special characters

2. Extract the downloaded `.zip` file to `C:\flutter`
3. Final structure should be:
   ```
   C:\flutter\
   ├── bin\
   │   └── flutter.bat
   ├── packages\
   └── ...
   ```

#### 1.3 Verify Extraction
Open PowerShell and run:
```powershell
C:\flutter\bin\flutter --version
```
Should show Flutter version information.

---

### Step 2: Install Android Studio

#### 2.1 Download Android Studio
1. Go to: https://developer.android.com/studio
2. Click **"Download Android Studio"**
3. Accept terms and download (~1 GB)

#### 2.2 Install Android Studio
1. Run the installer (`android-studio-xxxx.exe`)
2. Installation wizard:
   - **Install Type:** Standard
   - **Theme:** Choose your preference
   - **Components:** Make sure these are selected:
     - ✓ Android SDK
     - ✓ Android SDK Platform
     - ✓ Android Virtual Device

3. Click **"Finish"** and wait for component downloads (~3-5 GB)

#### 2.3 SDK Configuration
After installation completes:
1. Open Android Studio
2. Click **"More Actions"** → **"SDK Manager"**
3. In **SDK Platforms** tab:
   - ✓ Check **Android 13.0 (Tiramisu)** API Level 33 (or latest)
   - ✓ Check **Android 12.0 (S)** API Level 31 (for compatibility)
4. In **SDK Tools** tab, ensure these are installed:
   - ✓ Android SDK Build-Tools
   - ✓ Android SDK Command-line Tools
   - ✓ Android Emulator
   - ✓ Android SDK Platform-Tools
5. Click **"Apply"** to download selected components

#### 2.4 Note SDK Location
The Android SDK is typically installed at:
```
C:\Users\[YourUsername]\AppData\Local\Android\Sdk
```
**Write this path down - you'll need it for environment variables!**

---

### Step 3: Configure Environment Variables

#### 3.1 Open Environment Variables
1. Press `Win + X`
2. Select **"System"**
3. Click **"Advanced system settings"**
4. Click **"Environment Variables"** button

#### 3.2 Add ANDROID_HOME (System Variable)
1. Under **"System variables"** section, click **"New..."**
2. **Variable name:** `ANDROID_HOME`
3. **Variable value:** `C:\Users\[YourUsername]\AppData\Local\Android\Sdk`
   - Replace `[YourUsername]` with your actual Windows username
   - Example: `C:\Users\Lex\AppData\Local\Android\Sdk`
4. Click **"OK"**

#### 3.3 Add ANDROID_SDK_ROOT (System Variable)
1. Click **"New..."** again
2. **Variable name:** `ANDROID_SDK_ROOT`
3. **Variable value:** Same as ANDROID_HOME
   - `C:\Users\[YourUsername]\AppData\Local\Android\Sdk`
4. Click **"OK"**

#### 3.4 Update PATH Variable
1. Under **"System variables"**, find and select **"Path"**
2. Click **"Edit..."**
3. Click **"New"** and add these entries ONE BY ONE:

```
C:\flutter\bin
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\cmdline-tools\latest\bin
%ANDROID_HOME%\emulator
```

4. Click **"OK"** on all dialogs
5. **IMPORTANT:** Restart any open terminals/IDEs for changes to take effect

#### 3.5 Verify Environment Variables
Open a **NEW** PowerShell window and run:
```powershell
# Check Flutter
echo $env:PATH | Select-String "flutter"

# Check Android SDK
echo $env:ANDROID_HOME
echo $env:ANDROID_SDK_ROOT

# Should output the SDK path
```

---

### Step 4: Accept Android Licenses

#### 4.1 Run License Command
Open PowerShell and run:
```powershell
flutter doctor --android-licenses
```

#### 4.2 Accept All Licenses
- You'll be prompted multiple times
- Type `y` and press Enter for each license
- Continue until you see: `All SDK package licenses accepted`

---

### Step 5: Verify Installation

#### 5.1 Run Flutter Doctor
```powershell
flutter doctor
```

#### 5.2 Expected Output
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x, on Microsoft Windows)
[✓] Android toolchain - develop for Android devices (Android SDK version 33.x.x)
[✓] Chrome - develop for the web
[✓] Visual Studio - develop Windows apps (optional)
[✓] Android Studio (version 2023.x)
[✓] VS Code (version 1.x.x) (optional)
[✓] Connected device (1 available)
[✓] Network resources

• No issues found!
```

#### 5.3 Common Warnings (Can Ignore)
- **Visual Studio** - Only needed for Windows desktop apps (not required for StoryForge)
- **Xcode** - Only on macOS (not applicable for Windows)

#### 5.4 Issues to Fix
If you see ❌ for Android toolchain or Android Studio:
- Re-check environment variables (ANDROID_HOME, PATH)
- Restart terminal/computer
- Re-run `flutter doctor --android-licenses`

---

### Step 6: Create Android Virtual Device (Emulator)

#### 6.1 Open Device Manager
1. Open Android Studio
2. Click **"More Actions"** → **"Virtual Device Manager"**
3. Click **"Create Device"**

#### 6.2 Configure Virtual Device
1. **Select Hardware:**
   - Choose **"Pixel 6"** or **"Pixel 7"** (recommended)
   - Click **"Next"**

2. **Select System Image:**
   - Click **"Download"** next to latest Android version (e.g., Tiramisu API 33)
   - Wait for download to complete
   - Select the downloaded image
   - Click **"Next"**

3. **Verify Configuration:**
   - **AVD Name:** Pixel_6_API_33 (or similar)
   - **Startup orientation:** Portrait
   - Click **"Finish"**

#### 6.3 Test Emulator
1. In Device Manager, click **▶ (Play)** button next to your device
2. Wait for emulator to boot (first time takes 2-3 minutes)
3. You should see Android home screen

---

### Step 7: Install IDE Extensions (Optional but Recommended)

#### For Visual Studio Code:
1. Open VS Code
2. Go to Extensions (`Ctrl + Shift + X`)
3. Search and install:
   - **Flutter** (by Dart Code)
   - **Dart** (by Dart Code)

#### For Android Studio:
1. Open Android Studio
2. **File** → **Settings** → **Plugins**
3. Search and install:
   - **Flutter** plugin
   - **Dart** plugin (auto-installed with Flutter)
4. Restart Android Studio

---

## Working with StoryForge Flutter Project

### Clone Repository (If Not Already Done)
```powershell
cd D:\java-projects
git clone https://github.com/hammerheart92/StoryForge.git
cd StoryForge\frontend
```

### Essential Flutter Commands

#### Get Dependencies
Run this whenever `pubspec.yaml` changes:
```powershell
flutter pub get
```

#### Clean Build Files
Run when you have build issues:
```powershell
flutter clean
```

#### Run App (Debug Mode)
**On Emulator:**
1. Start your Android emulator first
2. Then run:
```powershell
flutter run
```

**On Physical Device:**
1. Enable Developer Options on your Android phone:
   - Go to **Settings** → **About Phone**
   - Tap **Build Number** 7 times
   - Go back to **Settings** → **Developer Options**
   - Enable **USB Debugging**
2. Connect phone via USB
3. Run:
```powershell
flutter devices  # Should list your device
flutter run
```

#### Build Release APK
```powershell
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

#### Check for Issues
```powershell
flutter doctor -v
```
Shows detailed diagnostics.

---

## Common Tasks for StoryForge Development

### Adding Assets (Images, Fonts, etc.)

#### 1. Add Files to Project
Place assets in appropriate folders:
```
frontend/
├── assets/
│   ├── images/
│   │   └── pirates/
│   │       └── treasure_map.png
│   ├── fonts/
│   └── ...
```

#### 2. Update pubspec.yaml
```yaml
flutter:
  assets:
    - assets/images/pirates/
    - assets/images/
  
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
```

#### 3. Get Dependencies
```powershell
flutter pub get
```

#### 4. Use in Code
```dart
Image.asset('assets/images/pirates/treasure_map.png')
```

### Updating Dependencies

#### When pubspec.yaml Changes (Git Pull)
```powershell
git pull origin main
cd frontend
flutter pub get
```

#### Upgrade All Packages
```powershell
flutter pub upgrade
```

### Hot Reload During Development
When app is running in debug mode:
- Press `r` in terminal for **hot reload** (fast, preserves state)
- Press `R` for **hot restart** (slower, resets state)
- Press `q` to quit

---

## Troubleshooting

### Issue 1: "flutter is not recognized"
**Cause:** PATH not set correctly

**Solution:**
1. Verify `C:\flutter\bin` is in PATH
2. Restart terminal
3. Run: `flutter --version`

---

### Issue 2: "Android SDK not found"
**Cause:** ANDROID_HOME not set or incorrect

**Solution:**
1. Verify SDK location:
   ```powershell
   ls C:\Users\[YourUsername]\AppData\Local\Android\Sdk
   ```
2. Re-set ANDROID_HOME environment variable
3. Restart terminal
4. Run: `flutter doctor`

---

### Issue 3: "No devices available"
**Cause:** No emulator running or device connected

**Solution:**
1. Start emulator from Android Studio
2. Or connect physical device with USB debugging
3. Verify with: `flutter devices`

---

### Issue 4: "Gradle build failed"
**Cause:** Various (outdated dependencies, cache issues)

**Solution:**
```powershell
cd frontend
flutter clean
flutter pub get
flutter run
```

If still failing:
```powershell
cd android
.\gradlew clean
cd ..
flutter run
```

---

### Issue 5: "License not accepted"
**Cause:** Android SDK licenses not accepted

**Solution:**
```powershell
flutter doctor --android-licenses
# Press 'y' for all prompts
```

---

### Issue 6: Emulator is Slow
**Solutions:**
1. **Enable Hardware Acceleration:**
   - Android Studio → Tools → SDK Manager → SDK Tools
   - Install "Intel x86 Emulator Accelerator (HAXM)"

2. **Increase Emulator RAM:**
   - Edit AVD settings → Advanced Settings
   - Increase RAM to 4GB or 8GB (if your PC has enough)

3. **Use Physical Device:**
   - Generally faster than emulators

---

### Issue 7: "Could not find or load main class org.gradle.wrapper.GradleWrapperMain"
**Cause:** Gradle wrapper missing

**Solution:**
```powershell
cd frontend\android
.\gradlew wrapper --gradle-version 8.0
cd ..\..
flutter run
```

---

## Useful Commands Reference

### Flutter Commands
```powershell
# Version and diagnostics
flutter --version
flutter doctor
flutter doctor -v

# Project commands
flutter create my_app
flutter pub get
flutter pub upgrade
flutter pub outdated

# Running
flutter run
flutter run --release
flutter run -d <device_id>

# Building
flutter build apk
flutter build apk --release
flutter build appbundle

# Cleaning
flutter clean

# Devices
flutter devices
flutter emulators
flutter emulators --launch <emulator_id>

# Analysis
flutter analyze
flutter test
```

### ADB Commands (Android Debug Bridge)
```powershell
# List devices
adb devices

# Install APK
adb install app-release.apk

# View logs
adb logcat

# Screenshot
adb exec-out screencap -p > screenshot.png

# Restart ADB
adb kill-server
adb start-server
```

---

## Best Practices for StoryForge Development

### 1. Before Starting Work
```powershell
git pull origin main
cd frontend
flutter pub get
flutter clean
```

### 2. During Development
- Use **hot reload** (`r`) for quick UI changes
- Use **hot restart** (`R`) when changing state logic
- Check console for errors/warnings

### 3. Before Committing
```powershell
flutter analyze  # Check for code issues
flutter test     # Run tests (when available)
```

### 4. Testing on Multiple Devices
- Test on at least one emulator
- Test on physical device (if possible)
- Check different screen sizes

### 5. Asset Management
- Keep assets organized in folders
- Use appropriate image formats (PNG for transparency, JPG for photos)
- Optimize images before adding (use tools like TinyPNG)

---

## Performance Tips

### 1. Keep Dependencies Updated
```powershell
flutter pub outdated  # Check for updates
flutter pub upgrade   # Upgrade all
```

### 2. Profile App Performance
```powershell
flutter run --profile
# Then use DevTools for profiling
```

### 3. Build Size Optimization
```powershell
flutter build apk --split-per-abi
# Creates separate APKs for each architecture (smaller file sizes)
```

---

## Next Steps After Setup

### 1. Verify Everything Works
```powershell
cd D:\java-projects\StoryForge\frontend
flutter pub get
flutter run
```

### 2. Explore StoryForge Frontend Code
```
frontend/
├── lib/
│   ├── main.dart           # App entry point
│   ├── screens/            # UI screens
│   ├── widgets/            # Reusable components
│   ├── models/             # Data models
│   └── services/           # API calls, business logic
├── assets/                 # Images, fonts
├── pubspec.yaml            # Dependencies
└── README.md               # Project documentation
```

### 3. Run Backend (Required for Full Testing)
See backend README for Spring Boot setup.

### 4. Practice with Simple Changes
- Try changing text or colors
- Add a new image asset
- Experiment with hot reload

---

## Getting Help

### Resources
- **Flutter Documentation:** https://docs.flutter.dev
- **Flutter Cookbook:** https://docs.flutter.dev/cookbook
- **Dart Language Tour:** https://dart.dev/guides/language/language-tour
- **Stack Overflow:** https://stackoverflow.com/questions/tagged/flutter

### StoryForge-Specific Help
- Check `frontend/README.md` for project-specific docs
- Ask Laszlo (main developer) for architecture questions
- Use Claude Code for code assistance

---

## Checklist: Setup Complete ✓

Use this checklist to verify your setup:

- [ ] Flutter SDK installed at `C:\flutter`
- [ ] Android Studio installed
- [ ] Android SDK installed (check in SDK Manager)
- [ ] Environment variables set:
  - [ ] `ANDROID_HOME`
  - [ ] `ANDROID_SDK_ROOT`
  - [ ] Flutter bin in `PATH`
- [ ] `flutter doctor` shows all green checkmarks (except optional items)
- [ ] Android licenses accepted
- [ ] At least one Android emulator created
- [ ] IDE extensions installed (Flutter + Dart)
- [ ] StoryForge frontend runs successfully: `flutter run`

**If all items checked:** 🎉 **Setup Complete! You're ready to develop!**

---

## Quick Reference Card

**Print this for easy access:**

```
FLUTTER QUICK REFERENCE
=======================

Essential Commands:
-------------------
flutter pub get          # Get dependencies
flutter clean            # Clean build
flutter run              # Run app (debug)
flutter run --release    # Run (release)
flutter doctor           # Check setup
flutter devices          # List devices

Hot Keys (during flutter run):
-------------------------------
r    # Hot reload (fast)
R    # Hot restart (full)
q    # Quit

Troubleshooting:
----------------
1. flutter clean && flutter pub get
2. Restart emulator
3. flutter doctor -v
4. Check ANDROID_HOME environment variable

Environment Variables:
----------------------
ANDROID_HOME: C:\Users\[You]\AppData\Local\Android\Sdk
ANDROID_SDK_ROOT: (same as ANDROID_HOME)
PATH: C:\flutter\bin (and Android SDK paths)
```

---

**Good luck with StoryForge development!** 🚀

*Last updated: January 30, 2026*
