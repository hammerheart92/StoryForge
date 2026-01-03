import 'package:flutter/material.dart';
import '../models/story_info.dart';
import '../models/character_info.dart';

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
        width: 400,
        height: 500,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF23272C),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.story.accentColor.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.story.accentColor
                    .withValues(alpha: _isHovered ? 0.4 : 0.2),
                blurRadius: _isHovered ? 30 : 20,
                spreadRadius: _isHovered ? 3 : 1,
              ),
              BoxShadow(
                color: widget.story.accentColor
                    .withValues(alpha: _isHovered ? 0.3 : 0.1),
                blurRadius: _isHovered ? 50 : 40,
                spreadRadius: _isHovered ? 5 : 2,
              ),
            ],
          ),
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              _buildStoryIcon(),
              SizedBox(height: 16),
              Expanded(
                child: _buildStoryInfo(),
              ),
              SizedBox(height: 16),
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
        boxShadow: [
          BoxShadow(
            color: widget.story.accentColor.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
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
              color: Color(0xFFF1F3F5),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
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
          SizedBox(height: 16),
          Text(
            widget.story.description,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              height: 1.5,
              color: Color(0xFFB0B3B8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.story.accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
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
          SizedBox(height: 12),
          Text(
            characterNames,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: Color(0xFFB0B3B8),
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
            borderRadius: BorderRadius.circular(12),
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
