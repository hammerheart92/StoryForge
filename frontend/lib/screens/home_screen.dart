// lib/screens/home_screen.dart
// HomeScreen - Entry point for StoryForge storytelling experience
// Features atmospheric gradient background with character-themed glowing buttons

import 'package:flutter/material.dart';
import '../models/narrative_message.dart';
import '../services/story_state_service.dart';
import '../theme/storyforge_theme.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import 'narrative_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasSavedStory = false;

  @override
  void initState() {
    super.initState();
    _checkForSavedStory();
  }

  /// Check for saved story on screen load
  Future<void> _checkForSavedStory() async {
    final hasSaved = await StoryStateService.hasSavedState();
    if (mounted) {
      setState(() {
        _hasSavedStory = hasSaved;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      body: Stack(
        children: [
          // Main content with gradient background
          Container(
            // Option B: Subtle vertical gradient (atmospheric depth)
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A2E), // Dark blue-gray (top)
                  Color(0xFF121417), // Near black (middle) - matches dBackground
                  Color(0xFF0D0D0D), // Deeper black (bottom)
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSpacing.lg,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title: "StoryForge"
                    Text(
                      'StoryForge',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Merriweather',
                        fontSize: isDesktop
                            ? StoryForgeTheme.homeTitleSizeDesktop
                            : StoryForgeTheme.homeTitleSizeMobile,
                        fontWeight: FontWeight.bold,
                        color: DesignColors.dPrimaryText,
                        letterSpacing: 2.0,
                        shadows: [
                          // Subtle text glow for drama
                          Shadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: DesignSpacing.md),

                    // Subtitle: "Interactive Storytelling"
                    Text(
                      'Interactive Storytelling',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Merriweather',
                        fontSize: isDesktop
                            ? StoryForgeTheme.homeSubtitleSizeDesktop
                            : StoryForgeTheme.homeSubtitleSizeMobile,
                        fontStyle: FontStyle.italic,
                        color: DesignColors.dSecondaryText,
                        letterSpacing: 1.2,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: isDesktop ? 80 : 64),

                    // Primary Button: "Begin Your Story"
                    _PrimaryButton(
                      onTap: () async {
                        // Clear old state before starting new story
                        await StoryStateService.clearState();

                        if (!context.mounted) return;
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NarrativeScreen(
                              restoredMessages: null, // Fresh start
                            ),
                          ),
                        );

                        // Refresh button state after returning
                        _checkForSavedStory();
                      },
                    ),

                    const SizedBox(height: DesignSpacing.lg),

                    // Secondary Button: "Continue Story"
                    _SecondaryButton(
                      enabled: _hasSavedStory,
                      onTap: _hasSavedStory
                          ? () async {
                              // Load saved state and restore
                              final savedState =
                                  await StoryStateService.loadState();

                              if (savedState == null) {
                                // Edge case: state deleted between check and tap
                                if (mounted) {
                                  setState(() {
                                    _hasSavedStory = false;
                                  });
                                }
                                return;
                              }

                              if (!context.mounted) return;

                              // Navigate with restored messages
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NarrativeScreen(
                                    restoredMessages: savedState['messages']
                                        as List<NarrativeMessage>,
                                    lastCharacter:
                                        savedState['lastCharacter'] as String,
                                  ),
                                ),
                              );

                              // Refresh button state after returning
                              _checkForSavedStory();
                            }
                          : null,
                    ),

                    SizedBox(
                      height: isDesktop
                          ? DesignSpacing.xxl
                          : DesignSpacing.xl,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

          // Profile icon button (top-right)
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(DesignSpacing.md),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final dataCleared = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );

                      // Refresh state if data was cleared
                      if (dataCleared == true) {
                        _checkForSavedStory();
                      }
                    },
                    borderRadius: BorderRadius.circular(24),
                    splashColor: DesignColors.highlightTeal.withOpacity(0.3),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DesignColors.dSurfaces.withOpacity(0.6),
                        border: Border.all(
                          color: DesignColors.highlightTeal.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: DesignColors.highlightTeal,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Primary button with teal glow effect (Narrator theme)
class _PrimaryButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PrimaryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Begin your interactive story with the Narrator and Ilyra',
      button: true,
      enabled: true,
      child: Container(
        width: StoryForgeTheme.homeButtonWidth,
        height: StoryForgeTheme.homeButtonHeight,
        decoration: BoxDecoration(
          // Dark background with slight teal tint
          color: const Color(0xFF1A2828),
          borderRadius: BorderRadius.circular(
            StoryForgeTheme.homeButtonRadius,
          ),

          // Subtle teal border
          border: Border.all(
            color: StoryForgeTheme.narratorTeal.withOpacity(0.6),
            width: 1.5,
          ),

          // Multi-layer glow effect
          boxShadow: [
            // Inner glow (close, intense)
            BoxShadow(
              color: StoryForgeTheme.narratorTeal.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
            // Outer glow (far, soft)
            BoxShadow(
              color: StoryForgeTheme.narratorTeal.withOpacity(0.3),
              blurRadius: 40,
              spreadRadius: 5,
              offset: const Offset(0, 4),
            ),
            // Subtle bottom shadow for depth
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              StoryForgeTheme.homeButtonRadius,
            ),
            splashColor: StoryForgeTheme.narratorTeal.withOpacity(0.3),
            highlightColor: StoryForgeTheme.narratorTeal.withOpacity(0.2),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Begin Your Story',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: DesignColors.dPrimaryText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward,
                    color: StoryForgeTheme.narratorTeal,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary button with purple glow (enabled when saved story exists)
class _SecondaryButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;

  const _SecondaryButton({
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: enabled
          ? 'Continue your saved story'
          : 'Continue story - no saved story available',
      button: true,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5, // Full opacity when enabled
        child: Container(
          width: StoryForgeTheme.homeButtonWidth,
          height: StoryForgeTheme.homeButtonHeight,
          decoration: BoxDecoration(
            // Dark background with purple tint (brighter when enabled)
            color: enabled ? const Color(0xFF1E1A28) : const Color(0xFF1A1A24),
            borderRadius: BorderRadius.circular(
              StoryForgeTheme.homeButtonRadius,
            ),

            // Purple border (brighter when enabled)
            border: Border.all(
              color: StoryForgeTheme.ilyraExtended
                  .withOpacity(enabled ? 0.6 : 0.3),
              width: 1.5,
            ),

            // Glow effect (stronger when enabled)
            boxShadow: enabled
                ? [
                    // Inner glow (close, intense) - enabled state
                    BoxShadow(
                      color: StoryForgeTheme.ilyraExtended.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 0),
                    ),
                    // Outer glow (far, soft) - enabled state
                    BoxShadow(
                      color: StoryForgeTheme.ilyraExtended.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 5,
                      offset: const Offset(0, 4),
                    ),
                    // Subtle bottom shadow for depth
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    // Very subtle purple glow - disabled state
                    BoxShadow(
                      color: StoryForgeTheme.ilyraExtended.withOpacity(0.15),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                    // Soft shadow for depth
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onTap : null, // Only tappable when enabled
              borderRadius: BorderRadius.circular(
                StoryForgeTheme.homeButtonRadius,
              ),
              splashColor: StoryForgeTheme.ilyraExtended.withOpacity(0.3),
              highlightColor: StoryForgeTheme.ilyraExtended.withOpacity(0.2),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue Story',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: enabled
                            ? DesignColors.dPrimaryText
                            : DesignColors.dSecondaryText,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.arrow_forward,
                      color: enabled
                          ? StoryForgeTheme.ilyraExtended
                          : StoryForgeTheme.ilyraExtended.withOpacity(0.5),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
