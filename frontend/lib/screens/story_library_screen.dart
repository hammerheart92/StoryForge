// lib/screens/story_library_screen.dart
// Story Library screen showing all stories with save progress

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story_info.dart';
import '../models/save_info.dart';
import '../providers/save_providers.dart';
import '../widgets/saved_story_card.dart';
import '../theme/tokens/colors.dart';
import 'story_slot_selection_screen.dart';

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

  Widget _buildSortFilterControls() {
    final sortOrder = ref.watch(sortOrderProvider);
    final filter = ref.watch(filterProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Sort dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Sort by:', style: TextStyle(color: DesignColors.dSecondaryText)),
              SizedBox(width: 8),
              DropdownButton<String>(
                value: sortOrder,
                dropdownColor: DesignColors.dSurfaces,
                style: TextStyle(color: DesignColors.dPrimaryText),
                underline: Container(
                  height: 1,
                  color: DesignColors.dSecondaryText.withValues(alpha: 0.3),
                ),
                items: [
                  DropdownMenuItem(value: 'lastPlayed', child: Text('Last Played')),
                  DropdownMenuItem(value: 'alphabetical', child: Text('Alphabetical')),
                  DropdownMenuItem(value: 'completion', child: Text('Completion')),
                ],
                onChanged: (value) => ref.read(sortOrderProvider.notifier).state = value!,
              ),
            ],
          ),
          SizedBox(height: 12),
          // Filter chips - use Wrap to allow wrapping on narrow screens
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: Text('All'),
                selected: filter == 'all',
                selectedColor: DesignColors.highlightTeal.withValues(alpha: 0.3),
                checkmarkColor: DesignColors.highlightTeal,
                onSelected: (_) => ref.read(filterProvider.notifier).state = 'all',
              ),
              FilterChip(
                label: Text('In Progress'),
                selected: filter == 'inProgress',
                selectedColor: DesignColors.highlightTeal.withValues(alpha: 0.3),
                checkmarkColor: DesignColors.highlightTeal,
                onSelected: (_) => ref.read(filterProvider.notifier).state = 'inProgress',
              ),
              FilterChip(
                label: Text('Completed'),
                selected: filter == 'completed',
                selectedColor: DesignColors.highlightTeal.withValues(alpha: 0.3),
                checkmarkColor: DesignColors.highlightTeal,
                onSelected: (_) => ref.read(filterProvider.notifier).state = 'completed',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLibrary(List<SaveInfo> saves, bool isDesktop) {
    final stories = StoryInfo.all;
    final sortOrder = ref.watch(sortOrderProvider);
    final filter = ref.watch(filterProvider);

    // Create a map for quick lookup of saves by storyId
    final saveMap = {for (var s in saves) s.storyId: s};

    // Get stories with saves, apply filter and sort
    var storiesWithSaves = stories.where((s) => saveMap.containsKey(s.id)).toList();
    var storiesWithoutSaves = stories.where((s) => !saveMap.containsKey(s.id)).toList();

    // Apply filter to saves
    if (filter == 'inProgress') {
      storiesWithSaves = storiesWithSaves.where((s) => !(saveMap[s.id]?.isCompleted ?? false)).toList();
    } else if (filter == 'completed') {
      storiesWithSaves = storiesWithSaves.where((s) => saveMap[s.id]?.isCompleted ?? false).toList();
    }

    // Apply sort to stories with saves
    if (sortOrder == 'lastPlayed') {
      storiesWithSaves.sort((a, b) => saveMap[b.id]!.lastPlayed.compareTo(saveMap[a.id]!.lastPlayed));
    } else if (sortOrder == 'alphabetical') {
      storiesWithSaves.sort((a, b) => a.title.compareTo(b.title));
      storiesWithoutSaves.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortOrder == 'completion') {
      storiesWithSaves.sort((a, b) {
        final aCompleted = saveMap[a.id]?.isCompleted ?? false;
        final bCompleted = saveMap[b.id]?.isCompleted ?? false;
        if (aCompleted != bCompleted) return aCompleted ? 1 : -1;
        return saveMap[b.id]!.lastPlayed.compareTo(saveMap[a.id]!.lastPlayed);
      });
    }

    // Combine: saves first (sorted), then unsaved stories
    final orderedStories = [...storiesWithSaves, ...storiesWithoutSaves];

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubheading(saves),
          SizedBox(height: 16),
          _buildSortFilterControls(),
          SizedBox(height: 24),
          Center(
            child: Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: orderedStories.map((story) {
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

  // Session 29: Navigate to slot selection screen for all story interactions
  Future<void> _handleContinue(StoryInfo story, SaveInfo? save) async {
    await _navigateToSlotSelection(story);
  }

  Future<void> _handleNewGame(StoryInfo story, SaveInfo? existingSave) async {
    await _navigateToSlotSelection(story);
  }

  Future<void> _navigateToSlotSelection(StoryInfo story) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StorySlotSelectionScreen(story: story),
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
