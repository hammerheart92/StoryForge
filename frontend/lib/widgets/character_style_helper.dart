// lib/widgets/character_style_helper.dart
// Helper class for character-specific styling

import 'package:flutter/material.dart';

class CharacterStyle {
  final Color accentColor;      // Character's theme color
  final String fontFamily;      // Custom font
  final String icon;            // Emoji icon
  final Color glowColor;        // Glow effect color
  final double actionFontSize;  // ⭐ NEW: Custom action text size
  final double dialogueFontSize; // ⭐ NEW: Custom dialogue size

  CharacterStyle({
    required this.accentColor,
    required this.fontFamily,
    required this.icon,
    required this.glowColor,
    this.actionFontSize = 15.0,    // ⭐ NEW: Default 15
    this.dialogueFontSize = 16.0,  // ⭐ NEW: Default 16
  });

  /// Get the style for a specific character
  static CharacterStyle forSpeaker(String speaker) {
    switch (speaker.toLowerCase()) {
      case 'narrator':
        return CharacterStyle(
          accentColor: const Color(0xFF1A7F8A),  // Teal
          fontFamily: 'Merriweather',
          icon: '📖',
          glowColor: const Color(0xFF1A7F8A).withOpacity(0.3),
          actionFontSize: 15.0,   // Standard size
          dialogueFontSize: 16.0, // Standard size
        );

      case 'ilyra':
        return CharacterStyle(
          accentColor: const Color(0xFF6B4A9E),  // Purple
          fontFamily: 'DancingScript',
          icon: '⭐',
          glowColor: const Color(0xFF6B4A9E).withOpacity(0.3),
          actionFontSize: 17.0,   // ⭐ BIGGER for script font
          dialogueFontSize: 18.0, // ⭐ BIGGER for script font
        );

      case 'user':
      default:
        return CharacterStyle(
          accentColor: const Color(0xFF2196F3),  // Blue
          fontFamily: 'Roboto',  // Default Flutter font
          icon: '',  // No icon for user
          glowColor: const Color(0xFF2196F3).withOpacity(0.2),
          actionFontSize: 15.0,   // Standard size
          dialogueFontSize: 16.0, // Standard size
        );
    }
  }
}