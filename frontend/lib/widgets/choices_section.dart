// lib/widgets/choices_section.dart
// Section that displays all available choices for the user

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/choice.dart';
import '../providers/narrative_provider.dart';
import '../theme/storyforge_theme.dart';
import '../theme/tokens/spacing.dart';
import 'choice_button.dart';

class ChoicesSection extends ConsumerWidget {
  final List<Choice> choices;
  final String storyId;

  const ChoicesSection({
    super.key,
    required this.choices,
    required this.storyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch loading state
    final isLoading = ref.watch(narrativeLoadingProvider);

    if (choices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider
          const Divider(height: 1),

          const SizedBox(height: DesignSpacing.md),

          // Prompt text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.md),
            child: Row(
              children: [
                const Text(
                  '💭',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: DesignSpacing.sm),
                Text(
                  'What do you do?',
                  style: StoryForgeTheme.characterName.copyWith(
                    color: StoryForgeTheme.primaryText,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: DesignSpacing.sm),

          // Choice buttons
          ...choices.map((choice) => ChoiceButton(
            choice: choice,
            isLoading: isLoading,
            onPressed: () {
              // Call the notifier to select this choice
              ref.read(narrativeStateProvider.notifier).selectChoice(choice, storyId);
            },
          )),

          const SizedBox(height: DesignSpacing.md),
        ],
      ),
    );
  }
}