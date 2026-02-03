// lib/widgets/achievement_card.dart
// Achievement card with progress bar, rarity styling, and claim button

import 'dart:math';
import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/achievement_progress.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/shadows.dart';
import '../theme/tokens/typography.dart';
import '../theme/storyforge_theme.dart';

/// Achievement card with progress bar and rarity-based styling
///
/// Design tokens used:
/// - Card: Theme-aware surfaces, StoryForgeTheme.cardRadius (12)
/// - Rarity badge: DesignColors.rarity*, StoryForgeTheme.chipRadius (4)
/// - Claimable glow: DesignShadows.glowIntense(rarityColor)
/// - Title: DesignTypography.ctaBold, Theme-aware text
/// - Description: DesignTypography.bodyRegular @ 14px, Theme-aware text
/// - Progress bar: 6px height, StoryForgeTheme.chipRadius (4)
/// - Gem badge: rarityColor @ 20%, StoryForgeTheme.badgeRadius (6)
/// - Claim button: rarityColor, StoryForgeTheme.buttonRadius (12)
///
/// States:
/// - Locked: Gray progress, "Locked" button disabled
/// - Claimable: Rarity glow, "Get now →" button enabled
/// - Claimed: "Completed ✓" badge, no button
class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final AchievementProgress progress;
  final VoidCallback onClaim;
  final bool isLoading;
  final bool isDark;

  const AchievementCard({
    required this.achievement,
    required this.progress,
    required this.onClaim,
    this.isLoading = false,
    required this.isDark,
    super.key,
  });

  /// Get rarity color based on achievement rarity
  Color get _rarityColor {
    switch (achievement.rarity) {
      case AchievementRarity.legendary:
        return DesignColors.rarityLegendary;
      case AchievementRarity.epic:
        return DesignColors.rarityEpic;
      case AchievementRarity.rare:
        return DesignColors.rarityRare;
      case AchievementRarity.common:
        return DesignColors.rarityCommon;
    }
  }

  /// Get rarity name for badge
  String get _rarityName {
    return achievement.rarity.name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isClaimable = progress.status == AchievementStatus.claimable;
    final isClaimed = progress.status == AchievementStatus.claimed;
    final isLocked = progress.status == AchievementStatus.locked;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      decoration: BoxDecoration(
        color: isClaimed
            ? surfaceColor.withValues(alpha: 0.6)
            : surfaceColor,
        borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
        border: Border.all(
          color: isClaimable ? _rarityColor : _rarityColor.withValues(alpha: 0.3),
          width: isClaimable ? 2 : 1,
        ),
        boxShadow: isClaimable
            ? DesignShadows.glowIntense(_rarityColor)
            : DesignShadows.sm,
      ),
      padding: EdgeInsets.all(DesignSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Rarity badge + Title
          Row(
            children: [
              // Rarity badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSpacing.sm,
                  vertical: DesignSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _rarityColor,
                  borderRadius: BorderRadius.circular(StoryForgeTheme.chipRadius),
                ),
                child: Text(
                  _rarityName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(width: DesignSpacing.sm),
              // Title
              Expanded(
                child: Text(
                  achievement.title,
                  style: DesignTypography.ctaBold.copyWith(
                    color: isClaimed ? secondaryText : primaryText,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: DesignSpacing.sm),

          // Description
          Text(
            achievement.description,
            style: DesignTypography.bodyRegular.copyWith(
              fontSize: 14,
              color: secondaryText,
            ),
          ),

          SizedBox(height: DesignSpacing.md),

          // Progress section
          _buildProgressSection(isLocked, isClaimed),

          SizedBox(height: DesignSpacing.md),

          // Bottom row: Gem reward + Action button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Gem reward badge
              _buildGemBadge(),
              // Action button or completed badge
              _buildActionWidget(isClaimable, isClaimed, isLocked),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(bool isLocked, bool isClaimed) {
    final progressPercent = progress.currentCount / achievement.targetCount;
    final clampedProgress = progressPercent.clamp(0.0, 1.0);
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final disabledColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 12,
                color: secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${min(progress.currentCount, achievement.targetCount)}/${achievement.targetCount}',
              style: TextStyle(
                fontSize: 12,
                color: isClaimed ? DesignColors.lSuccess : _rarityColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: DesignSpacing.xs),
        // Progress bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: disabledColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(StoryForgeTheme.chipRadius),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Fill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: constraints.maxWidth * clampedProgress,
                    decoration: BoxDecoration(
                      color: isLocked ? disabledColor : _rarityColor,
                      borderRadius: BorderRadius.circular(StoryForgeTheme.chipRadius),
                      boxShadow: clampedProgress > 0 && !isLocked
                          ? DesignShadows.glowSoft(_rarityColor)
                          : null,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGemBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _rarityColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(StoryForgeTheme.badgeRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.diamond,
            size: StoryForgeTheme.iconSizeSmall,
            color: _rarityColor,
          ),
          SizedBox(width: DesignSpacing.xs),
          Text(
            '+${achievement.gemReward}',
            style: TextStyle(
              color: _rarityColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionWidget(bool isClaimable, bool isClaimed, bool isLocked) {
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final disabledColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;

    if (isClaimed) {
      // Completed badge
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.sm,
          vertical: DesignSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: DesignColors.lSuccess.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(StoryForgeTheme.badgeRadius),
          border: Border.all(
            color: DesignColors.lSuccess.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: StoryForgeTheme.iconSizeSmall,
              color: DesignColors.lSuccess,
            ),
            SizedBox(width: DesignSpacing.xs),
            Text(
              'Completed',
              style: TextStyle(
                color: DesignColors.lSuccess,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Claim button (enabled for claimable, disabled for locked)
    return ElevatedButton(
      onPressed: isClaimable && !isLoading ? onClaim : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isClaimable ? _rarityColor : disabledColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: disabledColor,
        disabledForegroundColor: secondaryText,
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StoryForgeTheme.buttonRadius),
        ),
        elevation: isClaimable ? 2 : 0,
      ),
      child: isLoading
          ? SizedBox(
              height: StoryForgeTheme.iconSizeSmall,
              width: StoryForgeTheme.iconSizeSmall,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              isClaimable ? 'Get now →' : 'Locked',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
