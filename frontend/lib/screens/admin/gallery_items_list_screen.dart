import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/admin/gallery_item_dto.dart';
import '../../providers/admin/gallery_items_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin/gallery_admin_service.dart';
import '../../theme/tokens/colors.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/storyforge_theme.dart';
import 'gallery_item_form_screen.dart';

/// Gallery items list screen - embedded in AdminLayoutScreen body (no Scaffold)
class GalleryItemsListScreen extends ConsumerWidget {
  const GalleryItemsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(galleryItemsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return itemsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return _buildEmptyState(isDark);
        }
        return _buildItemList(context, ref, items, isDark);
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
            Icons.photo_library_outlined,
            size: StoryForgeTheme.iconSizeXL,
            color: DesignColors.highlightTeal.withValues(alpha: 0.5),
          ),
          const SizedBox(height: DesignSpacing.md),
          Text(
            'No gallery items yet',
            style: TextStyle(
              fontFamily: 'Merriweather',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
            ),
          ),
          const SizedBox(height: DesignSpacing.sm),
          Text(
            'Create your first gallery item to get started',
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
            'Loading gallery items...',
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
            'Failed to load gallery items',
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
            onPressed: () => ref.invalidate(galleryItemsListProvider),
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

  Widget _buildItemList(
    BuildContext context,
    WidgetRef ref,
    List<GalleryItemDto> items,
    bool isDark,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(galleryItemsListProvider);
        await ref.read(galleryItemsListProvider.future);
      },
      color: DesignColors.highlightTeal,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.md,
        ),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: DesignSpacing.sm),
        itemBuilder: (context, index) {
          return _GalleryItemCard(
            item: items[index],
            isDark: isDark,
            onTap: () => _navigateToEdit(context, ref, items[index]),
            onLongPress: () => _showActionSheet(context, ref, items[index], isDark),
          );
        },
      ),
    );
  }

  void _navigateToEdit(BuildContext context, WidgetRef ref, GalleryItemDto item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryItemFormScreen(item: item),
      ),
    );
  }

  void _showActionSheet(BuildContext context, WidgetRef ref, GalleryItemDto item, bool isDark) {
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
                'Edit Item',
                style: TextStyle(
                  color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _navigateToEdit(context, ref, item);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
              ),
              title: Text(
                'Delete Item',
                style: TextStyle(
                  color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _confirmDelete(context, ref, item, isDark);
              },
            ),
            const SizedBox(height: DesignSpacing.sm),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    GalleryItemDto item,
    bool isDark,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
        title: Text(
          'Delete Gallery Item?',
          style: TextStyle(
            color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${item.title}"? This action cannot be undone.',
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
      await _handleDelete(context, ref, item);
    }
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref, GalleryItemDto item) async {
    try {
      final service = ref.read(galleryAdminServiceProvider);
      await service.deleteGalleryItem(item.contentId);
      ref.invalidate(galleryItemsListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gallery item deleted successfully!'),
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
            content: const Text('Failed to delete gallery item.'),
            backgroundColor: StoryForgeTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// Individual gallery item card in the list
class _GalleryItemCard extends StatelessWidget {
  final GalleryItemDto item;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _GalleryItemCard({
    required this.item,
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
                  child: Icon(
                    _getContentTypeIcon(item.contentType),
                    color: DesignColors.highlightTeal,
                    size: StoryForgeTheme.iconSizeMedium,
                  ),
                ),
                const SizedBox(width: DesignSpacing.md),

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
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
                      const SizedBox(height: DesignSpacing.xs),
                      Row(
                        children: [
                          Text(
                            '${item.unlockCost} gems',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? DesignColors.dSecondaryText
                                  : DesignColors.lSecondaryText,
                            ),
                          ),
                          const SizedBox(width: DesignSpacing.sm),
                          _RarityBadge(rarity: item.rarity),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DesignSpacing.sm),

                // Content type badge
                _ContentTypeBadge(contentType: item.contentType, isDark: isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getContentTypeIcon(String contentType) {
    switch (contentType) {
      case 'scene':
        return Icons.movie_outlined;
      case 'character':
        return Icons.person_outline;
      case 'lore':
        return Icons.auto_stories_outlined;
      case 'extra':
        return Icons.star_outline;
      default:
        return Icons.image_outlined;
    }
  }
}

/// Rarity badge with design system colors
class _RarityBadge extends StatelessWidget {
  final String rarity;

  const _RarityBadge({required this.rarity});

  @override
  Widget build(BuildContext context) {
    final color = _getRarityColor(rarity);
    final label = rarity[0].toUpperCase() + rarity.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(StoryForgeTheme.chipRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return DesignColors.rarityCommon;
      case 'rare':
        return DesignColors.rarityRare;
      case 'epic':
        return DesignColors.rarityEpic;
      case 'legendary':
        return DesignColors.rarityLegendary;
      default:
        return DesignColors.rarityCommon;
    }
  }
}

/// Content type badge
class _ContentTypeBadge extends StatelessWidget {
  final String contentType;
  final bool isDark;

  const _ContentTypeBadge({required this.contentType, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final label = contentType[0].toUpperCase() + contentType.substring(1);
    final color = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(StoryForgeTheme.badgeRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
