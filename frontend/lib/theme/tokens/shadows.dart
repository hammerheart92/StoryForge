import 'package:flutter/material.dart';

class DesignShadows {
  // ==================== ELEVATION SHADOWS ====================

  /// No shadow - Flat elements
  /// Use for: Inline elements, flat buttons
  static const List<BoxShadow> none = [];

  /// Subtle shadow - Elevation 1
  /// Use for: Subtle cards, slight depth
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0D000000), // 5% black
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Standard shadow - Elevation 2
  /// Use for: Cards, containers, buttons
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Medium-Large shadow - Elevation 3
  /// Use for: Raised cards, floating elements
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1F000000), // 12% black
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Large shadow - Elevation 4
  /// Use for: Modals, overlays, important cards
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x26000000), // 15% black
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  /// Extra large shadow - Elevation 5
  /// Use for: Dialogs, bottom sheets, navigation drawers
  static const List<BoxShadow> xxl = [
    BoxShadow(
      color: Color(0x33000000), // 20% black
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // ==================== COLORED SHADOWS ====================
  // Subtle colored shadows for highlight elements

  /// Primary color shadow (soft)
  /// Use for: Primary buttons, important CTAs
  static List<BoxShadow> primary(Color primaryColor) => [
    BoxShadow(
      color: primaryColor.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Success color shadow
  /// Use for: Success states, positive actions
  static const List<BoxShadow> success = [
    BoxShadow(
      color: Color(0x4D6BD9A7), // 30% green
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Danger color shadow
  /// Use for: Delete buttons, critical actions
  static const List<BoxShadow> danger = [
    BoxShadow(
      color: Color(0x4DFF6B6B), // 30% red
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // ==================== DARK MODE SHADOWS ====================
  // Lighter shadows for dark backgrounds

  /// Dark mode standard shadow
  /// Use for: Cards in dark mode
  static const List<BoxShadow> darkMd = [
    BoxShadow(
      color: Color(0x33000000), // 20% black (stronger for dark mode)
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Dark mode large shadow
  /// Use for: Elevated elements in dark mode
  static const List<BoxShadow> darkLg = [
    BoxShadow(
      color: Color(0x40000000), // 25% black
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}