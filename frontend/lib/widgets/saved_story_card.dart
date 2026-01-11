// lib/widgets/saved_story_card.dart
// Card widget for displaying story with save progress in Story Library

import 'package:flutter/material.dart';
import '../models/story_info.dart';
import '../models/save_info.dart';
import '../theme/tokens/colors.dart';

class SavedStoryCard extends StatefulWidget {
  final StoryInfo story;
  final SaveInfo? save;
  final VoidCallback onContinue;
  final VoidCallback onNewGame;
  final VoidCallback? onDelete;

  const SavedStoryCard({
    super.key,
    required this.story,
    this.save,
    required this.onContinue,
    required this.onNewGame,
    this.onDelete,
  });

  @override
  State<SavedStoryCard> createState() => _SavedStoryCardState();
}

class _SavedStoryCardState extends State<SavedStoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasSave = widget.save != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onLongPress: hasSave && widget.onDelete != null
            ? () => _showDeleteDialog(context)
            : null,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..setEntry(0, 0, _isHovered ? 1.02 : 1.0)
            ..setEntry(1, 1, _isHovered ? 1.02 : 1.0),
          transformAlignment: Alignment.center,
          width: 360,
          child: Container(
            decoration: BoxDecoration(
              color: DesignColors.dSurfaces,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.story.accentColor.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.story.accentColor
                      .withValues(alpha: _isHovered ? 0.3 : 0.15),
                  blurRadius: _isHovered ? 24 : 16,
                  spreadRadius: _isHovered ? 2 : 0,
                ),
              ],
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                SizedBox(height: 16),
                _buildStoryInfo(),
                if (hasSave) ...[
                  SizedBox(height: 16),
                  _buildProgress(),
                ],
                SizedBox(height: 20),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.story.accentColor.withValues(alpha: 0.2),
            boxShadow: [
              BoxShadow(
                color: widget.story.accentColor.withValues(alpha: 0.4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(
            widget.story.icon,
            size: 28,
            color: widget.story.accentColor,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.story.title,
                style: TextStyle(
                  fontFamily: 'Merriweather',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DesignColors.dPrimaryText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.story.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.story.theme,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: widget.story.accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.save?.isCompleted == true)
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DesignColors.dSuccess.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.check_circle,
              size: 20,
              color: DesignColors.dSuccess,
            ),
          ),
      ],
    );
  }

  Widget _buildStoryInfo() {
    return Text(
      widget.story.tagline,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 13,
        fontStyle: FontStyle.italic,
        color: DesignColors.dSecondaryText,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildProgress() {
    final save = widget.save!;
    final isCompleted = save.isCompleted;

    // Character info row (same for both states)
    final characterRow = Row(
      children: [
        Icon(
          Icons.person,
          size: 14,
          color: widget.story.accentColor,
        ),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            save.characterName,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: DesignColors.dPrimaryText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          _formatTimeAgo(save.lastPlayed),
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 11,
            color: DesignColors.dSecondaryText,
          ),
        ),
      ],
    );

    if (isCompleted) {
      // COMPLETED: Show badge instead of progress bar
      return Column(
        children: [
          characterRow,
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: DesignColors.dSuccess.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DesignColors.dSuccess),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: DesignColors.dSuccess, size: 16),
                SizedBox(width: 4),
                Text(
                  'Completed',
                  style: TextStyle(
                    color: DesignColors.dSuccess,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${save.messageCount} messages',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 10,
              color: DesignColors.dSecondaryText,
            ),
          ),
        ],
      );
    }

    // IN PROGRESS: Show progress bar
    final progress = (save.messageCount / 50).clamp(0.0, 1.0);
    return Column(
      children: [
        characterRow,
        SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: DesignColors.dBackground,
            valueColor: AlwaysStoppedAnimation<Color>(widget.story.accentColor),
            minHeight: 6,
          ),
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${save.messageCount} messages',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 10,
                color: DesignColors.dSecondaryText,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: widget.story.accentColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtons() {
    final hasSave = widget.save != null;
    final isCompleted = widget.save?.isCompleted == true;

    if (!hasSave) {
      // No save - only show "Start Story" button
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: widget.onNewGame,
          icon: Icon(Icons.play_arrow, size: 20),
          label: Text(
            'Start Story',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.story.accentColor,
            foregroundColor: Colors.black,
            elevation: _isHovered ? 6 : 3,
            shadowColor: widget.story.accentColor.withValues(alpha: 0.5),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }

    // Has save - show Continue and New Game buttons
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: widget.onContinue,
              icon: Icon(isCompleted ? Icons.replay : Icons.play_arrow, size: 18),
              label: Text(
                isCompleted ? 'Play Again' : 'Continue',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.story.accentColor,
                foregroundColor: Colors.black,
                elevation: _isHovered ? 6 : 3,
                shadowColor: widget.story.accentColor.withValues(alpha: 0.5),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: widget.onNewGame,
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignColors.dSecondaryText,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                side: BorderSide(
                  color: DesignColors.dSecondaryText.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'New',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignColors.dSurfaces,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Save?',
          style: TextStyle(
            color: DesignColors.dPrimaryText,
            fontFamily: 'Merriweather',
          ),
        ),
        content: Text(
          'Your progress in "${widget.story.title}" will be permanently deleted.',
          style: TextStyle(
            color: DesignColors.dSecondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: DesignColors.dSecondaryText),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete?.call();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: DesignColors.dDanger),
            ),
          ),
        ],
      ),
    );
  }
}
