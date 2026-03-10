// lib/widgets/narrative_suggestion_chip.dart
// SESSION_45: Tappable suggestion chip that fills the input field

import 'package:flutter/material.dart';
import '../theme/storyforge_theme.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/typography.dart';

class NarrativeSuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const NarrativeSuggestionChip({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: DesignColors.dSurfaces,
          border: Border.all(
            color: DesignColors.highlightTeal,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
        ),
        child: Row(
          children: [
            Icon(
              Icons.edit_rounded,
              size: 18,
              color: DesignColors.highlightTeal,
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: DesignTypography.bodyRegular.copyWith(
                  color: DesignColors.highlightTeal,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
