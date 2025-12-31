// lib/services/settings_service.dart
// Service for managing app settings with SharedPreferences persistence

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Text size options for the app
enum TextSize {
  small,  // 14px
  medium, // 16px
  large   // 18px
}

/// Extension to get pixel values for TextSize
extension TextSizeExtension on TextSize {
  double get pixels {
    switch (this) {
      case TextSize.small:
        return 14.0;
      case TextSize.medium:
        return 16.0;
      case TextSize.large:
        return 18.0;
    }
  }
}

/// App settings model with JSON serialization
class AppSettings {
  final int animationSpeed;   // milliseconds per character (0-100)
  final TextSize textSize;    // small/medium/large
  final String language;      // 'en' or 'ro'

  const AppSettings({
    this.animationSpeed = 20,
    this.textSize = TextSize.medium,
    this.language = 'en',
  });

  /// Convert settings to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'animationSpeed': animationSpeed,
      'textSize': textSize.name,
      'language': language,
    };
  }

  /// Create settings from JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      animationSpeed: json['animationSpeed'] ?? 20,
      textSize: TextSize.values.firstWhere(
        (e) => e.name == json['textSize'],
        orElse: () => TextSize.medium,
      ),
      language: json['language'] ?? 'en',
    );
  }

  /// Create a copy with modified fields
  AppSettings copyWith({
    int? animationSpeed,
    TextSize? textSize,
    String? language,
  }) {
    return AppSettings(
      animationSpeed: animationSpeed ?? this.animationSpeed,
      textSize: textSize ?? this.textSize,
      language: language ?? this.language,
    );
  }

  @override
  String toString() {
    return 'AppSettings(animationSpeed: $animationSpeed, textSize: ${textSize.name}, language: $language)';
  }
}

/// Service for loading and saving app settings
class SettingsService {
  static const String _keySettings = 'app_settings';

  /// Load settings from SharedPreferences
  static Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_keySettings);

    if (settingsJson == null) {
      return const AppSettings(); // Return defaults
    }

    try {
      final json = jsonDecode(settingsJson);
      return AppSettings.fromJson(json);
    } catch (e) {
      print('Error loading settings: $e');
      return const AppSettings();
    }
  }

  /// Save settings to SharedPreferences
  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, jsonEncode(settings.toJson()));
    print('Settings saved: ${settings.animationSpeed}ms, ${settings.textSize.name}, ${settings.language}');
  }

  /// Reset settings to defaults
  static Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySettings);
    print('Settings reset to defaults');
  }
}
