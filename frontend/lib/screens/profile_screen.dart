// lib/screens/profile_screen.dart
// ProfileScreen - User profile with stats
// Settings moved to dedicated SettingsScreen

import 'package:flutter/material.dart';
import '../services/stats_service.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/storyforge_theme.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserStats _stats = UserStats.empty();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await StatsService.calculateStats();
    if (mounted) {
      setState(() {
        _stats = stats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: StoryForgeTheme.getPrimaryTextColor(Theme.of(context).brightness),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Merriweather',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: StoryForgeTheme.getPrimaryTextColor(Theme.of(context).brightness),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: StoryForgeTheme.getGradientColors(Theme.of(context).brightness),
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? DesignSpacing.xl : DesignSpacing.lg,
              vertical: DesignSpacing.md,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section 1: Profile Header
                    _ProfileHeader(totalStories: _stats.totalStories, isDark: isDark),

                    SizedBox(height: DesignSpacing.xl),

                    // Section 2: Stats Grid (3x2)
                    _StatsGrid(stats: _stats, isDark: isDark),

                    SizedBox(height: DesignSpacing.xl),

                    // Section 3: Settings Navigation Button
                    _SettingsNavigationButton(
                      isDark: isDark,
                      onDataCleared: () {
                        // Refresh stats when data is cleared
                        _loadStats();
                      },
                    ),

                    SizedBox(height: DesignSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Profile header with avatar and user info
class _ProfileHeader extends StatelessWidget {
  final int totalStories;
  final bool isDark;

  const _ProfileHeader({
    required this.totalStories,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
        borderRadius: BorderRadius.circular(StoryForgeTheme.pillRadius),
        border: Border.all(
          color: DesignColors.highlightTeal.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: DesignColors.highlightTeal,
                width: 2,
              ),
              color: isDark ? const Color(0xFF1A2828) : const Color(0xFFE8F4F4),
            ),
            child: const Icon(
              Icons.auto_stories,
              color: DesignColors.highlightTeal,
              size: 32,
            ),
          ),

          SizedBox(width: DesignSpacing.lg),

          // Name and stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Storyteller',
                  style: TextStyle(
                    fontFamily: 'Merriweather',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
                  ),
                ),
                SizedBox(height: DesignSpacing.xs),
                Text(
                  '$totalStories ${totalStories == 1 ? 'Story' : 'Stories'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stats grid displaying 6 stat cards in 3x2 layout
class _StatsGrid extends StatelessWidget {
  final UserStats stats;
  final bool isDark;

  const _StatsGrid({
    required this.stats,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(
            left: DesignSpacing.xs,
            bottom: DesignSpacing.md,
          ),
          child: Text(
            'YOUR JOURNEY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
            ),
          ),
        ),

        // 3x2 Grid of stat cards
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [
            _StatCard(
              value: stats.totalMessages.toString(),
              label: 'Messages',
              accentColor: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
              isDark: isDark,
            ),
            _StatCard(
              value: stats.choicesMade.toString(),
              label: 'Choices',
              accentColor: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
              isDark: isDark,
            ),
            _StatCard(
              value: stats.timeSpentMinutes.toString(),
              label: 'Minutes',
              accentColor: DesignColors.highlightTeal,
              isDark: isDark,
            ),
            _StatCard(
              value: stats.narratorMessages.toString(),
              label: 'Narrator',
              accentColor: DesignColors.highlightTeal,
              isDark: isDark,
            ),
            _StatCard(
              value: stats.ilyraMessages.toString(),
              label: 'Ilyra',
              accentColor: DesignColors.highlightPurple,
              isDark: isDark,
            ),
            _StatCard(
              value: stats.totalStories.toString(),
              label: 'Stories',
              accentColor: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }
}

/// Individual stat card widget
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color accentColor;
  final bool isDark;

  const _StatCard({
    required this.value,
    required this.label,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
        borderRadius: BorderRadius.circular(StoryForgeTheme.pillRadius),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
            ),
          ),
          SizedBox(height: DesignSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Navigation button to Settings screen
class _SettingsNavigationButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onDataCleared;

  const _SettingsNavigationButton({
    required this.isDark,
    required this.onDataCleared,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
        borderRadius: BorderRadius.circular(StoryForgeTheme.pillRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
            // Refresh stats if data was cleared
            if (result == true) {
              onDataCleared();
            }
          },
          borderRadius: BorderRadius.circular(StoryForgeTheme.pillRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.md,
              vertical: DesignSpacing.md,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  color: DesignColors.highlightTeal,
                  size: StoryForgeTheme.iconSizeMedium,
                ),
                SizedBox(width: DesignSpacing.md),
                Expanded(
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? DesignColors.dPrimaryText
                          : DesignColors.lPrimaryText,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark
                      ? DesignColors.dSecondaryText
                      : DesignColors.lSecondaryText,
                  size: StoryForgeTheme.iconSizeRegular,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
