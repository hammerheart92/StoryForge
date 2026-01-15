// lib/widgets/choice_button.dart
// A button representing a choice the user can make

import 'package:flutter/material.dart';
import '../models/choice.dart';
import '../theme/storyforge_theme.dart';
import '../theme/tokens/spacing.dart';

class ChoiceButton extends StatelessWidget {
  final Choice choice;
  final VoidCallback onPressed;
  final bool isLoading;

  const ChoiceButton({
    super.key,
    required this.choice,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = StoryForgeTheme.getCharacterColor(choice.nextSpeaker);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.xs,
      ),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: DesignSpacing.md,
            horizontal: DesignSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              StoryForgeTheme.buttonRadius,
            ),
          ),
          elevation: 2,
          disabledBackgroundColor: buttonColor.withOpacity(0.5),
        ),
        child: Row(
          children: [
            // Icon based on speaker
            Icon(
              _getIconForSpeaker(choice.nextSpeaker),
              size: StoryForgeTheme.iconSizeRegular,
              color: Colors.white,
            ),

            const SizedBox(width: DesignSpacing.sm),

            // Choice label
            Expanded(
              child: Text(
                choice.label,
                style: StoryForgeTheme.choiceButtonText,
              ),
            ),

            // Arrow icon
            Icon(
              Icons.arrow_forward,
              size: StoryForgeTheme.iconSizeRegular,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  /// Get icon based on which character will speak next
  IconData _getIconForSpeaker(String speaker) {
    switch (speaker.toLowerCase()) {
      case 'narrator':
        return Icons.auto_stories; // Book icon for narrator
      case 'ilyra':
        return Icons.stars; // Stars icon for Ilyra (astronomer)
      case 'user':
        return Icons.person;
      default:
        return Icons.chat_bubble_outline;
    }
  }
}