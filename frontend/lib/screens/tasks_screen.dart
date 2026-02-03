// lib/screens/tasks_screen.dart
// Main Tasks screen with check-in and achievements

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tasks_providers.dart';
import '../services/tasks_service.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/typography.dart';
import '../theme/storyforge_theme.dart';
import '../widgets/check_in_card.dart';
import '../widgets/achievement_card.dart';
import '../widgets/gem_counter_widget.dart';
import 'package:http/http.dart' as http;

/// Tasks screen displaying daily check-in and achievements
///
/// Design tokens used:
/// - Background: Theme-aware (dBackground/lBackground)
/// - Heading: DesignTypography.headingMedium, Theme-aware text
/// - Section padding: DesignSpacing.md (16)
/// - Section spacing: DesignSpacing.lg (24)
/// - Card spacing: DesignSpacing.md (16)
///
/// Features:
/// - Pull-to-refresh
/// - Loading state
/// - Error state with retry
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  bool _isCheckInLoading = false;
  String? _claimingAchievementId;
  int _gemBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadGemBalance();
  }

  Future<void> _loadGemBalance() async {
    final balance = await TasksService().getGemBalance();
    if (mounted && balance != null) {
      setState(() {
        _gemBalance = balance;
      });
    }
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(tasksProvider);
    ref.invalidate(tasksBadgeCountProvider);
    await _loadGemBalance();
  }

  Future<void> _handleCheckIn() async {
    setState(() {
      _isCheckInLoading = true;
    });

    try {
      final success = await ref.read(tasksProvider.notifier).performCheckIn();

      if (mounted) {
        if (success) {
          await _loadGemBalance();
          ref.invalidate(tasksBadgeCountProvider);
          _showMessage('Check-in successful! Gems awarded.', isSuccess: true);
        } else {
          _showMessage('Check-in failed. Please try again.');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckInLoading = false;
        });
      }
    }
  }

  Future<void> _handleClaimAchievement(String achievementId) async {
    setState(() {
      _claimingAchievementId = achievementId;
    });

    try {
      final success = await ref.read(tasksProvider.notifier).claimAchievement(achievementId);

      if (mounted) {
        if (success) {
          await _loadGemBalance();
          ref.invalidate(tasksBadgeCountProvider);
          _showMessage('Achievement claimed! Gems awarded.', isSuccess: true);
        } else {
          _showMessage('Failed to claim achievement. Please try again.');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _claimingAchievementId = null;
        });
      }
    }
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
              size: StoryForgeTheme.iconSizeRegular,
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? DesignColors.lSuccess : DesignColors.lDanger,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignColors.dBackground : DesignColors.lBackground,
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: DesignTypography.headingMedium.copyWith(
            color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
          ),
        ),
        actions: [
          // Gem counter
          Padding(
            padding: EdgeInsets.only(right: DesignSpacing.md),
            child: Center(
              child: GemCounterWidget(gemBalance: _gemBalance),
            ),
          ),
        ],
      ),
      body: tasksState.isLoading
          ? _buildLoadingState(isDark)
          : tasksState.error != null
              ? _buildErrorState(tasksState.error!, isDark)
              : RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: _buildContent(tasksState, isDark),
                ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: DesignSpacing.md),
          Text(
            'Loading tasks...',
            style: DesignTypography.bodyRegular.copyWith(
              color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: StoryForgeTheme.iconSizeXL,
              color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              'Failed to load tasks',
              style: DesignTypography.ctaBold.copyWith(
                color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              error,
              textAlign: TextAlign.center,
              style: DesignTypography.bodyRegular.copyWith(
                color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
                fontSize: 14,
              ),
            ),
            SizedBox(height: DesignSpacing.lg),
            ElevatedButton.icon(
              onPressed: _handleRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: StoryForgeTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(TasksState tasksState, bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(DesignSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily Check-in Card
          CheckInCard(
            data: tasksState.checkInData,
            onCheckIn: _handleCheckIn,
            isLoading: _isCheckInLoading,
            isDark: isDark,
          ),

          SizedBox(height: DesignSpacing.lg),

          // Achievements Section Header
          Text(
            'Achievements',
            style: DesignTypography.headingMedium.copyWith(
              color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
              fontSize: 20,
            ),
          ),

          SizedBox(height: DesignSpacing.sm),

          // Achievement Cards
          ...tasksState.achievements.map((tuple) {
            final achievement = tuple.$1;
            final progress = tuple.$2;

            return Padding(
              padding: EdgeInsets.only(bottom: DesignSpacing.md),
              child: AchievementCard(
                achievement: achievement,
                progress: progress,
                onClaim: () => _handleClaimAchievement(achievement.id),
                isLoading: _claimingAchievementId == achievement.id,
                isDark: isDark,
              ),
            );
          }),

          // Bottom padding for FAB clearance
          SizedBox(height: DesignSpacing.xl),
        ],
      ),
    );
  }
}
