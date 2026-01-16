// lib/widgets/tasks_icon_button.dart
// Tasks icon button with badge counter for Gallery AppBar

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tasks_providers.dart';
import '../theme/tokens/colors.dart';
import '../theme/storyforge_theme.dart';

/// Tasks icon button with badge showing unclaimed count
///
/// Design tokens used:
/// - Icon: Icons.assignment, StoryForgeTheme.iconSizeMedium (24)
/// - Badge: DesignColors.lDanger background, white text
///
/// Badge logic:
/// - Hidden when count == 0
/// - Shows number if ≤ 9
/// - Shows "9+" if > 9
class TasksIconButton extends ConsumerWidget {
  const TasksIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeCountAsync = ref.watch(tasksBadgeCountProvider);

    return badgeCountAsync.when(
      data: (count) => _buildButton(context, count),
      loading: () => _buildButton(context, 0),
      error: (error, stack) => _buildButton(context, 0),
    );
  }

  Widget _buildButton(BuildContext context, int badgeCount) {
    return IconButton(
      onPressed: () => Navigator.pushNamed(context, '/tasks'),
      tooltip: 'Tasks',
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main icon
          Icon(
            Icons.assignment,
            size: StoryForgeTheme.iconSizeMedium,
            color: Colors.white,
          ),

          // Badge (only show if count > 0)
          if (badgeCount > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  color: DesignColors.lDanger,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    badgeCount > 9 ? '9+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
