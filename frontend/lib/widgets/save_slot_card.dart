// lib/widgets/save_slot_card.dart
// Widget for displaying individual save slots in the slot selection screen
// Session 29: Multi-Slot Save System

import 'package:flutter/material.dart';
import '../models/story_info.dart';
import '../models/save_info.dart';
import '../theme/tokens/colors.dart';

class SaveSlotCard extends StatelessWidget {
  final StoryInfo story;
  final int slotNumber;
  final SaveInfo? save;
  final VoidCallback onContinue;
  final VoidCallback onNewSave;
  final VoidCallback onDelete;

  const SaveSlotCard({
    super.key,
    required this.story,
    required this.slotNumber,
    required this.save,
    required this.onContinue,
    required this.onNewSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = save == null;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignColors.dSurfaces,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEmpty
              ? DesignColors.dSecondaryText.withValues(alpha: 0.3)
              : story.accentColor,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (!isEmpty) ...[
            SizedBox(height: 12),
            _buildSaveInfo(),
          ],
          SizedBox(height: 12),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: story.accentColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
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
        SizedBox(width: 8),
        if (save != null)
          Expanded(
            child: Text(
              save!.characterName,
              style: TextStyle(
                color: DesignColors.dPrimaryText,
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
              color: DesignColors.dSecondaryText,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.message, size: 12, color: DesignColors.dSecondaryText),
            SizedBox(width: 4),
            Text(
              '$messageCount messages',
              style: TextStyle(color: DesignColors.dSecondaryText, fontSize: 12),
            ),
            SizedBox(width: 12),
            Icon(Icons.schedule, size: 12, color: DesignColors.dSecondaryText),
            SizedBox(width: 4),
            Text(
              timeAgo,
              style: TextStyle(color: DesignColors.dSecondaryText, fontSize: 12),
            ),
          ],
        ),
        SizedBox(height: 8),
        if (isCompleted)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DesignColors.dSuccess.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: DesignColors.dSuccess),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: DesignColors.dSuccess, size: 14),
                SizedBox(width: 4),
                Text(
                  'Completed',
                  style: TextStyle(
                    color: DesignColors.dSuccess,
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
              backgroundColor: DesignColors.dBackground,
              valueColor: AlwaysStoppedAnimation<Color>(story.accentColor),
              minHeight: 6,
            ),
          ),
      ],
    );
  }

  Widget _buildActions() {
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
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
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          height: 44,
          width: 44,
          child: IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline),
            color: DesignColors.dDanger,
            style: IconButton.styleFrom(
              backgroundColor: DesignColors.dDanger.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
