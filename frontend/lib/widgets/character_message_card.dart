// lib/widgets/character_message_card.dart
// Light cream/beige message cards - Fantasia style
// Portrait visible AROUND cards, not through them
// ⭐ UPDATED FOR PHASE 2.3: Now displays italic actionText above dialogue
// ⭐ UPDATED FOR PHASE 2.4: Character-specific fonts and glows

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
  static const Color _creamBackground = Color(0xFFF5F1E8);    // Light cream
  static const Color _cardBorder = Color(0xFFE8E0D0);         // Warm border
  static const Color _textPrimary = Color(0xFF2D2A26);        // Dark brown text
  static const Color _textSecondary = Color(0xFF5C574F);      // Muted brown
  static const Color _actionTextGray = Color(0xFF6B6B6B);     // Gray for action text
  static const Color _userCardBackground = Color(0xFFE8EEF5); // Light blue for user

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final speakerColor = StoryForgeTheme.getCharacterColor(message.speaker);
    final characterStyle = CharacterStyle.forSpeaker(message.speaker);  // ⭐ NEW

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

              // Character name - cream background pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSpacing.sm,
                  vertical: DesignSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _creamBackground.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _cardBorder,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
              if (!isUser)
                _MoodIndicator(mood: message.mood),
            ],
          ),

          const SizedBox(height: DesignSpacing.sm),

          // ⭐ UPDATED: Message content card - now shows actionText + dialogue
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignSpacing.md),
            decoration: BoxDecoration(
              // Light cream/beige - 90% opacity (semi-opaque)
              color: isUser
                  ? _userCardBackground.withOpacity(0.92)
                  : _creamBackground.withOpacity(0.90),
              borderRadius: BorderRadius.circular(
                StoryForgeTheme.cardRadius,
              ),
              // Warm border for definition
              border: Border.all(
                color: isUser
                    ? const Color(0xFFD0D8E8)
                    : _cardBorder,
                width: 1,
              ),
              // Soft shadow for depth + character glow
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
                // ⭐ NEW: Character-specific glow
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
                // ⭐ Action text (if present) - Italic, gray, custom font
                if (message.hasActionText)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      message.actionText!,
                      style: TextStyle(
                        fontSize: characterStyle.actionFontSize,
                        fontStyle: FontStyle.italic,
                        color: _actionTextGray,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        fontFamily: characterStyle.fontFamily,  // ⭐ NEW: Custom font
                      ),
                    ),
                  ),

                // Dialogue text - Regular, custom font
                Text(
                  message.dialogue,
                  style: StoryForgeTheme.dialogueText.copyWith(
                    color: _textPrimary,
                    fontSize: characterStyle.dialogueFontSize,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                    fontFamily: characterStyle.fontFamily,  // ⭐ NEW: Custom font
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
    final moodColor = StoryForgeTheme.getMoodColor(mood);

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
          color: moodColor.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Extension to get darker shade for mood text
extension ColorShade on Color {
  Color get shade700 {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
  }
}