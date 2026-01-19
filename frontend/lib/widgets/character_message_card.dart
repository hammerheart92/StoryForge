// lib/widgets/character_message_card.dart
// Light cream/beige message cards
// Portrait visible AROUND cards, not through them
// ⭐ UPDATED FOR PHASE 2.3: Now displays italic actionText above dialogue
// ⭐ UPDATED FOR PHASE 2.4: Character-specific fonts and glows
// ⭐ UPDATED FOR PHASE 2.5: Smooth fade-in animations
// ⭐ UPDATED: Fantasia-style dark transparent cards
// ⭐ UPDATED FOR PHASE 2.6: Typewriter effect - text types character by character

import 'package:flutter/material.dart';
import '../models/narrative_message.dart';
import '../services/settings_service.dart';
import '../theme/storyforge_theme.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/shadows.dart';
import 'character_style_helper.dart';
import 'typewriter_text.dart';

class CharacterMessageCard extends StatefulWidget {
  final NarrativeMessage message;
  final bool shouldAnimate;  // Control animation
  final VoidCallback? onContentExpanding;  // Called when typewriter expands content

  const CharacterMessageCard({
    super.key,
    required this.message,
    this.shouldAnimate = true,  // Default to true
    this.onContentExpanding,
  });

  @override
  State<CharacterMessageCard> createState() => _CharacterMessageCardState();
}

class _CharacterMessageCardState extends State<CharacterMessageCard> {
  // ⭐ PHASE 2.6: Typewriter effect state
  bool _showDialogue = false;

  // ⭐ PHASE 4: User settings state
  int _animationSpeed = 20;      // Default: 20ms per character
  double _textSize = 16.0;       // Default: Medium (16px)

  // Fantasia-style color palette
  static const Color _darkCardBackground = Color(0xFF1A1A1A);     // Dark gray (darker than dSurfaces for contrast)
  static const Color _cardBorder = Color(0xFF2A2A2A);             // Subtle border
  static final Color _textPrimary = DesignColors.dPrimaryText;    // Light text
  static final Color _actionTextGray = DesignColors.dSecondaryText; // Gray for action text
  static final Color _userCardBackground = DesignColors.lSurfaces; // Light blue for user
  static final Color _userTextDark = DesignColors.lPrimaryText;    // Dark text for user
  static final Color _userActionDark = DesignColors.lSecondaryText; // Dark action for user

  // Typewriter timing constant (pause between action and dialogue)
  static const int _pauseBetweenMs = 150;

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // If no action text, show dialogue immediately
    if (!widget.message.hasActionText || !widget.shouldAnimate) {
      _showDialogue = true;
    }
  }

  /// Load user settings for animation speed and text size
  Future<void> _loadSettings() async {
    try {
      final settings = await SettingsService.loadSettings();
      if (mounted) {
        setState(() {
          _animationSpeed = settings.animationSpeed;
          _textSize = settings.textSize.pixels;

          // ⭐ PHASE 4: If instant mode (0ms), show dialogue immediately
          // (no animation callback to trigger it)
          if (settings.animationSpeed == 0 && widget.message.hasActionText) {
            _showDialogue = true;
          }
        });
      }
    } catch (e) {
      // Use defaults on error - values already initialized
    }
  }

  /// Check if animation should be skipped (0ms = instant)
  bool get _isInstantMode => _animationSpeed == 0;

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.speaker == 'user';
    final speakerColor = StoryForgeTheme.getCharacterColor(widget.message.speaker);
    final characterStyle = CharacterStyle.forSpeaker(widget.message.speaker);

    // ⭐ PHASE 2.6: Card appears instantly, text types out
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
                  // Avatar circle - solid color, clearly visible
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: DesignShadows.sm,
                    ),
                    child: CircleAvatar(
                      radius: StoryForgeTheme.avatarRadius,
                      backgroundColor: speakerColor,
                      child: Text(
                        widget.message.speakerName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: DesignSpacing.sm),

                  // Character name - dark background pill
                  Flexible(  // Wrapper for long names
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignSpacing.sm,
                        vertical: DesignSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _darkCardBackground.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(StoryForgeTheme.inputRadius),
                        border: Border.all(
                          color: _cardBorder.withOpacity(0.6),
                          width: 1,
                        ),
                        boxShadow: DesignShadows.sm,
                      ),
                      child: Text(
                        widget.message.speakerName,
                        overflow: TextOverflow.ellipsis,  // ⭐ ADDED: Handles overflow
                        style: StoryForgeTheme.characterName.copyWith(
                          color: _textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Mood indicator (skip for user messages)
                  if (!isUser && widget.message.mood.isNotEmpty)
                    _MoodIndicator(mood: widget.message.mood),
                ],
              ),

              const SizedBox(height: DesignSpacing.sm),

              // Message content card - shows actionText + dialogue
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DesignSpacing.md),
                decoration: BoxDecoration(
                  // Dark semi-transparent for characters, light for user
                  color: isUser
                      ? _userCardBackground.withOpacity(0.92)
                      : _darkCardBackground.withOpacity(0.70),
                  borderRadius: BorderRadius.circular(
                    StoryForgeTheme.cardRadius,
                  ),
                  // Subtle border
                  border: Border.all(
                    color: _cardBorder.withOpacity(0.5),
                    width: 1,
                  ),
                  // Soft shadow + character glow
                  boxShadow: [
                    ...DesignShadows.md,
                    // Character-specific glow
                    if (!isUser)
                      BoxShadow(
                        color: characterStyle.glowColor,
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                      ),
                  ],
                ),
                // ⭐ PHASE 2.6: Typewriter effect for text content
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ⭐ Action text (if present) - Italic, custom font, types first
                    // ⭐ PHASE 4: Uses user's text size setting
                    if (widget.message.hasActionText && widget.message.actionText != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: DesignSpacing.sm + 4), // 12
                        child: (widget.shouldAnimate && !_isInstantMode)
                            ? TypewriterText(
                                text: widget.message.actionText!,
                                style: TextStyle(
                                  fontSize: _textSize,  // ⭐ User setting
                                  fontStyle: FontStyle.italic,
                                  color: isUser ? _userActionDark : _actionTextGray,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: characterStyle.fontFamily,
                                ),
                                msPerCharacter: _animationSpeed,  // ⭐ User setting
                                onProgress: widget.onContentExpanding,  // Scroll as content expands
                                onComplete: () {
                                  // After action text completes, pause then show dialogue
                                  Future.delayed(
                                    Duration(milliseconds: _pauseBetweenMs),
                                    () {
                                      if (mounted) {
                                        setState(() => _showDialogue = true);
                                      }
                                    },
                                  );
                                },
                              )
                            : Text(
                                widget.message.actionText!,
                                style: TextStyle(
                                  fontSize: _textSize,  // ⭐ User setting
                                  fontStyle: FontStyle.italic,
                                  color: isUser ? _userActionDark : _actionTextGray,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: characterStyle.fontFamily,
                                ),
                              ),
                      ),

                    // ⭐ Dialogue text - types after action text completes (or immediately if no action)
                    // ⭐ PHASE 4: Uses user's animation speed and text size settings
                    if (_showDialogue)
                      (widget.shouldAnimate && !_isInstantMode)
                          ? TypewriterText(
                              text: widget.message.dialogue,
                              style: StoryForgeTheme.dialogueText.copyWith(
                                color: isUser ? _userTextDark : _textPrimary,
                                fontSize: _textSize,  // ⭐ User setting
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                                fontFamily: characterStyle.fontFamily,
                              ),
                              msPerCharacter: _animationSpeed,  // ⭐ User setting
                              onProgress: widget.onContentExpanding,  // Scroll as content expands
                            )
                          : Text(
                              widget.message.dialogue,
                              style: StoryForgeTheme.dialogueText.copyWith(
                                color: isUser ? _userTextDark : _textPrimary,
                                fontSize: _textSize,  // ⭐ User setting
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                                fontFamily: characterStyle.fontFamily,
                              ),
                            ),
                  ],
                ),
              ),
            ],
          ),
        );
  }
}

/// Mood indicator with light styling to match cards
class _MoodIndicator extends StatelessWidget {
  final String mood;

  const _MoodIndicator({required this.mood});

  @override
  Widget build(BuildContext context) {
    // Safe mood color retrieval with fallback
    final moodColor = mood.isNotEmpty
        ? StoryForgeTheme.getMoodColor(mood)
        : DesignColors.dSecondaryText;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        // Light background with mood color tint
        color: moodColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(StoryForgeTheme.inputRadius),
        border: Border.all(
          color: moodColor.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Text(
        mood,
        style: StoryForgeTheme.moodLabel.copyWith(
          color: _getSafeShade700(moodColor),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Safe method to get shade700
  Color _getSafeShade700(Color color) {
    try {
      final hsl = HSLColor.fromColor(color);
      return hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
    } catch (e) {
      return color; // Return original if shade calculation fails
    }
  }
}

// Extension to get darker shade for mood text
extension ColorShade on Color {
  Color get shade700 {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
  }
}