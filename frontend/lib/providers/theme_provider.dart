// lib/providers/theme_provider.dart
// State management for app theme (light/dark/system)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings_service.dart';

/// Immutable state for theme management
class ThemeState {
  final ThemeMode themeMode;
  final bool isLoading;

  const ThemeState({
    required this.themeMode,
    this.isLoading = false,
  });

  /// Initial state defaults to system
  factory ThemeState.initial() {
    return const ThemeState(
      themeMode: ThemeMode.system,
      isLoading: true,
    );
  }

  /// Create copy with updated fields
  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isLoading,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  String toString() => 'ThemeState(themeMode: $themeMode, isLoading: $isLoading)';
}

/// StateNotifier for managing theme state
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState.initial()) {
    _loadTheme();
  }

  /// Load theme from settings
  Future<void> _loadTheme() async {
    try {
      final settings = await SettingsService.loadSettings();
      state = state.copyWith(
        themeMode: _parseThemeMode(settings.themeMode),
        isLoading: false,
      );
    } catch (e) {
      // Default to system on error
      state = state.copyWith(isLoading: false);
    }
  }

  /// Parse string to ThemeMode
  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Convert ThemeMode to string for storage
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Set theme mode and persist
  Future<void> setThemeMode(ThemeMode mode) async {
    // Update state immediately for responsive UI
    state = state.copyWith(themeMode: mode);

    // Persist via SettingsService
    final settings = await SettingsService.loadSettings();
    final newSettings = settings.copyWith(
      themeMode: _themeModeToString(mode),
    );
    await SettingsService.saveSettings(newSettings);
  }
}

/// Provider for theme state with auto-loading
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

/// Convenience provider for just the ThemeMode
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeProvider.select((state) => state.themeMode));
});

/// Provider for checking if theme is loading
final themeLoadingProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider.select((state) => state.isLoading));
});
