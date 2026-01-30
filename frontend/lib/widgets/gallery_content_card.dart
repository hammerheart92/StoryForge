// lib/widgets/gallery_content_card.dart
// Beautiful card widget for gallery content items with blur effect and rarity styling

import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/gallery_content.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/shadows.dart';
import '../theme/storyforge_theme.dart';

/// Beautiful card for displaying gallery content items.
///
/// Features:
/// - Rarity-colored border (common/rare/epic/legendary)
/// - Blur effect on locked content
/// - Lock icon overlay when locked
/// - Green checkmark when unlocked
/// - Content-type icon (scene/character/lore/extra)
/// - Unlock button with gem cost
///
/// Usage:
/// ```dart
/// GalleryContentCard(
///   content: galleryContent,
///   isUnlocked: false,
///   hasEnoughGems: true,
///   onUnlockTap: () => handleUnlock(),
/// )
/// ```
class GalleryContentCard extends StatelessWidget {
  final GalleryContent content;
  final bool isUnlocked;
  final bool hasEnoughGems;
  final VoidCallback onUnlockTap;
  final VoidCallback? onTap;

  const GalleryContentCard({
    required this.content,
    required this.isUnlocked,
    required this.hasEnoughGems,
    required this.onUnlockTap,
    this.onTap,
    super.key,
  });

  Color _getRarityColor() {
    switch (content.rarity.toLowerCase()) {
      case 'legendary':
        return DesignColors.rarityLegendary;
      case 'epic':
        return DesignColors.rarityEpic;
      case 'rare':
        return DesignColors.rarityRare;
      case 'common':
      default:
        return DesignColors.rarityCommon;
    }
  }

  IconData _getContentTypeIcon() {
    switch (content.contentType.toLowerCase()) {
      case 'scene':
        return Icons.landscape;
      case 'character':
        return Icons.person;
      case 'lore':
        return Icons.menu_book;
      case 'extra':
        return Icons.star;
      default:
        return Icons.image;
    }
  }

  String? _getSceneImagePath() {
    // Map content IDs to image files (scenes only for now)
    if (content.contentType.toLowerCase() != 'scene') {
      return null; // Only scenes have images for now
    }

    // Map based on title (you can also use contentId if you prefer)
    switch (content.title.toLowerCase()) {
      case 'the storm':
        return 'assets/images/gallery/scenes/scene_storm.png';
      case 'the kraken attack':
        return 'assets/images/gallery/scenes/scene_kraken_attack.png';
      case 'treasure island discovery':
        return 'assets/images/gallery/scenes/scene_treasure_island.png';
      default:
        return null; // Fallback to placeholder
    }
  }

  String? _getCharacterImagePath() {
    // Map character titles to image files
    if (content.contentType.toLowerCase() != 'character') {
      return null; // Only characters have images for now
    }

    switch (content.title.toLowerCase()) {
      case 'captain isla portrait':
        return 'assets/images/gallery/characters/character_isla_portrait.png';
      case 'first mate rodriguez':
        return 'assets/images/gallery/characters/character_rodriguez_portrait.png';
      case 'the sea witch':
        return 'assets/images/gallery/characters/character_sea_witch_portrait.png';
      default:
        return null; // Fallback to placeholder
    }
  }

  String? _getLoreImagePath() {
    if (content.contentType.toLowerCase() != 'lore') {
      return null;
    }

    switch (content.title.toLowerCase()) {
      case 'the pirate code':
        return 'assets/images/gallery/lore/lore_pirate_code.png';
      case 'captain\'s logbook':
        return 'assets/images/gallery/lore/lore_captains_logbook.png';
      case 'the black pearl legend':
        return 'assets/images/gallery/lore/lore_black_pearl_legend.png';
      case 'ancient sea chart':
        return 'assets/images/gallery/lore/lore_ancient_sea_chart.png';
      case 'the kraken chronicle':
        return 'assets/images/gallery/lore/lore_kraken_chronicle.png';
      default:
        return null;
    }
  }

  String? _getExtrasImagePath() {
    if (content.contentType.toLowerCase() != 'extra') {
      return null;
    }

    switch (content.title.toLowerCase()) {
      case 'ship\'s bell':
        return 'assets/images/gallery/extras/extras_ships_bell.png';
      case 'pirate\'s spyglass':
        return 'assets/images/gallery/extras/extras_pirates_spyglass.png';
      case 'rum bottles collection':
        return 'assets/images/gallery/extras/extras_rum_bottles.png';
      case 'treasure coins':
        return 'assets/images/gallery/extras/extras_treasure_coins.png';
      case 'captain\'s pistol':
        return 'assets/images/gallery/extras/extras_captains_pistol.png';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
        border: Border.all(
          color: rarityColor,
          width: 3,
        ),
        boxShadow: DesignShadows.glowSoft(rarityColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9), // 12 - 3 (border width)
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail area (60% of card)
            Expanded(
              flex: 5,
              child: _buildThumbnailArea(rarityColor),
            ),
            // Info area (40% of card)
            Expanded(
              flex: 4,
              child: _buildInfoArea(context),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildThumbnailArea(Color rarityColor) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image or placeholder
            () {
              final imagePath = _getSceneImagePath() ??
                  _getCharacterImagePath() ??
                  _getLoreImagePath() ??
                  _getExtrasImagePath();

          if (imagePath != null) {
            return Image.asset(
              imagePath,
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,  // Keep the top (face) visible
              errorBuilder: (context, error, stackTrace) {
                // Fallback to placeholder if image fails to load
                return Container(
                  color: rarityColor.withOpacity(0.15),
                  child: Center(
                    child: Icon(
                      _getContentTypeIcon(),
                      size: 48,
                      color: rarityColor.withOpacity(0.5),
                    ),
                  ),
                );
              },
            );
          } else {
            // Placeholder for content without images
            return Container(
              color: rarityColor.withOpacity(0.15),
              child: Center(
                child: Icon(
                  _getContentTypeIcon(),
                  size: 48,
                  color: rarityColor.withOpacity(0.5),
                ),
              ),
            );
          }
        }(),

        // Blur overlay for locked content (rest stays the same)
        if (!isUnlocked) _buildLockedOverlay(),

        // Rarity badge (top-left, always visible)
        Positioned(
          top: DesignSpacing.sm,
          left: DesignSpacing.sm,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Non-standard badge padding
            decoration: BoxDecoration(
              color: rarityColor,
              borderRadius: BorderRadius.circular(StoryForgeTheme.chipRadius),
              boxShadow: DesignShadows.sm,
            ),
            child: Text(
              content.rarity.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

        // Unlocked checkmark (top-right)
        if (isUnlocked)
          Positioned(
            top: DesignSpacing.sm,
            right: DesignSpacing.sm,
            child: Container(
              padding: EdgeInsets.all(DesignSpacing.xs),
              decoration: BoxDecoration(
                color: DesignColors.lSuccess,
                shape: BoxShape.circle,
                boxShadow: DesignShadows.glowSoft(DesignColors.lSuccess),
              ),
              child: Icon(
                Icons.check,
                size: StoryForgeTheme.iconSizeSmall,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLockedOverlay() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(DesignSpacing.sm + 4), // 12
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock,
                size: StoryForgeTheme.iconSizeLarge,
                color: Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.sm),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Flexible(
            child: Text(
              content.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Status/Action row
          if (isUnlocked)
            _buildUnlockedStatus()
          else
            _buildUnlockButton(),
        ],
      ),
    );
  }

  Widget _buildUnlockedStatus() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs),
      decoration: BoxDecoration(
        color: DesignColors.lSuccess.withOpacity(0.1),
        borderRadius: BorderRadius.circular(StoryForgeTheme.inputRadius),
        border: Border.all(color: DesignColors.lSuccess.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: StoryForgeTheme.iconSizeSmall, color: DesignColors.lSuccess),
          SizedBox(width: DesignSpacing.xs),
          Text(
            'Unlocked',
            style: TextStyle(
              color: DesignColors.lSuccess,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onUnlockTap,  // Always allow tap, dialog handles the check
        style: ElevatedButton.styleFrom(
          backgroundColor: hasEnoughGems ? DesignColors.rarityEpic : Colors.grey,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: DesignSpacing.xs),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StoryForgeTheme.inputRadius),
          ),
          elevation: hasEnoughGems ? 2 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.diamond, size: StoryForgeTheme.iconSizeSmall),
            SizedBox(width: DesignSpacing.xs),
            Text(
              '${content.unlockCost}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
