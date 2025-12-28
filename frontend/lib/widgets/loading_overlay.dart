// lib/widgets/loading_overlay.dart
// Full-screen loading overlay shown during API calls

import 'package:flutter/material.dart';
import '../theme/storyforge_theme.dart';
import '../theme/tokens/spacing.dart';

class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(DesignSpacing.lg),
          margin: const EdgeInsets.symmetric(horizontal: DesignSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
            boxShadow: StoryForgeTheme.modalShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Spinner
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  StoryForgeTheme.primaryColor,
                ),
              ),

              const SizedBox(height: DesignSpacing.md),

              // Loading message
              Text(
                message ?? 'Weaving the narrative...',
                style: StoryForgeTheme.dialogueText.copyWith(
                  color: StoryForgeTheme.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}