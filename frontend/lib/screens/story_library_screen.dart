// lib/screens/story_library_screen.dart
// Story Library screen showing all stories with save progress

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story_info.dart';
import '../models/save_info.dart';
import '../models/narrative_message.dart';
import '../providers/save_providers.dart';
import '../services/save_service.dart';
import '../services/story_state_service.dart';
import '../widgets/saved_story_card.dart';
import '../widgets/save_confirm_dialog.dart';
import '../theme/tokens/colors.dart';
import 'character_selection_screen.dart';
import 'narrative_screen.dart';

class StoryLibraryScreen extends ConsumerStatefulWidget {
  const StoryLibraryScreen({super.key});

  @override
  ConsumerState<StoryLibraryScreen> createState() => _StoryLibraryScreenState();
}

class _StoryLibraryScreenState extends ConsumerState<StoryLibraryScreen> {
  @override
  Widget build(BuildContext context) {
    final savesAsync = ref.watch(saveListProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: DesignColors.dBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: DesignColors.dPrimaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Story Library',
          style: TextStyle(
            fontFamily: 'Merriweather',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: DesignColors.dPrimaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: savesAsync.when(
        loading: () => _buildLoading(),
        error: (error, stack) => _buildError(error),
        data: (saves) => _buildLibrary(saves, isDesktop),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: DesignColors.highlightTeal,
          ),
          SizedBox(height: 16),
          Text(
            'Loading your stories...',
            style: TextStyle(
              color: DesignColors.dSecondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: DesignColors.dDanger,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Failed to load saves',
              style: TextStyle(
                color: DesignColors.dPrimaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                color: DesignColors.dSecondaryText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(saveListProvider),
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.highlightTeal,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibrary(List<SaveInfo> saves, bool isDesktop) {
    final stories = StoryInfo.all;

    // Create a map for quick lookup of saves by storyId
    final saveMap = {for (var s in saves) s.storyId: s};

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubheading(saves),
          SizedBox(height: 24),
          Center(
            child: Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: stories.map((story) {
                final save = saveMap[story.id];
                return SavedStoryCard(
                  story: story,
                  save: save,
                  onContinue: () => _handleContinue(story, save),
                  onNewGame: () => _handleNewGame(story, save),
                  onDelete: save != null
                      ? () => _handleDelete(story.id)
                      : null,
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSubheading(List<SaveInfo> saves) {
    final activeCount = saves.where((s) => !s.isCompleted).length;
    final completedCount = saves.where((s) => s.isCompleted).length;

    String subtext;
    if (saves.isEmpty) {
      subtext = 'Choose a story to begin your adventure';
    } else if (completedCount > 0 && activeCount > 0) {
      subtext = '$activeCount in progress, $completedCount completed';
    } else if (completedCount > 0) {
      subtext = '$completedCount ${completedCount == 1 ? 'story' : 'stories'} completed';
    } else {
      subtext = '$activeCount ${activeCount == 1 ? 'story' : 'stories'} in progress';
    }

    return Center(
      child: Text(
        subtext,
        style: TextStyle(
          color: DesignColors.dSecondaryText,
          fontSize: 14,
        ),
      ),
    );
  }

  Future<void> _handleContinue(StoryInfo story, SaveInfo? save) async {
    if (save == null) {
      // No save, start new game
      _handleNewGame(story, null);
      return;
    }

    // Load full conversation state
    final savedState = await StoryStateService.loadStateForStory(story.id);

    if (savedState == null) {
      // Edge case: metadata exists but conversation data is missing
      // Just start fresh
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save data not found. Starting new game.'),
            backgroundColor: DesignColors.dWarning,
          ),
        );
        await ref.read(saveServiceProvider).deleteSave(story.id);
        ref.invalidate(saveListProvider);
        _navigateToCharacterSelection(story.id);
      }
      return;
    }

    if (!mounted) return;

    // Navigate to narrative with restored state
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NarrativeScreen(
          restoredMessages: savedState['messages'] as List<NarrativeMessage>,
          lastCharacter: savedState['lastCharacter'] as String,
          storyId: story.id,
        ),
      ),
    );

    // Refresh library after returning
    ref.invalidate(saveListProvider);
  }

  Future<void> _handleNewGame(StoryInfo story, SaveInfo? existingSave) async {
    // If save exists, show confirmation dialog
    if (existingSave != null) {
      final confirmed = await SaveConfirmDialog.show(
        context: context,
        storyTitle: story.title,
      );

      if (!confirmed || !mounted) return;

      // Delete existing save
      await ref.read(saveServiceProvider).deleteSave(story.id);
      ref.invalidate(saveListProvider);
    }

    if (!mounted) return;

    _navigateToCharacterSelection(story.id);
  }

  Future<void> _navigateToCharacterSelection(String storyId) async {
    // Navigate to character selection
    final selectedCharacterId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterSelectionScreen(storyId: storyId),
      ),
    );

    if (selectedCharacterId == null || !mounted) {
      // User backed out
      return;
    }

    // Navigate to narrative screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NarrativeScreen(
          restoredMessages: null,
          startingCharacter: selectedCharacterId,
          storyId: storyId,
        ),
      ),
    );

    // Refresh library after returning
    ref.invalidate(saveListProvider);
  }

  Future<void> _handleDelete(String storyId) async {
    await ref.read(saveServiceProvider).deleteSave(storyId);
    ref.invalidate(saveListProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save deleted'),
          backgroundColor: DesignColors.dSurfaces,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
