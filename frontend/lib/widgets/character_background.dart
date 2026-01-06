import 'package:flutter/material.dart';

/// Displays character portrait or scene as background - SHARP and VISIBLE
///
/// ⭐ SESSION 24: Enhanced with mood-based scene system
/// - Pirates characters use dynamic scenes that change with mood
/// - Existing characters (Narrator, Ilyra, Illidan, Tyrande) keep static portraits
/// - Smooth transitions between scenes (500ms crossfade)
/// - Fallback to default scene if mood-specific scene not found
class CharacterBackground extends StatelessWidget {
  final String speaker;
  final String? mood; // ⭐ NEW: Optional mood for scene selection
  final Duration transitionDuration;

  const CharacterBackground({
    super.key,
    required this.speaker,
    this.mood,
    this.transitionDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: transitionDuration,
      child: _buildBackgroundStack(),
    );
  }

  Widget _buildBackgroundStack() {
    // ⭐ Key now includes mood so AnimatedSwitcher triggers on mood change
    final key = mood != null ? '$speaker-$mood' : speaker;

    return Stack(
      key: ValueKey(key),
      fit: StackFit.expand,
      children: [
        // 1. Character portrait/scene - SHARP, NO BLUR!
        _buildSharpPortrait(),

        // 2. Dark vignette around edges (NOT over the portrait!)
        _buildEdgeVignette(),
      ],
    );
  }

  /// Portrait image - positioned at top, SHARP and VISIBLE
  Widget _buildSharpPortrait() {
    final imagePath = _getCharacterImagePath(speaker, mood);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter, // Keep face visible at top
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: _getFallbackColor(speaker),
          );
        },
      ),
    );
  }

  /// Dark vignette around edges - creates depth without obscuring portrait
  Widget _buildEdgeVignette() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              Colors.transparent,           // Clear in center (portrait visible!)
              Colors.black.withOpacity(0.3), // Subtle darkening
              Colors.black.withOpacity(0.6), // Darker at edges
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }

  /// ⭐ NEW: Get image path with mood-based scene selection for pirates
  String _getCharacterImagePath(String speaker, String? mood) {
    final speakerLower = speaker.toLowerCase();

    // Pirates characters use dynamic scenes based on mood
    if (speakerLower == 'blackwood' || speakerLower == 'isla') {
      return _getPirateScenePath(speakerLower, mood);
    }

    // Existing characters use static portraits
    switch (speaker.toLowerCase()) {
      case 'narrator':
        return 'assets/images/characters/narrator_portrait.webp';
      case 'ilyra':
        return 'assets/images/characters/ilyra_portrait.webp';
      case 'illidan':  // ⭐ NEW
        return 'assets/images/characters/illidan.png';
      case 'tyrande':  // ⭐ NEW
        return 'assets/images/characters/tyrande.png';
      default:
        return 'assets/images/characters/narrator_portrait.webp';
    }
  }

  /// ⭐ NEW: Map pirate character + mood to scene path
  String _getPirateScenePath(String character, String? mood) {
    // Mood-to-scene mapping for pirates
    final sceneMap = _getPirateSceneMap(character);

    // Try to get mood-specific scene, fallback to default
    final moodLower = mood?.toLowerCase() ?? 'default';
    return sceneMap[moodLower] ?? sceneMap['default']!;
  }

  /// ⭐ NEW: Scene mapping tables for each pirate character
  Map<String, String> _getPirateSceneMap(String character) {
    switch (character) {
      case 'blackwood':
        return {
          // Dramatic moods
          'defiant': 'assets/images/scenes/pirates/pirate_ship_deck.png',
          'frustrated': 'assets/images/scenes/pirates/pirate_ship_deck.png',
          'angry': 'assets/images/scenes/pirates/pirate_ship_deck.png',

          // Romantic/contemplative moods
          'charming': 'assets/images/scenes/pirates/pirate_captains_cabin.png',
          'contemplative': 'assets/images/scenes/pirates/pirate_captains_cabin.png',
          'longing': 'assets/images/scenes/pirates/pirate_captains_cabin.png',
          'melancholic': 'assets/images/scenes/pirates/pirate_captains_cabin.png',

          // Default fallback
          'default': 'assets/images/scenes/pirates/pirate_captains_cabin.png',
        };

      case 'isla':
        return {
          // Professional/analytical moods
          'analytical': 'assets/images/scenes/pirates/pirate_ship_navigation_room.png',
          'focused': 'assets/images/scenes/pirates/pirate_ship_navigation_room.png',
          'wary': 'assets/images/scenes/pirates/pirate_ship_navigation_room.png',
          'uncomfortable': 'assets/images/scenes/pirates/pirate_ship_navigation_room.png',
          'firm': 'assets/images/scenes/pirates/pirate_ship_navigation_room.png',

          // Default fallback
          'default': 'assets/images/scenes/pirates/pirate_ship_navigation_room.png',
        };

      default:
      // Fallback for unknown pirates
        return {
          'default': 'assets/images/scenes/pirates/pirate_ship_deck.png',
        };
    }
  }

  Color _getFallbackColor(String speaker) {
    switch (speaker.toLowerCase()) {
      case 'narrator':
        return const Color(0xFF1A4D5C);
      case 'ilyra':
        return const Color(0xFF4A1A5C);
      case 'illidan':
        return const Color(0xFF1A3D1A);  // Dark fel green
      case 'tyrande':
        return const Color(0xFF3D3D4D);  // Dark silver/blue
      case 'blackwood':  // ⭐ NEW
        return const Color(0xFF1A2A3A);  // Dark ocean blue
      case 'isla':  // ⭐ NEW
        return const Color(0xFF3A2A1A);  // Warm brown (navigation room)
      default:
        return const Color(0xFF1A1A1A);
    }
  }
}