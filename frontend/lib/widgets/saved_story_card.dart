// lib/widgets/saved_story_card.dart
// Card widget for displaying story with save progress in Story Library

import 'package:flutter/material.dart';
import '../models/story_info.dart';
import '../models/save_info.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/shadows.dart';
import '../theme/storyforge_theme.dart';

class SavedStoryCard extends StatefulWidget {
  final StoryInfo story;
  final SaveInfo? save;
  final bool isDark;
  final VoidCallback onContinue;
  final VoidCallback onNewGame;
  final VoidCallback? onDelete;
  final VoidCallback? onGallery;  // Phase B: Gallery navigation
  final VoidCallback? onViewEndings;  // Session 34: View endings navigation

  const SavedStoryCard({
    super.key,
    required this.story,
    this.save,
    required this.isDark,
    required this.onContinue,
    required this.onNewGame,
    this.onDelete,
    this.onGallery,
    this.onViewEndings,
  });

  @override
  State<SavedStoryCard> createState() => _SavedStoryCardState();
}

class _SavedStoryCardState extends State<SavedStoryCard> {
  bool _isHovered = false;

  bool get isDark => widget.isDark;

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
          width: StoryForgeTheme.storyCardWidth,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
              borderRadius: BorderRadius.circular(StoryForgeTheme.largeCardRadius),
              border: Border.all(
                color: widget.story.accentColor.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: _isHovered
                  ? DesignShadows.glowIntense(widget.story.accentColor)
                  : DesignShadows.glowSoft(widget.story.accentColor),
            ),
            padding: EdgeInsets.all(20), // Non-standard spacing (20px)
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                SizedBox(height: DesignSpacing.md),
                _buildStoryInfo(),
                if (hasSave) ...[
                  SizedBox(height: DesignSpacing.md),
                  _buildProgress(),
                ],
                SizedBox(height: 20), // Non-standard spacing (20px)
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.story.accentColor.withValues(alpha: 0.2),
            boxShadow: DesignShadows.glowSoft(widget.story.accentColor),
          ),
          child: Icon(
            widget.story.icon,
            size: 28,
            color: widget.story.accentColor,
          ),
        ),
        SizedBox(width: DesignSpacing.md),
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
                  color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: DesignSpacing.xs),
              Container(
                padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.story.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(StoryForgeTheme.inputRadius),
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
        // Phase B: Gallery icon button
        if (widget.onGallery != null)
          Padding(
            padding: EdgeInsets.only(right: DesignSpacing.xs),
            child: IconButton(
              icon: Icon(Icons.photo_library, size: StoryForgeTheme.iconSizeRegular),
              color: widget.story.accentColor.withValues(alpha: 0.7),
              tooltip: 'Gallery',
              onPressed: widget.onGallery,
              constraints: BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.all(6),
            ),
          ),
        // Session 34: View endings icon button
        if (widget.save != null && widget.onViewEndings != null)
          Padding(
            padding: EdgeInsets.only(right: DesignSpacing.xs),
            child: IconButton(
              icon: Icon(Icons.emoji_events, size: StoryForgeTheme.iconSizeRegular),
              color: successColor.withValues(alpha: 0.7),
              tooltip: 'View Endings',
              onPressed: widget.onViewEndings,
              constraints: BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.all(6),
            ),
          ),
        if (widget.save?.isCompleted == true)
          Container(
            padding: EdgeInsets.all(6), // Non-standard badge padding
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: successColor.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.check_circle,
              size: StoryForgeTheme.iconSizeRegular,
              color: successColor,
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
        color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildProgress() {
    final save = widget.save!;
    final isCompleted = save.isCompleted;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    // Character info row (same for both states)
    final characterRow = Row(
      children: [
        Icon(
          Icons.person,
          size: StoryForgeTheme.iconSizeSmall,
          color: widget.story.accentColor,
        ),
        SizedBox(width: DesignSpacing.xs + 2), // 6
        Expanded(
          child: Text(
            save.characterName,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: primaryText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          _formatTimeAgo(save.lastPlayed),
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 11,
            color: secondaryText,
          ),
        ),
      ],
    );

    if (isCompleted) {
      // COMPLETED: Show badge instead of progress bar
      return Column(
        children: [
          characterRow,
          SizedBox(height: DesignSpacing.sm + 2), // 10
          Container(
            padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm + 4, vertical: DesignSpacing.xs + 2), // 12, 6
            decoration: BoxDecoration(
              color: successColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
              border: Border.all(color: successColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: successColor, size: 16), // Non-standard icon size
                SizedBox(width: DesignSpacing.xs),
                Text(
                  'Completed',
                  style: TextStyle(
                    color: successColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: DesignSpacing.xs),
          Text(
            '${save.messageCount} messages',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 10,
              color: secondaryText,
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
        SizedBox(height: DesignSpacing.sm + 2), // 10
        ClipRRect(
          borderRadius: BorderRadius.circular(StoryForgeTheme.chipRadius),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? DesignColors.dBackground : DesignColors.lBackground,
            valueColor: AlwaysStoppedAnimation<Color>(widget.story.accentColor),
            minHeight: 6,
          ),
        ),
        SizedBox(height: DesignSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${save.messageCount} messages',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 10,
                color: secondaryText,
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
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    if (!hasSave) {
      // No save - only show "Start Story" button
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: widget.onNewGame,
          icon: Icon(Icons.play_arrow, size: StoryForgeTheme.iconSizeRegular),
          label: Text(
            'Start Story',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.story.accentColor,
            foregroundColor: Colors.black,
            elevation: _isHovered ? 6 : 3,
            shadowColor: widget.story.accentColor.withValues(alpha: 0.5),
            padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.sm + 4), // 16, 12
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
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
              icon: Icon(isCompleted ? Icons.replay : Icons.play_arrow, size: 18), // Non-standard icon size
              label: Text(
                isCompleted ? 'Play Again' : 'Continue',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.story.accentColor,
                foregroundColor: Colors.black,
                elevation: _isHovered ? 6 : 3,
                shadowColor: widget.story.accentColor.withValues(alpha: 0.5),
                padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm + 4, vertical: DesignSpacing.sm + 4), // 12, 12
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: DesignSpacing.sm + 2), // 10
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: widget.onNewGame,
              style: OutlinedButton.styleFrom(
                foregroundColor: secondaryText,
                padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm + 4, vertical: DesignSpacing.sm + 4), // 12, 12
                side: BorderSide(
                  color: secondaryText.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
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
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StoryForgeTheme.pillRadius),
        ),
        title: Text(
          'Delete Save?',
          style: TextStyle(
            color: primaryText,
            fontFamily: 'Merriweather',
          ),
        ),
        content: Text(
          'Your progress in "${widget.story.title}" will be permanently deleted.',
          style: TextStyle(
            color: secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: secondaryText),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete?.call();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: dangerColor),
            ),
          ),
        ],
      ),
    );
  }
}
