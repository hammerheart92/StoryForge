import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/admin/story_dto.dart';
import '../../providers/admin/stories_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin/story_admin_service.dart';
import '../../theme/tokens/colors.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/storyforge_theme.dart';
import 'story_form_screen.dart';

/// Stories list screen - embedded in AdminLayoutScreen body (no Scaffold)
class StoriesListScreen extends ConsumerWidget {
  const StoriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(storiesListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return storiesAsync.when(
      data: (stories) {
        if (stories.isEmpty) {
          return _buildEmptyState(isDark);
        }
        return _buildStoryList(context, ref, stories, isDark);
      },
      loading: () => _buildLoadingState(isDark),
      error: (error, _) => _buildErrorState(context, ref, error, isDark),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: StoryForgeTheme.iconSizeXL,
            color: DesignColors.highlightTeal.withValues(alpha: 0.5),
          ),
          const SizedBox(height: DesignSpacing.md),
          Text(
            'No stories yet',
            style: TextStyle(
              fontFamily: 'Merriweather',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
            ),
          ),
          const SizedBox(height: DesignSpacing.sm),
          Text(
            'Create your first story to get started',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(DesignColors.highlightTeal),
          ),
          const SizedBox(height: DesignSpacing.md),
          Text(
            'Loading stories...',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error, bool isDark) {
    String message;
    if (error is NetworkException) {
      message = 'Check your internet connection';
    } else if (error is UnauthorizedException) {
      message = 'Please login again';
    } else if (error is ForbiddenException) {
      message = 'You do not have permission';
    } else {
      message = 'Something went wrong';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: StoryForgeTheme.iconSizeXL,
            color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
          ),
          const SizedBox(height: DesignSpacing.md),
          Text(
            'Failed to load stories',
            style: TextStyle(
              fontFamily: 'Merriweather',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
            ),
          ),
          const SizedBox(height: DesignSpacing.sm),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
            ),
          ),
          const SizedBox(height: DesignSpacing.lg),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(storiesListProvider),
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: StoryForgeTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(StoryForgeTheme.buttonRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryList(
    BuildContext context,
    WidgetRef ref,
    List<StoryDto> stories,
    bool isDark,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(storiesListProvider);
        await ref.read(storiesListProvider.future);
      },
      color: DesignColors.highlightTeal,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.md,
        ),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(height: DesignSpacing.sm),
        itemBuilder: (context, index) {
          return _StoryCard(
            story: stories[index],
            isDark: isDark,
            onTap: () => _navigateToEdit(context, ref, stories[index]),
            onLongPress: () => _showActionSheet(context, ref, stories[index], isDark),
          );
        },
      ),
    );
  }

  void _navigateToEdit(BuildContext context, WidgetRef ref, StoryDto story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryFormScreen(story: story),
      ),
    );
  }

  void _showActionSheet(BuildContext context, WidgetRef ref, StoryDto story, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(StoryForgeTheme.largeCardRadius),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: DesignSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: DesignSpacing.md),
            ListTile(
              leading: Icon(
                Icons.edit,
                color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
              ),
              title: Text(
                'Edit Story',
                style: TextStyle(
                  color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _navigateToEdit(context, ref, story);
              },
            ),
            ListTile(
              leading: Icon(
                story.published ? Icons.unpublished : Icons.publish,
                color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
              ),
              title: Text(
                story.published ? 'Unpublish' : 'Publish',
                style: TextStyle(
                  color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _togglePublish(context, ref, story);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
              ),
              title: Text(
                'Delete Story',
                style: TextStyle(
                  color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _confirmDelete(context, ref, story, isDark);
              },
            ),
            const SizedBox(height: DesignSpacing.sm),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePublish(BuildContext context, WidgetRef ref, StoryDto story) async {
    try {
      final service = ref.read(storyAdminServiceProvider);
      final updated = await service.togglePublishStatus(story.id);
      ref.invalidate(storiesListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updated.published ? 'Story published!' : 'Story unpublished!'),
            backgroundColor: StoryForgeTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on UnauthorizedException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Session expired. Please login again.'),
            backgroundColor: StoryForgeTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(authProvider.notifier).logout();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update publish status.'),
            backgroundColor: StoryForgeTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    StoryDto story,
    bool isDark,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
        title: Text(
          'Delete Story?',
          style: TextStyle(
            color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${story.title}"? This action cannot be undone.',
          style: TextStyle(
            color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? DesignColors.dDanger : DesignColors.lDanger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _handleDelete(context, ref, story);
    }
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref, StoryDto story) async {
    try {
      final service = ref.read(storyAdminServiceProvider);
      await service.deleteStory(story.id);
      ref.invalidate(storiesListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Story deleted successfully!'),
            backgroundColor: StoryForgeTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on UnauthorizedException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Session expired. Please login again.'),
            backgroundColor: StoryForgeTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(authProvider.notifier).logout();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete story.'),
            backgroundColor: StoryForgeTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// Individual story card in the list
class _StoryCard extends StatelessWidget {
  final StoryDto story;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _StoryCard({
    required this.story,
    required this.isDark,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
        borderRadius: BorderRadius.circular(StoryForgeTheme.pillRadius),
        border: Border.all(
          color: DesignColors.highlightTeal.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(StoryForgeTheme.pillRadius),
          child: Padding(
            padding: const EdgeInsets.all(DesignSpacing.md),
            child: Row(
              children: [
                // Leading icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DesignColors.highlightTeal.withValues(alpha: 0.1),
                    border: Border.all(
                      color: DesignColors.highlightTeal.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.book,
                    color: DesignColors.highlightTeal,
                    size: StoryForgeTheme.iconSizeMedium,
                  ),
                ),
                const SizedBox(width: DesignSpacing.md),

                // Title and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title,
                        style: TextStyle(
                          fontFamily: 'Merriweather',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? DesignColors.dPrimaryText
                              : DesignColors.lPrimaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (story.description != null && story.description!.isNotEmpty) ...[
                        const SizedBox(height: DesignSpacing.xs),
                        Text(
                          story.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? DesignColors.dSecondaryText
                                : DesignColors.lSecondaryText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: DesignSpacing.sm),

                // Publish badge
                _PublishBadge(published: story.published, isDark: isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Publish status badge
class _PublishBadge extends StatelessWidget {
  final bool published;
  final bool isDark;

  const _PublishBadge({required this.published, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = published
        ? (isDark ? DesignColors.dSuccess : DesignColors.lSuccess)
        : (isDark ? DesignColors.dWarning : DesignColors.lWarning);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(StoryForgeTheme.badgeRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        published ? 'Published' : 'Draft',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
