// lib/widgets/save_slot_card.dart
// Widget for displaying individual save slots in the slot selection screen
// Session 29: Multi-Slot Save System

import 'package:flutter/material.dart';
import '../models/story_info.dart';
import '../models/save_info.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/storyforge_theme.dart';

class SaveSlotCard extends StatelessWidget {
  final StoryInfo story;
  final int slotNumber;
  final SaveInfo? save;
  final bool isDark;
  final VoidCallback onContinue;
  final VoidCallback onNewSave;
  final VoidCallback onDelete;

  const SaveSlotCard({
    super.key,
    required this.story,
    required this.slotNumber,
    required this.save,
    required this.isDark,
    required this.onContinue,
    required this.onNewSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = save == null;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
        border: Border.all(
          color: isEmpty
              ? secondaryText.withValues(alpha: 0.3)
              : story.accentColor,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (!isEmpty) ...[
            SizedBox(height: DesignSpacing.sm + 4),
            _buildSaveInfo(),
          ],
          SizedBox(height: DesignSpacing.sm + 4),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs),
          decoration: BoxDecoration(
            color: story.accentColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(StoryForgeTheme.badgeRadius),
          ),
          child: Text(
            'Slot $slotNumber',
            style: TextStyle(
              color: story.accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        SizedBox(width: DesignSpacing.sm),
        if (save != null)
          Expanded(
            child: Text(
              save!.characterName,
              style: TextStyle(
                color: primaryText,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Text(
            '[Empty]',
            style: TextStyle(
              color: secondaryText,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildSaveInfo() {
    if (save == null) return SizedBox.shrink();

    final isCompleted = save!.isCompleted;
    final messageCount = save!.messageCount;
    final timeAgo = _formatTimeAgo(save!.lastPlayed);
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
    final backgroundColor = isDark ? DesignColors.dBackground : DesignColors.lBackground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.message, size: 12, color: secondaryText),
            SizedBox(width: DesignSpacing.xs),
            Text(
              '$messageCount messages',
              style: TextStyle(color: secondaryText, fontSize: 12),
            ),
            SizedBox(width: DesignSpacing.sm + 4),
            Icon(Icons.schedule, size: 12, color: secondaryText),
            SizedBox(width: DesignSpacing.xs),
            Text(
              timeAgo,
              style: TextStyle(color: secondaryText, fontSize: 12),
            ),
          ],
        ),
        SizedBox(height: DesignSpacing.sm),
        if (isCompleted)
          Container(
            padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs),
            decoration: BoxDecoration(
              color: successColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(StoryForgeTheme.inputRadius),
              border: Border.all(color: successColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: successColor, size: StoryForgeTheme.iconSizeSmall),
                SizedBox(width: DesignSpacing.xs),
                Text(
                  'Completed',
                  style: TextStyle(
                    color: successColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (messageCount / 50).clamp(0.0, 1.0),
              backgroundColor: backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(story.accentColor),
              minHeight: 6,
            ),
          ),
      ],
    );
  }

  Widget _buildActions() {
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    if (save == null) {
      // Empty slot - show "New Save" button
      return SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton.icon(
          onPressed: onNewSave,
          icon: Icon(Icons.add, size: 18),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('New Save'),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: story.accentColor,
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.sm),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(StoryForgeTheme.inputRadius),
            ),
          ),
        ),
      );
    }

    // Existing save - show "Continue" and "Delete" buttons
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onContinue,
              icon: Icon(
                save!.isCompleted ? Icons.replay : Icons.play_arrow,
                size: 18,
              ),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(save!.isCompleted ? 'Play Again' : 'Continue'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: story.accentColor,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm + 4, vertical: DesignSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(StoryForgeTheme.inputRadius),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: DesignSpacing.sm),
        SizedBox(
          height: 44,
          width: 44,
          child: IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline),
            color: dangerColor,
            style: IconButton.styleFrom(
              backgroundColor: dangerColor.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(StoryForgeTheme.inputRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
