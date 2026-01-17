import 'package:flutter/material.dart';
import '../models/story_ending.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/shadows.dart';
import '../theme/storyforge_theme.dart';

/// Dialog shown when player completes a story
class StoryCompletionDialog extends StatelessWidget {
  final StoryEnding ending;
  final int gemsAwarded;
  final String? achievementUnlocked;
  final VoidCallback onViewEndings;
  final VoidCallback onContinue;

  const StoryCompletionDialog({
    super.key,
    required this.ending,
    this.gemsAwarded = 100,
    this.achievementUnlocked,
    required this.onViewEndings,
    required this.onContinue,
  });

  /// Show the dialog and return user choice
  /// Returns 'view_endings' or 'continue'
  static Future<String?> show({
    required BuildContext context,
    required StoryEnding ending,
    int gemsAwarded = 100,
    String? achievementUnlocked,
  }) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StoryCompletionDialog(
        ending: ending,
        gemsAwarded: gemsAwarded,
        achievementUnlocked: achievementUnlocked,
        onViewEndings: () => Navigator.pop(context, 'view_endings'),
        onContinue: () => Navigator.pop(context, 'continue'),
      ),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DesignColors.dSurfaces,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StoryForgeTheme.largeCardRadius),
      ),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: 320,
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTrophyIcon(),
            SizedBox(height: DesignSpacing.md),
            _buildTitle(),
            SizedBox(height: DesignSpacing.lg),
            _buildEndingInfo(),
            SizedBox(height: DesignSpacing.lg),
            _buildRewardBadge(),
            if (achievementUnlocked != null) ...[
              SizedBox(height: DesignSpacing.sm + 4),
              _buildAchievementBadge(),
            ],
            SizedBox(height: DesignSpacing.lg),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophyIcon() {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: DesignColors.dSuccess.withValues(alpha: 0.2),
        boxShadow: DesignShadows.glowSoft(DesignColors.dSuccess),
      ),
      child: Icon(
        Icons.emoji_events,
        size: StoryForgeTheme.iconSizeLarge + 16,
        color: DesignColors.dSuccess,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Story Complete!',
      style: TextStyle(
        fontFamily: 'Merriweather',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: DesignColors.dPrimaryText,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEndingInfo() {
    return Column(
      children: [
        Text(
          ending.title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DesignColors.highlightTeal,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignSpacing.sm),
        Text(
          ending.description,
          style: TextStyle(
            fontSize: 14,
            color: DesignColors.dSecondaryText,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRewardBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: DesignColors.rarityEpic.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
        border: Border.all(color: DesignColors.rarityEpic),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.diamond, size: 20, color: DesignColors.rarityEpic),
          SizedBox(width: DesignSpacing.sm),
          Text(
            '+$gemsAwarded Gems',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: DesignColors.rarityEpic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm + 4,
        vertical: DesignSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: DesignColors.highlightPurple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 16, color: DesignColors.highlightPurple),
          SizedBox(width: DesignSpacing.xs),
          Text(
            'Achievement Unlocked!',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: DesignColors.highlightPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onViewEndings,
            icon: Icon(Icons.list_alt, size: 18),
            label: Text('View Endings'),
            style: OutlinedButton.styleFrom(
              foregroundColor: DesignColors.dSecondaryText,
              side: BorderSide(
                color: DesignColors.dSecondaryText.withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
              ),
              padding: EdgeInsets.symmetric(vertical: DesignSpacing.sm + 4),
            ),
          ),
        ),
        SizedBox(width: DesignSpacing.sm + 4),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onContinue,
            icon: Icon(Icons.library_books, size: 18),
            label: Text('Continue'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.highlightTeal,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
              ),
              padding: EdgeInsets.symmetric(vertical: DesignSpacing.sm + 4),
            ),
          ),
        ),
      ],
    );
  }
}
