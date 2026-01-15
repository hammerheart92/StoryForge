import 'package:flutter/material.dart';
import '../models/story_info.dart';
import '../models/character_info.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/shadows.dart';
import '../theme/storyforge_theme.dart';

class StoryCard extends StatefulWidget {
  final StoryInfo story;
  final VoidCallback onSelect;

  const StoryCard({
    super.key,
    required this.story,
    required this.onSelect,
  });

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..setEntry(0, 0, _isHovered ? 1.05 : 1.0)
          ..setEntry(1, 1, _isHovered ? 1.05 : 1.0),
        transformAlignment: Alignment.center,
        width: StoryForgeTheme.storyCardLargeWidth,
        height: StoryForgeTheme.storyCardLargeHeight,
        child: Container(
          decoration: BoxDecoration(
            color: DesignColors.dSurfaces,
            borderRadius: BorderRadius.circular(StoryForgeTheme.heroCardRadius),
            border: Border.all(
              color: widget.story.accentColor.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: _isHovered
                ? DesignShadows.glowIntense(widget.story.accentColor)
                : DesignShadows.glowSoft(widget.story.accentColor),
          ),
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            children: [
              _buildStoryIcon(),
              SizedBox(height: DesignSpacing.md),
              Expanded(
                child: _buildStoryInfo(),
              ),
              SizedBox(height: DesignSpacing.md),
              _buildSelectButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.story.accentColor.withValues(alpha: 0.2),
        boxShadow: DesignShadows.glowSoft(widget.story.accentColor),
      ),
      child: Icon(
        widget.story.icon,
        size: 50,
        color: widget.story.accentColor,
      ),
    );
  }

  Widget _buildStoryInfo() {
    final characters = CharacterInfo.forStory(widget.story.id);
    final characterNames = characters.map((c) => c.name).join(' & ');

    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            widget.story.title,
            style: TextStyle(
              fontFamily: 'Merriweather',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: DesignColors.dPrimaryText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DesignSpacing.sm),
          Text(
            widget.story.tagline,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: widget.story.accentColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DesignSpacing.md),
          Text(
            widget.story.description,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              height: 1.5,
              color: DesignColors.dSecondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DesignSpacing.md),
          Container(
            padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.sm),
            decoration: BoxDecoration(
              color: widget.story.accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(StoryForgeTheme.pillRadius),
              border: Border.all(
                color: widget.story.accentColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Text(
              widget.story.theme,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: widget.story.accentColor,
              ),
            ),
          ),
          SizedBox(height: DesignSpacing.sm + 4), // 12
          Text(
            characterNames,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: DesignColors.dSecondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: widget.onSelect,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.story.accentColor,
          foregroundColor: Colors.black,
          elevation: _isHovered ? 8 : 4,
          shadowColor: widget.story.accentColor.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
          ),
        ),
        child: Text(
          'Begin Story',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
