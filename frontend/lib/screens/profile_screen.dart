// lib/screens/profile_screen.dart
// ProfileScreen - Central hub for user stats and settings
// Features profile header, stats grid, and settings menu

import 'package:flutter/material.dart';
import '../services/stats_service.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      // Transparent for gradient background
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: DesignColors.dPrimaryText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Merriweather',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: DesignColors.dPrimaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        // Dark gradient background (same as HomeScreen)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E), // Dark blue-gray (top)
              Color(0xFF121417), // Near black (middle)
              Color(0xFF0D0D0D), // Deeper black (bottom)
            ],
            stops: [0.0, 0.5, 1.0],
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
                // Max width for desktop
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section 1: Profile Header
                    _ProfileHeader(totalStories: _stats.totalStories),

                    const SizedBox(height: DesignSpacing.xl),

                    // Section 2: Stats Grid (3x2)
                    _StatsGrid(stats: _stats),

                    const SizedBox(height: DesignSpacing.xl),

                    // Section 3: Settings List
                    const _SettingsList(),

                    const SizedBox(height: DesignSpacing.xl),
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

  const _ProfileHeader({required this.totalStories});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: DesignColors.dSurfaces,
        borderRadius: BorderRadius.circular(16),
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
              color: const Color(0xFF1A2828),
            ),
            child: const Icon(
              Icons.auto_stories,
              color: DesignColors.highlightTeal,
              size: 32,
            ),
          ),

          const SizedBox(width: DesignSpacing.lg),

          // Name and stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Storyteller',
                  style: TextStyle(
                    fontFamily: 'Merriweather',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: DesignColors.dPrimaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalStories ${totalStories == 1 ? 'Story' : 'Stories'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: DesignColors.dSecondaryText,
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

  const _StatsGrid({required this.stats});

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
              color: DesignColors.dSecondaryText,
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
              accentColor: DesignColors.dSecondaryText,
            ),
            _StatCard(
              value: stats.choicesMade.toString(),
              label: 'Choices',
              accentColor: DesignColors.dSecondaryText,
            ),
            _StatCard(
              value: stats.timeSpentMinutes.toString(),
              label: 'Minutes',
              accentColor: DesignColors.highlightTeal,
            ),
            _StatCard(
              value: stats.narratorMessages.toString(),
              label: 'Narrator',
              accentColor: DesignColors.highlightTeal,
            ),
            _StatCard(
              value: stats.ilyraMessages.toString(),
              label: 'Ilyra',
              accentColor: DesignColors.highlightPurple,
            ),
            _StatCard(
              value: stats.totalStories.toString(),
              label: 'Stories',
              accentColor: DesignColors.dSecondaryText,
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

  const _StatCard({
    required this.value,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignColors.dSurfaces,
        borderRadius: BorderRadius.circular(16),
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
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: DesignColors.dPrimaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: DesignColors.dSecondaryText,
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

/// Settings menu list
class _SettingsList extends StatelessWidget {
  const _SettingsList();

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
            'SETTINGS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: DesignColors.dSecondaryText,
            ),
          ),
        ),

        // Settings container
        Container(
          decoration: BoxDecoration(
            color: DesignColors.dSurfaces,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Animation Speed
              _SettingsItem(
                icon: Icons.speed,
                iconColor: DesignColors.highlightTeal,
                title: 'Animation Speed',
                subtitle: '20ms per character',
                onTap: () {
                  // TODO: Implement in Phase 3
                },
              ),

              _buildDivider(),

              // Text Size
              _SettingsItem(
                icon: Icons.text_fields,
                iconColor: DesignColors.highlightTeal,
                title: 'Text Size',
                subtitle: 'Medium',
                onTap: () {
                  // TODO: Implement in Phase 3
                },
              ),

              _buildDivider(),

              // Language
              _SettingsItem(
                icon: Icons.language,
                iconColor: DesignColors.highlightTeal,
                title: 'Language',
                subtitle: 'English',
                onTap: () {
                  // TODO: Implement in Phase 3
                },
              ),

              _buildDivider(),

              // Clear Data
              _SettingsItem(
                icon: Icons.delete_forever,
                iconColor: DesignColors.dDanger,
                title: 'Clear All Data',
                subtitle: 'Delete all stories and settings',
                onTap: () {
                  // TODO: Implement in Phase 4
                },
              ),

              _buildDivider(),

              // About
              _SettingsItem(
                icon: Icons.info_outline,
                iconColor: DesignColors.dSecondaryText,
                title: 'About StoryForge',
                subtitle: 'Version 1.0.0',
                showChevron: false,
                onTap: () {
                  // TODO: Implement in Phase 4
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: DesignColors.dBackground.withOpacity(0.5),
      indent: 56,
    );
  }
}

/// Individual settings item widget
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool showChevron;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.showChevron = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSpacing.md,
            vertical: DesignSpacing.md,
          ),
          child: Row(
            children: [
              // Leading icon
              Icon(
                icon,
                color: iconColor,
                size: 24,
              ),

              const SizedBox(width: DesignSpacing.md),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: DesignColors.dPrimaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: DesignColors.dSecondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing chevron
              if (showChevron)
                Icon(
                  Icons.chevron_right,
                  color: DesignColors.dSecondaryText,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
