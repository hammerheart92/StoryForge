// Typography system with 3 font families: Poppins, Inter, Quicksand

import 'package:flutter/material.dart';

class DesignTypography {
  // ==================== HEADINGS (Poppins) ====================
  // Used for: Screen titles, section headers

  static const headingLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 32,
    fontWeight: FontWeight.w600, // SemiBold
  );

  static const headingMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w600, // SemiBold
  );

  // ==================== CALL-TO-ACTION (Poppins) ====================
  // Used for: Buttons, important labels

  static const ctaBold = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  // ==================== BODY TEXT (Inter) ====================
  // Used for: Main content, descriptions

  static const bodyRegular = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w500, // Medium
  );

  static const buttonText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600, // SemiBold
    color: Colors.white,
  );

  // ==================== PLAYFUL ACCENTS (Quicksand) ====================
  // Used for: Pet names, friendly UI elements

  static const petName = TextStyle(
    fontFamily: 'Quicksand',
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
  );

  static const playfulTag = TextStyle(
    fontFamily: 'Quicksand',
    fontSize: 14,
    fontWeight: FontWeight.w700, // Bold
  );
}

// ==================== FONT SETUP INSTRUCTIONS ====================
// Add to pubspec.yaml:
//
// Option 1 - Use Google Fonts (easiest):
// dependencies:
//   google_fonts: ^6.1.0
//
// Then use: GoogleFonts.poppins(), GoogleFonts.inter(), GoogleFonts.quicksand()
//
// Option 2 - Download fonts manually:
// 1. Download fonts from Google Fonts
// 2. Add to pubspec.yaml:
//
// flutter:
//   fonts:
//     - family: Poppins
//       fonts:
//         - asset: assets/fonts/Poppins-Regular.ttf
//         - asset: assets/fonts/Poppins-SemiBold.ttf
//           weight: 600
//         - asset: assets/fonts/Poppins-Bold.ttf
//           weight: 700
//     - family: Inter
//       fonts:
//         - asset: assets/fonts/Inter-Regular.ttf
//         - asset: assets/fonts/Inter-Medium.ttf
//           weight: 500
//         - asset: assets/fonts/Inter-SemiBold.ttf
//           weight: 600
//     - family: Quicksand
//       fonts:
//         - asset: assets/fonts/Quicksand-Medium.ttf
//           weight: 500
//         - asset: assets/fonts/Quicksand-Bold.ttf
//           weight: 700