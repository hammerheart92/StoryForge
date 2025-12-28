// lib/widgets/character_message_card.dart
// Displays a single message from a character or user in the conversation

import 'package:flutter/material.dart';
import '../models/narrative_message.dart';
import '../theme/storyforge_theme.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/shadows.dart';

class CharacterMessageCard extends StatelessWidget {
  final NarrativeMessage message;

  const CharacterMessageCard({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final speakerColor = StoryForgeTheme.getCharacterColor(message.speaker);

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
              // Avatar circle
              CircleAvatar(
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

              const SizedBox(width: DesignSpacing.sm),

              // Character name
              Text(
                message.speakerName,
                style: StoryForgeTheme.characterName.copyWith(
                  color: StoryForgeTheme.primaryText,
                ),
              ),

              const Spacer(),

              // Mood indicator (skip for user messages)
              if (!isUser)
                _MoodIndicator(mood: message.mood),
            ],
          ),

          const SizedBox(height: DesignSpacing.sm),

          // Message content card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignSpacing.md),
            decoration: BoxDecoration(
              color: isUser
                  ? Colors.blue.shade50
                  : Colors.white,
              borderRadius: BorderRadius.circular(
                StoryForgeTheme.cardRadius,
              ),
              boxShadow: StoryForgeTheme.messageCardShadow,
            ),
            child: Text(
              message.dialogue,
              style: StoryForgeTheme.dialogueText.copyWith(
                color: StoryForgeTheme.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small mood indicator badge
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
        color: moodColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: moodColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        mood,
        style: StoryForgeTheme.moodLabel.copyWith(
          color: moodColor,
          fontSize: 12,
        ),
      ),
    );
  }
}