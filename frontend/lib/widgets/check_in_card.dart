// lib/widgets/check_in_card.dart
// Daily check-in card with 7-day calendar and streak tracking

import 'package:flutter/material.dart';
import '../models/check_in_data.dart';
import '../services/check_in_service.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/shadows.dart';
import '../theme/tokens/typography.dart';
import '../theme/storyforge_theme.dart';

/// Daily check-in card with 7-day calendar row
///
/// Design tokens used:
/// - Card: Theme-aware surfaces, StoryForgeTheme.cardRadius (12), DesignShadows.md
/// - Streak icon: DesignColors.rarityEpic (amber)
/// - Day card: StoryForgeTheme.inputRadius (8)
/// - Claimed day: DesignColors.lSuccess + glowSoft
/// - Current day: DesignColors.rarityEpic + glowIntense
/// - CTA button: DesignColors.rarityEpic, StoryForgeTheme.buttonRadius (12)
class CheckInCard extends StatelessWidget {
  final CheckInData data;
  final VoidCallback onCheckIn;
  final bool isLoading;
  final bool isDark;

  const CheckInCard({
    required this.data,
    required this.onCheckIn,
    this.isLoading = false,
    required this.isDark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final canClaim = CheckInService.canClaimToday(data);
    final nextDay = _getNextClaimDay();
    final nextReward = CheckInData.getRewardForDay(nextDay);
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final disabledColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
        boxShadow: DesignShadows.md,
      ),
      padding: EdgeInsets.all(DesignSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Title + Streak
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Check in',
                style: DesignTypography.ctaBold.copyWith(
                  color: primaryText,
                  fontSize: 18,
                ),
              ),
              // Streak indicator
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: DesignColors.rarityEpic,
                    size: StoryForgeTheme.iconSizeMedium,
                  ),
                  SizedBox(width: DesignSpacing.xs),
                  Text(
                    'Streak: ${data.currentStreak} ${data.currentStreak == 1 ? 'day' : 'days'}',
                    style: DesignTypography.bodyRegular.copyWith(
                      color: DesignColors.rarityEpic,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: DesignSpacing.xs),

          // Subtitle
          Text(
            'Check in now to get gems!',
            style: DesignTypography.bodyRegular.copyWith(
              color: secondaryText,
              fontSize: 14,
            ),
          ),

          SizedBox(height: DesignSpacing.md),

          // 7-day calendar row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final dayNum = index + 1;
              final isClaimed = data.isDayClaimed(dayNum);
              final isCurrentDay = _isCurrentClaimDay(dayNum);
              final reward = CheckInData.getRewardForDay(dayNum);

              return _DayCard(
                dayNumber: dayNum,
                reward: reward,
                isClaimed: isClaimed,
                isCurrentDay: isCurrentDay && canClaim,
                isPast: dayNum < nextDay && !isClaimed,
                isDark: isDark,
              );
            }),
          ),

          SizedBox(height: DesignSpacing.md),

          // CTA Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canClaim && !isLoading ? onCheckIn : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.rarityEpic,
                foregroundColor: Colors.white,
                disabledBackgroundColor: disabledColor,
                disabledForegroundColor: secondaryText,
                padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(StoryForgeTheme.buttonRadius),
                ),
                elevation: canClaim ? 4 : 0,
              ),
              child: isLoading
                  ? SizedBox(
                      height: StoryForgeTheme.iconSizeMedium,
                      width: StoryForgeTheme.iconSizeMedium,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          canClaim ? Icons.card_giftcard : Icons.check_circle,
                          size: StoryForgeTheme.iconSizeMedium,
                        ),
                        SizedBox(width: DesignSpacing.sm),
                        Text(
                          canClaim
                              ? 'Check now! Gain +$nextReward'
                              : 'Claimed today',
                          style: DesignTypography.ctaBold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        if (canClaim) ...[
                          SizedBox(width: DesignSpacing.xs),
                          Icon(
                            Icons.diamond,
                            size: StoryForgeTheme.iconSizeRegular,
                            color: Colors.white,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get the next day to claim (1-7)
  int _getNextClaimDay() {
    if (data.lastCheckInDate == null) {
      return 1;
    }
    if (CheckInService.shouldResetStreak(data)) {
      return 1;
    }
    return data.currentDay >= 7 ? 1 : data.currentDay + 1;
  }

  /// Check if this is the current day to claim
  bool _isCurrentClaimDay(int dayNum) {
    return dayNum == _getNextClaimDay();
  }
}

/// Individual day card in the calendar row
class _DayCard extends StatelessWidget {
  final int dayNumber;
  final int reward;
  final bool isClaimed;
  final bool isCurrentDay;
  final bool isPast;
  final bool isDark;

  const _DayCard({
    required this.dayNumber,
    required this.reward,
    required this.isClaimed,
    required this.isCurrentDay,
    required this.isPast,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final disabledColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    // Determine colors and effects based on state
    Color backgroundColor;
    Color borderColor;
    List<BoxShadow>? boxShadow;
    double opacity = 1.0;

    if (isClaimed) {
      // Claimed: green glow
      backgroundColor = DesignColors.lSuccess.withValues(alpha: 0.2);
      borderColor = DesignColors.lSuccess;
      boxShadow = DesignShadows.glowSoft(DesignColors.lSuccess);
    } else if (isCurrentDay) {
      // Current day to claim: gold glow
      backgroundColor = DesignColors.rarityEpic.withValues(alpha: 0.2);
      borderColor = DesignColors.rarityEpic;
      boxShadow = DesignShadows.glowIntense(DesignColors.rarityEpic);
    } else {
      // Future/unavailable days: dimmed
      backgroundColor = surfaceColor;
      borderColor = disabledColor;
      opacity = isPast ? 0.5 : 0.7;
    }

    return Opacity(
      opacity: opacity,
      child: Container(
        width: 42,
        padding: EdgeInsets.symmetric(
          vertical: DesignSpacing.sm,
          horizontal: DesignSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(StoryForgeTheme.inputRadius),
          border: Border.all(
            color: borderColor,
            width: isCurrentDay ? 2 : 1,
          ),
          boxShadow: boxShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day label
            Text(
              'D$dayNumber',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isClaimed
                    ? DesignColors.lSuccess
                    : isCurrentDay
                        ? DesignColors.rarityEpic
                        : secondaryText,
              ),
            ),
            SizedBox(height: DesignSpacing.xs),

            // Checkmark or reward amount
            if (isClaimed)
              Icon(
                Icons.check,
                size: StoryForgeTheme.iconSizeSmall,
                color: DesignColors.lSuccess,
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+$reward',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isCurrentDay
                          ? DesignColors.rarityEpic
                          : secondaryText,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
