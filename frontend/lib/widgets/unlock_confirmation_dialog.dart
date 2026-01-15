// lib/widgets/unlock_confirmation_dialog.dart
// Confirmation dialog for unlocking gallery content

import 'package:flutter/material.dart';
import '../models/gallery_content.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/storyforge_theme.dart';

/// Dialog that confirms user wants to spend gems to unlock content.
/// Shows item details, cost, current balance, and balance after unlock.
///
/// Returns `true` if user confirms, `false` if cancelled.
///
/// Usage:
/// ```dart
/// final confirmed = await showDialog<bool>(
///   context: context,
///   builder: (_) => UnlockConfirmationDialog(
///     content: item,
///     currentBalance: gemBalance,
///   ),
/// );
/// if (confirmed == true) {
///   // Proceed with unlock
/// }
/// ```
class UnlockConfirmationDialog extends StatelessWidget {
  final GalleryContent content;
  final int currentBalance;

  const UnlockConfirmationDialog({
    required this.content,
    required this.currentBalance,
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

  @override
  Widget build(BuildContext context) {
    final canAfford = currentBalance >= content.unlockCost;
    final balanceAfter = currentBalance - content.unlockCost;

    return AlertDialog(
      title: const Text('Unlock Content?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item preview
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(DesignSpacing.sm),
                decoration: BoxDecoration(
                  color: _getRarityColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(StoryForgeTheme.inputRadius),
                ),
                child: Icon(
                  _getContentTypeIcon(),
                  size: StoryForgeTheme.iconSizeLarge,
                  color: _getRarityColor(),
                ),
              ),
              SizedBox(width: DesignSpacing.sm + 4), // 12
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: DesignSpacing.xs),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignSpacing.xs + 2, // 6
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getRarityColor(),
                        borderRadius: BorderRadius.circular(StoryForgeTheme.chipRadius),
                      ),
                      child: Text(
                        content.rarity.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          const Divider(),
          SizedBox(height: DesignSpacing.md),
          // Cost info
          _buildInfoRow(
            'Cost:',
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.diamond, size: 18, color: DesignColors.rarityEpic), // Non-standard icon size
                SizedBox(width: DesignSpacing.xs),
                Text(
                  '${content.unlockCost}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Your balance:',
            Text(
              '$currentBalance gems',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: canAfford ? Colors.green : Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'After unlock:',
            Text(
              '$balanceAfter gems',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: balanceAfter >= 0 ? null : Colors.red,
              ),
            ),
          ),
          if (!canAfford) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, size: 18, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Not enough gems!',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: canAfford ? () => Navigator.pop(context, true) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignColors.rarityEpic,
            foregroundColor: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_open, size: 18), // Non-standard icon size
              SizedBox(width: DesignSpacing.xs),
              Text('Unlock'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        value,
      ],
    );
  }
}
