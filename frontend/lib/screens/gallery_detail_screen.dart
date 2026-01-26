// lib/screens/gallery_detail_screen.dart
// Full-screen detail view for gallery content with animated Sea Witch support

import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/gallery_content.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/shadows.dart';
import '../theme/tokens/typography.dart';
import '../theme/storyforge_theme.dart';
import '../widgets/animated_character_background.dart';

/// Full-screen detail view for gallery content.
///
/// Features:
/// - Animated video background for Sea Witch character
/// - Static image background for scenes/other characters
/// - Blur overlay for locked content
/// - Info overlay with title, description, rarity badge
/// - Unlock button (if locked)
class GalleryDetailScreen extends StatelessWidget {
  final GalleryContent content;
  final bool isUnlocked;
  final bool hasEnoughGems;
  final VoidCallback? onUnlock;

  const GalleryDetailScreen({
    required this.content,
    required this.isUnlocked,
    required this.hasEnoughGems,
    this.onUnlock,
    super.key,
  });

  /// Check if this content is the Sea Witch (animated character)
  bool _isSeaWitch() {
    return content.title.toLowerCase() == 'the sea witch' &&
        content.contentType.toLowerCase() == 'character';
  }

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
    if (content.contentType.toLowerCase() != 'scene') {
      return null;
    }

    switch (content.title.toLowerCase()) {
      case 'the storm':
        return 'assets/images/gallery/scenes/scene_storm.png';
      case 'the kraken attack':
        return 'assets/images/gallery/scenes/scene_kraken_attack.png';
      case 'treasure island discovery':
        return 'assets/images/gallery/scenes/scene_treasure_island.png';
      default:
        return null;
    }
  }

  String? _getCharacterImagePath() {
    if (content.contentType.toLowerCase() != 'character') {
      return null;
    }

    switch (content.title.toLowerCase()) {
      case 'captain isla portrait':
        return 'assets/images/gallery/characters/character_isla_portrait.png';
      case 'first mate rodriguez':
        return 'assets/images/gallery/characters/character_rodriguez_portrait.png';
      case 'the sea witch':
        return 'assets/images/gallery/characters/character_sea_witch_portrait.png';
      default:
        return null;
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

  Widget _buildBackground() {
    final rarityColor = _getRarityColor();

    // Sea Witch gets animated video background
    if (_isSeaWitch()) {
      return AnimatedCharacterBackground(
        videoPath: 'assets/videos/character_sea_witch_portrait.mp4',
      );
    }

    // Scenes get static images
    final imagePath = _getSceneImagePath() ??
        _getCharacterImagePath() ??
        _getLoreImagePath() ??
        _getExtrasImagePath();
    if (imagePath != null) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(rarityColor),
      );
    }

    // Everything else gets a placeholder
    return _buildPlaceholder(rarityColor);
  }

  Widget _buildPlaceholder(Color rarityColor) {
    return Container(
      color: rarityColor.withValues(alpha: 0.15),
      child: Center(
        child: Icon(
          _getContentTypeIcon(),
          size: 96,
          color: rarityColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildLockedOverlay() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          color: Colors.black.withValues(alpha: 0.4),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(DesignSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock,
                size: StoryForgeTheme.iconSizeXL,
                color: Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoOverlay(BuildContext context) {
    final rarityColor = _getRarityColor();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
              Colors.black.withValues(alpha: 0.9),
            ],
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          DesignSpacing.lg,
          DesignSpacing.xxl,
          DesignSpacing.lg,
          DesignSpacing.lg + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rarity badge
            _buildRarityBadge(rarityColor),
            SizedBox(height: DesignSpacing.sm),

            // Title
            Text(
              content.title,
              style: DesignTypography.headingMedium.copyWith(
                color: Colors.white,
              ),
            ),

            // Description (if available)
            if (content.description != null) ...[
              SizedBox(height: DesignSpacing.sm),
              Text(
                content.description!,
                style: DesignTypography.bodyRegular.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.4,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Unlock button (if locked)
            if (!isUnlocked) ...[
              SizedBox(height: DesignSpacing.lg),
              _buildUnlockButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRarityBadge(Color rarityColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: rarityColor,
        borderRadius: BorderRadius.circular(StoryForgeTheme.badgeRadius),
        boxShadow: DesignShadows.glowSoft(rarityColor),
      ),
      child: Text(
        content.rarity.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildUnlockButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onUnlock,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasEnoughGems ? DesignColors.rarityEpic : Colors.grey,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StoryForgeTheme.buttonRadius),
          ),
          elevation: hasEnoughGems ? 4 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.diamond, size: StoryForgeTheme.iconSizeRegular),
            SizedBox(width: DesignSpacing.sm),
            Text(
              'Unlock for ${content.unlockCost} Gems',
              style: DesignTypography.ctaBold.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.dBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(DesignSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Background (video or image)
          _buildBackground(),

          // Layer 2: Blur overlay (if locked)
          if (!isUnlocked) _buildLockedOverlay(),

          // Layer 3: Info overlay (always visible)
          _buildInfoOverlay(context),
        ],
      ),
    );
  }
}
