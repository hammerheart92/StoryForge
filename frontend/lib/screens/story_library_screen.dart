// lib/screens/story_library_screen.dart
// Story Library screen showing all stories with save progress

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story_info.dart';
import '../models/save_info.dart';
import '../providers/save_providers.dart';
import '../widgets/saved_story_card.dart';
import '../theme/storyforge_theme.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/typography.dart';
import 'story_slot_selection_screen.dart';
import 'gallery_screen.dart';
import 'story_endings_screen.dart';

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
          'Story Library',
          style: TextStyle(
            fontFamily: 'Merriweather',
            fontSize: DesignTypography.headingMedium.fontSize,
            fontWeight: FontWeight.bold,
            color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: savesAsync.when(
        loading: () => _buildLoading(isDark),
        error: (error, stack) => _buildError(error, isDark),
        data: (saves) => _buildLibrary(saves, isDesktop, isDark),
      ),
    );
  }

  Widget _buildLoading(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: DesignColors.highlightTeal,
          ),
          SizedBox(height: DesignSpacing.md),
          Text(
            'Loading your stories...',
            style: TextStyle(
              color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object error, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
              size: StoryForgeTheme.iconSizeLarge + 16,
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              'Failed to load saves',
              style: TextStyle(
                color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              error.toString(),
              style: TextStyle(
                color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.lg),
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

  Widget _buildSortFilterControls(bool isDark) {
    final sortOrder = ref.watch(sortOrderProvider);
    final filter = ref.watch(filterProvider);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
      child: Column(
        children: [
          // Sort dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sort by:',
                style: TextStyle(
                  color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
                ),
              ),
              SizedBox(width: DesignSpacing.sm),
              DropdownButton<String>(
                value: sortOrder,
                dropdownColor: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
                style: TextStyle(
                  color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
                ),
                underline: Container(
                  height: 1,
                  color: (isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText)
                      .withValues(alpha: 0.3),
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
          SizedBox(height: DesignSpacing.sm + 4),
          // Filter chips
          Wrap(
            alignment: WrapAlignment.center,
            spacing: DesignSpacing.sm,
            runSpacing: DesignSpacing.sm,
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

  Widget _buildLibrary(List<SaveInfo> saves, bool isDesktop, bool isDark) {
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
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubheading(saves, isDark),
          SizedBox(height: DesignSpacing.md),
          _buildSortFilterControls(isDark),
          SizedBox(height: DesignSpacing.lg),
          Center(
            child: Wrap(
              spacing: DesignSpacing.lg,
              runSpacing: DesignSpacing.lg,
              alignment: WrapAlignment.center,
              children: orderedStories.map((story) {
                final save = saveMap[story.id];
                return SavedStoryCard(
                  story: story,
                  save: save,
                  isDark: isDark,
                  onContinue: () => _handleContinue(story, save),
                  onNewGame: () => _handleNewGame(story, save),
                  onDelete: save != null
                      ? () => _handleDelete(story.id, isDark)
                      : null,
                  onGallery: () => _handleGallery(story.id),
                  onViewEndings: save != null
                      ? () => _handleViewEndings(story.id)
                      : null,
                );
              }).toList(),
            ),
          ),
          SizedBox(height: DesignSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSubheading(List<SaveInfo> saves, bool isDark) {
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
          color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
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

  Future<void> _handleDelete(String storyId, bool isDark) async {
    await ref.read(saveServiceProvider).deleteSave(storyId);
    ref.invalidate(saveListProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save deleted'),
          backgroundColor: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Phase B: Navigate to gallery for a story
  void _handleGallery(String storyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryScreen(storyId: storyId),
      ),
    );
  }

  // Session 34: Navigate to endings screen for a story
  void _handleViewEndings(String storyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryEndingsScreen(storyId: storyId),
      ),
    );
  }
}
