// lib/widgets/gem_counter_widget.dart
// Compact gem balance display widget for AppBar

import 'package:flutter/material.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/shadows.dart';
import '../theme/storyforge_theme.dart';

/// Displays user's gem balance with diamond icon.
/// Designed for use in AppBar actions.
///
/// Usage:
/// ```dart
/// AppBar(
///   actions: [
///     Padding(
///       padding: EdgeInsets.only(right: 16),
///       child: Center(child: GemCounterWidget(gemBalance: 100)),
///     ),
///   ],
/// )
/// ```
class GemCounterWidget extends StatelessWidget {
  final int gemBalance;

  const GemCounterWidget({required this.gemBalance, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm + 4, vertical: DesignSpacing.xs + 2), // 12, 6
      decoration: BoxDecoration(
        color: DesignColors.rarityEpic,
        borderRadius: BorderRadius.circular(StoryForgeTheme.pillRadius),
        boxShadow: DesignShadows.glowSoft(DesignColors.rarityEpic),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.diamond,
            size: 18, // Non-standard icon size
            color: Colors.white,
          ),
          SizedBox(width: DesignSpacing.xs),
          Text(
            '$gemBalance',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
