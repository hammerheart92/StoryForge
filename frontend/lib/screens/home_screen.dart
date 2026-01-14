// lib/screens/home_screen.dart
// HomeScreen - Entry point for StoryForge storytelling experience
// Features atmospheric gradient background with character-themed glowing buttons

import 'package:flutter/material.dart';
import '../theme/storyforge_theme.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import 'profile_screen.dart';
import 'story_library_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                colors: DesignColors.appGradient,
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
                                color: DesignColors.dPrimaryText.withOpacity(0.3),
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

                        SizedBox(
                          height: isDesktop
                              ? DesignSpacing.xxl + DesignSpacing.xl // 80
                              : DesignSpacing.xxl + DesignSpacing.md, // 64
                        ),

                        // Story Library Button
                        _StoryLibraryButton(
                          onTap: () async {
                            if (!context.mounted) return;

                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StoryLibraryScreen(),
                              ),
                            );
                          },
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(StoryForgeTheme.heroCardRadius),
                    splashColor: DesignColors.highlightTeal.withOpacity(0.3),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: DesignColors.highlightTeal.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: DesignColors.highlightTeal,
                        size: StoryForgeTheme.iconSizeMedium,
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

/// Story Library button with teal glow effect
class _StoryLibraryButton extends StatelessWidget {
  final VoidCallback onTap;

  const _StoryLibraryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Open Story Library to browse and continue stories',
      button: true,
      enabled: true,
      child: Container(
        width: StoryForgeTheme.homeButtonWidth,
        height: StoryForgeTheme.homeButtonHeight,
        decoration: BoxDecoration(
          color: DesignColors.dSurfaces,
          borderRadius: BorderRadius.circular(
            StoryForgeTheme.homeButtonRadius,
          ),
          border: Border.all(
            color: StoryForgeTheme.narratorTeal.withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: StoryForgeTheme.narratorTeal.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: StoryForgeTheme.narratorTeal.withOpacity(0.3),
              blurRadius: 40,
              spreadRadius: 5,
              offset: const Offset(0, 4),
            ),
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
                  Icon(
                    Icons.library_books,
                    color: StoryForgeTheme.narratorTeal,
                    size: StoryForgeTheme.iconSizeRegular + 2, // 22
                  ),
                  SizedBox(width: DesignSpacing.sm + 4), // 12
                  Text(
                    'Story Library',
                    style: TextStyle(
                      fontSize: 18, // Button text size
                      fontWeight: FontWeight.w600,
                      color: DesignColors.dPrimaryText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: DesignSpacing.sm + 4), // 12
                  Icon(
                    Icons.arrow_forward,
                    color: StoryForgeTheme.narratorTeal,
                    size: StoryForgeTheme.iconSizeRegular + 2, // 22
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