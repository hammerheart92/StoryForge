// lib/theme/storyforge_theme.dart
// Adapted for narrative storytelling experience

import 'package:flutter/material.dart';
import 'tokens/colors.dart';
import 'tokens/spacing.dart';
import 'tokens/shadows.dart';
import 'tokens/typography.dart';

class StoryForgeTheme {
  // ==================== CHARACTER COLORS ====================

  /// Narrator - Serious, observant, neutral
  static const narratorColor = DesignColors.highlightNavy;

  /// Ilyra - Mystical, celestial, enigmatic
  static const ilyraColor = DesignColors.highlightPurple;

  /// User/Player - Interactive, engaging
  static const userColor = DesignColors.highlightBlue;

  /// Default for any new character
  static const defaultCharacterColor = DesignColors.highlightTeal;

  /// Map character IDs to colors
  static Color getCharacterColor(String characterId) {
    switch (characterId.toLowerCase()) {
      case 'narrator':
        return narratorColor;
      case 'ilyra':
        return ilyraColor;
      case 'user':
        return userColor;
      default:
        return defaultCharacterColor;
    }
  }

  // ==================== APP COLORS ====================

  /// Primary brand color (teal for storytelling)
  static const primaryColor = DesignColors.highlightTeal;

  /// Background colors
  static const backgroundColor = DesignColors.lBackground;
  static const surfaceColor = DesignColors.lSurfaces;

  /// Text colors
  static const primaryText = DesignColors.lPrimaryText;
  static const secondaryText = DesignColors.lSecondaryText;

  /// Semantic colors
  static const successColor = DesignColors.lSuccess;
  static const errorColor = DesignColors.lDanger;
  static const warningColor = DesignColors.lWarning;

  // ==================== TYPOGRAPHY ====================

  /// App bar title
  static const appBarTitle = DesignTypography.headingMedium;

  /// Character name in message card
  static const characterName = DesignTypography.ctaBold;

  /// Main narrative/dialogue text (optimized for reading)
  static const dialogueText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    height: 1.6, // Better line height for long narratives
    fontWeight: FontWeight.w400,
  );

  /// Choice button text
  static const choiceButtonText = DesignTypography.buttonText;

  /// Mood indicator
  static const moodLabel = DesignTypography.playfulTag;

  /// Small helper text
  static const helperText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: DesignColors.lSecondaryText,
  );

  // ==================== SPACING ====================

  /// Card internal padding
  static const cardPadding = EdgeInsets.all(DesignSpacing.md);

  /// Choice button padding
  static const choiceButtonPadding = EdgeInsets.symmetric(
    vertical: DesignSpacing.md,
    horizontal: DesignSpacing.lg,
  );

  /// Spacing between messages
  static const messagePadding = EdgeInsets.symmetric(
    horizontal: DesignSpacing.md,
    vertical: DesignSpacing.sm,
  );

  /// Section spacing
  static const sectionSpacing = SizedBox(height: DesignSpacing.lg);

  /// Small gap
  static const smallGap = SizedBox(height: DesignSpacing.sm);

  // ==================== SHADOWS ====================

  /// Message card shadow
  static const messageCardShadow = DesignShadows.md;

  /// Choice button shadow
  static const choiceButtonShadow = DesignShadows.sm;

  /// Loading overlay shadow
  static const modalShadow = DesignShadows.xl;

  // ==================== BORDER RADIUS ====================

  /// Standard card radius
  static const cardRadius = 12.0;

  /// Button radius
  static const buttonRadius = 12.0;

  /// Avatar radius
  static const avatarRadius = 20.0;

  /// Additional border radii for comprehensive design system
  static const double chipRadius = 4.0;
  static const double badgeRadius = 6.0;
  static const double inputRadius = 8.0;
  static const double pillRadius = 16.0;
  static const double largeCardRadius = 20.0;
  static const double heroCardRadius = 24.0;

  // ==================== ICON SIZES ====================

  static const double iconSizeSmall = 14.0;
  static const double iconSizeRegular = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXL = 64.0;

  // ==================== CARD DIMENSIONS ====================

  static const double characterCardWidth = 320.0;
  static const double characterCardHeight = 480.0;
  static const double storyCardWidth = 360.0;
  static const double storyCardLargeWidth = 400.0;
  static const double storyCardLargeHeight = 500.0;

  // ==================== HOME SCREEN DESIGN TOKENS ====================

  /// Narrator teal color (matching CharacterStyleHelper)
  static const Color narratorTeal = Color(0xFF1A7F8A);

  /// Ilyra purple color (matching CharacterStyleHelper)
  static const Color ilyraExtended = Color(0xFF6B4A9E);

  /// Home screen button dimensions
  static const double homeButtonWidth = 300.0;
  static const double homeButtonHeight = 56.0;
  static const double homeButtonRadius = 16.0;

  /// Home screen title sizing
  static const double homeTitleSizeDesktop = 48.0;
  static const double homeTitleSizeMobile = 40.0;
  static const double homeSubtitleSizeDesktop = 20.0;
  static const double homeSubtitleSizeMobile = 18.0;

  // ==================== MOOD COLORS ====================
  // Visual indicators for character mood

  static Color getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'pleased':
      case 'happy':
      case 'cheerful':
        return DesignColors.lSuccess; // Green

      case 'wary':
      case 'cautious':
      case 'suspicious':
        return DesignColors.lWarning; // Yellow

      case 'angry':
      case 'hostile':
      case 'displeased':
        return DesignColors.lDanger; // Red

      case 'melancholic':
      case 'sad':
      case 'distant':
        return DesignColors.highlightBlue; // Blue

      case 'excited':
      case 'enthusiastic':
        return DesignColors.lSecondary; // Orange

      case 'observant':
      case 'neutral':
      default:
        return DesignColors.lSecondaryText; // Grey
    }
  }

  // ==================== THEME DATA ====================

  /// Complete Material theme for StoryForge
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Color scheme
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: DesignColors.highlightPurple,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
      ),

      // Scaffold
      scaffoldBackgroundColor: backgroundColor,

      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: appBarTitle.copyWith(color: Colors.white),
      ),

      // Card
      // Card
      cardTheme: CardThemeData(  // ✅ CORRECT
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
      ), // CardThemeData

      // Elevated button (for choice buttons)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: choiceButtonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: choiceButtonText,
          elevation: 2,
        ),
      ),

      // Text theme
      textTheme: TextTheme(
        headlineMedium: appBarTitle,
        bodyLarge: dialogueText,
        bodyMedium: dialogueText.copyWith(fontSize: 14),
        labelLarge: choiceButtonText,
      ),
    );
  }

  /// Complete Material dark theme for StoryForge
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: DesignColors.highlightPurple,
        surface: DesignColors.dSurfaces,
        error: DesignColors.dDanger,
        onPrimary: DesignColors.dPrimaryText,
        onSurface: DesignColors.dPrimaryText,
      ),

      // Scaffold
      scaffoldBackgroundColor: DesignColors.dBackground,

      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: DesignColors.dSurfaces,
        foregroundColor: DesignColors.dPrimaryText,
        elevation: 0,
        titleTextStyle: appBarTitle.copyWith(color: DesignColors.dPrimaryText),
      ),

      // Card
      cardTheme: CardThemeData(
        color: DesignColors.dSurfaces,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        shadowColor: Colors.black.withOpacity(0.3),
      ),

      // Elevated button (for choice buttons)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: choiceButtonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: choiceButtonText,
          elevation: 2,
        ),
      ),

      // Text theme
      textTheme: TextTheme(
        headlineMedium: appBarTitle.copyWith(color: DesignColors.dPrimaryText),
        bodyLarge: dialogueText.copyWith(color: DesignColors.dPrimaryText),
        bodyMedium: dialogueText.copyWith(fontSize: 14, color: DesignColors.dPrimaryText),
        labelLarge: choiceButtonText,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: DesignColors.dSurfaces,
        titleTextStyle: TextStyle(
          color: DesignColors.dPrimaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: DesignColors.dSecondaryText,
          fontSize: 14,
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DesignColors.dSurfaces,
        contentTextStyle: TextStyle(color: DesignColors.dPrimaryText),
      ),
    );
  }

  // ==================== THEME-AWARE HELPERS ====================

  /// Get background color based on brightness
  static Color getBackgroundColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? DesignColors.dBackground
        : DesignColors.lBackground;
  }

  /// Get surface color based on brightness
  static Color getSurfaceColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? DesignColors.dSurfaces
        : DesignColors.lSurfaces;
  }

  /// Get primary text color based on brightness
  static Color getPrimaryTextColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? DesignColors.dPrimaryText
        : DesignColors.lPrimaryText;
  }

  /// Get secondary text color based on brightness
  static Color getSecondaryTextColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? DesignColors.dSecondaryText
        : DesignColors.lSecondaryText;
  }

  /// Get danger color based on brightness
  static Color getDangerColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? DesignColors.dDanger
        : DesignColors.lDanger;
  }

  /// Get appropriate shadow for current theme
  static List<BoxShadow> getCardShadow(Brightness brightness) {
    return brightness == Brightness.dark
        ? DesignShadows.darkMd
        : DesignShadows.md;
  }

  /// Get gradient colors based on brightness
  static List<Color> getGradientColors(Brightness brightness) {
    return brightness == Brightness.dark
        ? DesignColors.appGradient
        : [DesignColors.lBackground, DesignColors.lSurfaces, DesignColors.lBackground];
  }
}