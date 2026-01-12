// lib/widgets/gallery_content_card.dart
// Beautiful card widget for gallery content items with blur effect and rarity styling

import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/gallery_content.dart';

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

  const GalleryContentCard({
    required this.content,
    required this.isUnlocked,
    required this.hasEnoughGems,
    required this.onUnlockTap,
    super.key,
  });

  Color _getRarityColor() {
    switch (content.rarity.toLowerCase()) {
      case 'legendary':
        return Colors.purple;
      case 'epic':
        return Colors.amber;
      case 'rare':
        return Colors.blue;
      case 'common':
      default:
        return Colors.grey.shade600;
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

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rarityColor,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9), // 12 - 3 (border width)
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail area (60% of card)
            Expanded(
              flex: 3,
              child: _buildThumbnailArea(rarityColor),
            ),
            // Info area (40% of card)
            Expanded(
              flex: 2,
              child: _buildInfoArea(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailArea(Color rarityColor) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background with rarity tint
        Container(
          color: rarityColor.withOpacity(0.15),
          child: Center(
            child: Icon(
              _getContentTypeIcon(),
              size: 48,
              color: rarityColor.withOpacity(0.5),
            ),
          ),
        ),

        // Blur overlay for locked content
        if (!isUnlocked) _buildLockedOverlay(),

        // Rarity badge (top-left, always visible)
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: rarityColor,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
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
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                size: 14,
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock,
                size: 32,
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
      padding: const EdgeInsets.all(10),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            content.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: Colors.green),
          SizedBox(width: 4),
          Text(
            'Unlocked',
            style: TextStyle(
              color: Colors.green,
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
        onPressed: hasEnoughGems ? onUnlockTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasEnoughGems ? Colors.amber.shade700 : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: hasEnoughGems ? 2 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.diamond, size: 14),
            const SizedBox(width: 4),
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
