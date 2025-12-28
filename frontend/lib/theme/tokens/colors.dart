import 'package:flutter/material.dart';

class DesignColors {
  // ==================== LIGHT MODE COLORS ====================

  // Semantic colors (status indicators)
  static const lSuccess = Color(0xFF6BD9A7);      // Green - for success states
  static const lWarning = Color(0xFFFFD166);      // Yellow - for warnings
  static const lDanger = Color(0xFFFF6B6B);       // Red - for errors/alerts
  static const lSecondary = Color(0xFFFF9E5E);    // Orange - secondary accent

  // Background & Surface colors
  static const lBackground = Color(0xFFF8F9FA);   // Main background
  static const lSurfaces = Color(0xFFE9ECEF);     // Cards, containers

  // Text colors
  static const lPrimaryText = Color(0xFF212529);      // Main text
  static const lSecondaryText = Color(0xFF6C757D);    // Subtle text
  static const lTextOnSecondaryBg = Color(0xFF1A365D); // Text on colored bg

  // UI State colors
  static const lDisabled = Color(0xFFAFAFAF);     // Disabled elements

  // ==================== DARK MODE COLORS ====================

  // Semantic colors (status indicators)
  static const dSuccess = Color(0xFF64D1A2);      // Green - for success states
  static const dWarning = Color(0xFFFFD860);      // Yellow - for warnings
  static const dDanger = Color(0xFFFF7F7F);       // Red - for errors/alerts
  static const dSecondary = Color(0xFFFFB27D);    // Orange - secondary accent

  // Background & Surface colors
  static const dBackground = Color(0xFF121417);   // Main background
  static const dSurfaces = Color(0xFF23272C);     // Cards, containers

  // Text colors
  static const dPrimaryText = Color(0xFFF1F3F5);      // Main text
  static const dSecondaryText = Color(0xFFB0B3B8);    // Subtle text
  static const dTextOnSecondaryBg = Color(0xFFA5A8AD); // Text on colored bg

  // UI State colors
  static const dDisabled = Color(0xFF555A60);     // Disabled elements

  // ==================== HIGHLIGHT COLORS ====================
  // These are the 8 user-selectable accent colors from the kit

  static const highlightBlue = Color(0xFF4A8FE7);       // Soft Blue
  static const highlightPink = Color(0xFFE3B7C4);       // Rose Quartz
  static const highlightCoral = Color(0xFFFF7C70);      // Coral Rose
  static const highlightPurple = Color(0xFFA88ED9);     // Lavender Mist (default)
  static const highlightYellow = Color(0xFFF6C343);     // Sunflower Gold
  static const highlightTeal = Color(0xFF30B2A3);       // Aqua Breeze
  static const highlightPeach = Color(0xFFFDAF9D);      // Blush Peach
  static const highlightNavy = Color(0xFF2E3A59);       // Storm Blue

  // List of all highlight colors (useful for color picker UI)
  static const List<Color> highlightColors = [
    highlightBlue,
    highlightPink,
    highlightCoral,
    highlightPurple,
    highlightYellow,
    highlightTeal,
    highlightPeach,
    highlightNavy,
  ];
}