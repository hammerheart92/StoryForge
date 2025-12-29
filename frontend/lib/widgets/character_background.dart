import 'package:flutter/material.dart';

/// Displays character portrait as background - SHARP and VISIBLE like Fantasia
///
/// Key differences from previous approach:
/// - NO BackdropFilter blur (portraits are sharp!)
/// - Portrait positioned at top 40-50% of screen
/// - Dark vignette around edges only
/// - Face area kept clear and visible
class CharacterBackground extends StatelessWidget {
  final String speaker;
  final Duration transitionDuration;

  const CharacterBackground({
    super.key,
    required this.speaker,
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
    return Stack(
      key: ValueKey(speaker),
      fit: StackFit.expand,
      children: [
        // 1. Character portrait - SHARP, NO BLUR!
        _buildSharpPortrait(),

        // 2. Dark vignette around edges (NOT over the portrait!)
        _buildEdgeVignette(),
      ],
    );
  }

  /// Portrait image - positioned at top, SHARP and VISIBLE
  Widget _buildSharpPortrait() {
    final imagePath = _getCharacterImagePath(speaker);

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

  String _getCharacterImagePath(String speaker) {
    switch (speaker.toLowerCase()) {
      case 'narrator':
        return 'assets/images/characters/narrator_portrait.webp';
      case 'ilyra':
        return 'assets/images/characters/ilyra_portrait.webp';
      default:
        return 'assets/images/characters/narrator_portrait.webp';
    }
  }

  Color _getFallbackColor(String speaker) {
    switch (speaker.toLowerCase()) {
      case 'narrator':
        return const Color(0xFF1A4D5C);
      case 'ilyra':
        return const Color(0xFF4A1A5C);
      default:
        return const Color(0xFF1A1A1A);
    }
  }
}