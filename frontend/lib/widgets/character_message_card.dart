// lib/widgets/character_message_card.dart
// Light cream/beige message cards
// Portrait visible AROUND cards, not through them
// ⭐ UPDATED FOR PHASE 2.3: Now displays italic actionText above dialogue
// ⭐ UPDATED FOR PHASE 2.4: Character-specific fonts and glows
// ⭐ UPDATED: Fantasia-style dark transparent cards

import 'package:flutter/material.dart';
import '../models/narrative_message.dart';
import '../theme/storyforge_theme.dart';
import '../theme/tokens/spacing.dart';
import 'character_style_helper.dart';

class CharacterMessageCard extends StatelessWidget {
  final NarrativeMessage message;

  const CharacterMessageCard({
    super.key,
    required this.message,
  });

  // Fantasia-style color palette
  static const Color _darkCardBackground = Color(0xFF1A1A1A);     // Dark gray
  static const Color _cardBorder = Color(0xFF2A2A2A);             // Subtle border
  static const Color _textPrimary = Color(0xFFE8E8E8);            // Light text
  static const Color _actionTextGray = Color(0xFFB0B0B0);         // Gray for action text
  static const Color _userCardBackground = Color(0xFFE8EEF5);     // Light blue for user
  static const Color _userTextDark = Color(0xFF1A1A1A);           // Dark text for user
  static const Color _userActionDark = Color(0xFF2A2A2A);         // Dark action for user

  @override
  Widget build(BuildContext context) {
    final isUser = message.speaker == 'user';
    final speakerColor = StoryForgeTheme.getCharacterColor(message.speaker);
    final characterStyle = CharacterStyle.forSpeaker(message.speaker);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Name + Mood
          Row(
            children: [
              // Avatar circle - solid color, clearly visible
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: StoryForgeTheme.avatarRadius,
                  backgroundColor: speakerColor,
                  child: Text(
                    message.speakerName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: DesignSpacing.sm),

              // Character name - dark background pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSpacing.sm,
                  vertical: DesignSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _darkCardBackground.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _cardBorder.withOpacity(0.6),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  message.speakerName,
                  style: StoryForgeTheme.characterName.copyWith(
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              // Mood indicator (skip for user messages)
              if (!isUser && message.mood.isNotEmpty)
                _MoodIndicator(mood: message.mood),
            ],
          ),

          const SizedBox(height: DesignSpacing.sm),

          // ⭐ UPDATED: Message content card - now shows actionText + dialogue
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignSpacing.md),
            decoration: BoxDecoration(
              // Dark semi-transparent for characters, light for user
              color: isUser
                  ? _userCardBackground.withOpacity(0.92)
                  : _darkCardBackground.withOpacity(0.70),
              borderRadius: BorderRadius.circular(
                StoryForgeTheme.cardRadius,
              ),
              // Subtle border
              border: Border.all(
                color: _cardBorder.withOpacity(0.5),
                width: 1,
              ),
              // Soft shadow + character glow
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                // Character-specific glow
                if (!isUser)
                  BoxShadow(
                    color: characterStyle.glowColor,
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                  ),
              ],
            ),
            // ⭐ CHANGED: From single Text to Column for actionText + dialogue
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ⭐ Action text (if present) - Italic, custom font
                if (message.hasActionText && message.actionText != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      message.actionText!,
                      style: TextStyle(
                        fontSize: characterStyle.actionFontSize,
                        fontStyle: FontStyle.italic,
                        color: isUser ? _userActionDark : _actionTextGray,  // ⭐ Safe: Dark for user, light for others
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        fontFamily: characterStyle.fontFamily,
                      ),
                    ),
                  ),

                // Dialogue text - Regular, custom font
                Text(
                  message.dialogue,
                  style: StoryForgeTheme.dialogueText.copyWith(
                    color: isUser ? _userTextDark : _textPrimary,  // ⭐ Safe: Dark for user, light for others
                    fontSize: characterStyle.dialogueFontSize,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                    fontFamily: characterStyle.fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mood indicator with light styling to match cards
class _MoodIndicator extends StatelessWidget {
  final String mood;

  const _MoodIndicator({required this.mood});

  @override
  Widget build(BuildContext context) {
    // Safe mood color retrieval with fallback
    final moodColor = mood.isNotEmpty
        ? StoryForgeTheme.getMoodColor(mood)
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        // Light background with mood color tint
        color: moodColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: moodColor.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Text(
        mood,
        style: StoryForgeTheme.moodLabel.copyWith(
          color: _getSafeShade700(moodColor),  // ⭐ CHANGED: Safe shade
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ⭐ NEW: Safe method to get shade700
  Color _getSafeShade700(Color color) {
    try {
      final hsl = HSLColor.fromColor(color);
      return hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
    } catch (e) {
      return color; // Return original if shade calculation fails
    }
  }
}

// Extension to get darker shade for mood text
extension ColorShade on Color {
  Color get shade700 {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
  }
}