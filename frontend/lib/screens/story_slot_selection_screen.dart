// lib/screens/story_slot_selection_screen.dart
// Screen for selecting a save slot (1-5) for a story
// Session 29: Multi-Slot Save System

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story_info.dart';
import '../models/save_info.dart';
import '../models/narrative_message.dart';
import '../providers/save_providers.dart';
import '../widgets/save_slot_card.dart';
import '../theme/storyforge_theme.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../services/story_state_service.dart';
import 'character_selection_screen.dart';
import 'narrative_screen.dart';

class StorySlotSelectionScreen extends ConsumerWidget {
  final StoryInfo story;

  const StorySlotSelectionScreen({
    super.key,
    required this.story,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savesAsync = ref.watch(storySavesProvider(story.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignColors.dBackground : DesignColors.lBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          story.title,
          style: TextStyle(
            fontFamily: 'Merriweather',
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: savesAsync.when(
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: story.accentColor),
              SizedBox(height: DesignSpacing.md),
              Text(
                'Loading save slots...',
                style: TextStyle(
                  color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => _buildErrorState(context, ref, error, isDark),
        data: (saves) => _buildSlotList(context, ref, saves, isDark),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: StoryForgeTheme.iconSizeXL,
              color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              'Unable to load save slots',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              'Check your connection and try again',
              style: TextStyle(
                color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(storySavesProvider(story.id)),
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: story.accentColor,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotList(BuildContext context, WidgetRef ref, List<SaveInfo> saves, bool isDark) {
    // Create map of slot -> save
    final Map<int, SaveInfo?> slotMap = {
      1: null, 2: null, 3: null, 4: null, 5: null,
    };
    for (var save in saves) {
      slotMap[save.saveSlot] = save;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Choose a save slot or start a new story',
                  style: TextStyle(
                    color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: DesignSpacing.lg),
              ...List.generate(5, (index) {
                final slot = index + 1;
                final save = slotMap[slot];
                return Padding(
                  padding: EdgeInsets.only(bottom: DesignSpacing.md),
                  child: SaveSlotCard(
                    story: story,
                    slotNumber: slot,
                    save: save,
                    isDark: isDark,
                    onContinue: () => _handleContinue(context, ref, slot, save, isDark),
                    onNewSave: () => _navigateToCharacterSelection(context, ref, slot),
                    onDelete: () => _confirmDelete(context, ref, slot, isDark),
                  ),
                );
              }),
              SizedBox(height: DesignSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue(BuildContext context, WidgetRef ref, int saveSlot, SaveInfo? save, bool isDark) async {
    if (save == null) {
      // No save, start new game
      _navigateToCharacterSelection(context, ref, saveSlot);
      return;
    }

    // Load full conversation state for this specific slot
    final savedState = await StoryStateService.loadStateForStory(story.id, saveSlot: saveSlot);

    if (savedState == null) {
      // Edge case: metadata exists but conversation data is missing
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save data not found. Starting new game.'),
            backgroundColor: isDark ? DesignColors.dWarning : DesignColors.lWarning,
          ),
        );
        _navigateToCharacterSelection(context, ref, saveSlot);
      }
      return;
    }

    if (!context.mounted) return;

    // Navigate to narrative with restored state
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NarrativeScreen(
          restoredMessages: savedState['messages'] as List<NarrativeMessage>,
          lastCharacter: savedState['lastCharacter'] as String,
          storyId: story.id,
          saveSlot: saveSlot,
        ),
      ),
    );

    // Refresh slots after returning
    ref.invalidate(storySavesProvider(story.id));
  }

  Future<void> _navigateToCharacterSelection(BuildContext context, WidgetRef ref, int saveSlot) async {
    final selectedCharacterId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterSelectionScreen(storyId: story.id),
      ),
    );

    if (selectedCharacterId == null || !context.mounted) {
      return;
    }

    // Navigate to narrative screen with selected character
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NarrativeScreen(
          restoredMessages: null,
          startingCharacter: selectedCharacterId,
          storyId: story.id,
          saveSlot: saveSlot,
        ),
      ),
    );

    // Refresh slots after returning
    ref.invalidate(storySavesProvider(story.id));
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, int saveSlot, bool isDark) async {
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StoryForgeTheme.pillRadius),
        ),
        title: Text(
          'Delete Save Slot $saveSlot?',
          style: TextStyle(
            color: primaryText,
            fontFamily: 'Merriweather',
          ),
        ),
        content: Text(
          'This action cannot be undone. Your progress will be permanently deleted.',
          style: TextStyle(color: secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: secondaryText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: dangerColor),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(saveServiceProvider).deleteSaveSlot(story.id, saveSlot);
        ref.invalidate(storySavesProvider(story.id));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Slot $saveSlot deleted'),
              backgroundColor: surfaceColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete slot: $e'),
              backgroundColor: dangerColor,
            ),
          );
        }
      }
    }
  }
}
