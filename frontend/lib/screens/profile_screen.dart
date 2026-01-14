// lib/screens/profile_screen.dart
// ProfileScreen - Central hub for user stats and settings
// Features profile header, stats grid, and settings menu

import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/stats_service.dart';
import '../services/story_state_service.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/storyforge_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserStats _stats = UserStats.empty();
  AppSettings _settings = const AppSettings();

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadSettings();
  }

  Future<void> _loadStats() async {
    final stats = await StatsService.calculateStats();
    if (mounted) {
      setState(() {
        _stats = stats;
      });
    }
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.loadSettings();
    if (mounted) {
      setState(() {
        _settings = settings;
      });
    }
  }

  // ==================== SETTINGS DIALOGS ====================

  /// Animation Speed dialog with slider (0-100ms)
  Future<void> _showAnimationSpeedDialog() async {
    double speed = _settings.animationSpeed.toDouble();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: DesignColors.dSurfaces,
          title: const Text(
            'Animation Speed',
            style: TextStyle(color: DesignColors.dPrimaryText),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: speed,
                min: 0,
                max: 100,
                divisions: 20,
                activeColor: DesignColors.highlightTeal,
                inactiveColor: DesignColors.dSurfaces,
                label: '${speed.round()}ms',
                onChanged: (value) {
                  setDialogState(() {
                    speed = value;
                  });
                },
              ),
              Text(
                '${speed.round()}ms per character',
                style: const TextStyle(color: DesignColors.dPrimaryText),
              ),
              const SizedBox(height: DesignSpacing.sm),
              Text(
                speed == 0
                    ? 'Instant'
                    : speed < 15
                        ? 'Fast'
                        : speed < 30
                            ? 'Normal'
                            : 'Slow',
                style: TextStyle(color: DesignColors.dSecondaryText),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: DesignColors.dSecondaryText),
              ),
            ),
            TextButton(
              onPressed: () async {
                final newSettings =
                    _settings.copyWith(animationSpeed: speed.round());
                await SettingsService.saveSettings(newSettings);
                if (mounted) {
                  setState(() {
                    _settings = newSettings;
                  });
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: DesignColors.highlightTeal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Text Size dialog with radio buttons (Small/Medium/Large)
  Future<void> _showTextSizeDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignColors.dSurfaces,
        title: const Text(
          'Text Size',
          style: TextStyle(color: DesignColors.dPrimaryText),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextSizeOption(TextSize.small, 'Small', 14),
            _buildTextSizeOption(TextSize.medium, 'Medium', 16),
            _buildTextSizeOption(TextSize.large, 'Large', 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSizeOption(TextSize size, String label, double fontSize) {
    return RadioListTile<TextSize>(
      title: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: DesignColors.dPrimaryText,
        ),
      ),
      value: size,
      groupValue: _settings.textSize,
      activeColor: DesignColors.highlightTeal,
      onChanged: (value) async {
        if (value != null) {
          final newSettings = _settings.copyWith(textSize: value);
          await SettingsService.saveSettings(newSettings);
          if (mounted) {
            setState(() {
              _settings = newSettings;
            });
          }
          if (context.mounted) Navigator.pop(context);
        }
      },
    );
  }

  /// Language dialog with radio buttons (English/Română)
  Future<void> _showLanguageDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignColors.dSurfaces,
        title: const Text(
          'Language',
          style: TextStyle(color: DesignColors.dPrimaryText),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('en', 'English'),
            _buildLanguageOption('ro', 'Română'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String label) {
    return RadioListTile<String>(
      title: Text(
        label,
        style: const TextStyle(color: DesignColors.dPrimaryText),
      ),
      value: code,
      groupValue: _settings.language,
      activeColor: DesignColors.highlightTeal,
      onChanged: (value) async {
        if (value != null) {
          final newSettings = _settings.copyWith(language: value);
          await SettingsService.saveSettings(newSettings);
          if (mounted) {
            setState(() {
              _settings = newSettings;
            });
          }
          if (context.mounted) Navigator.pop(context);
        }
      },
    );
  }

  /// Clear Data confirmation dialog
  Future<void> _showClearDataDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignColors.dSurfaces,
        title: const Text(
          'Clear All Data?',
          style: TextStyle(color: DesignColors.dPrimaryText),
        ),
        content: const Text(
          'This will delete all your stories, choices, and settings. '
          'This action cannot be undone.',
          style: TextStyle(color: DesignColors.dSecondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: DesignColors.dSecondaryText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: DesignColors.dDanger),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StoryStateService.clearState();
      await SettingsService.saveSettings(const AppSettings());

      if (mounted) {
        setState(() {
          _stats = UserStats.empty();
          _settings = const AppSettings();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared'),
            duration: Duration(seconds: 2),
          ),
        );

        // Pop back with flag that data was cleared
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context, true); // true = data was cleared
          }
        });
      }
    }
  }

  /// About dialog with version info
  Future<void> _showAboutDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignColors.dSurfaces,
        title: const Text(
          'About StoryForge',
          style: TextStyle(color: DesignColors.dPrimaryText),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: DesignColors.dPrimaryText),
            ),
            const SizedBox(height: DesignSpacing.md),
            const Text(
              'AI-powered interactive storytelling',
              style: TextStyle(color: DesignColors.dPrimaryText),
            ),
            const SizedBox(height: DesignSpacing.md),
            Text(
              'Built with Flutter & Claude API',
              style: TextStyle(color: DesignColors.dSecondaryText),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: DesignColors.highlightTeal),
            ),
          ),
        ],
      ),
    );
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
            colors: DesignColors.appGradient,
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
                    _SettingsList(
                      settings: _settings,
                      onAnimationSpeedTap: _showAnimationSpeedDialog,
                      onTextSizeTap: _showTextSizeDialog,
                      onLanguageTap: _showLanguageDialog,
                      onClearDataTap: _showClearDataDialog,
                      onAboutTap: _showAboutDialog,
                    ),

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
                const SizedBox(height: DesignSpacing.xs),
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
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: DesignColors.dPrimaryText,
            ),
          ),
          const SizedBox(height: DesignSpacing.xs),
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
  final AppSettings settings;
  final VoidCallback onAnimationSpeedTap;
  final VoidCallback onTextSizeTap;
  final VoidCallback onLanguageTap;
  final VoidCallback onClearDataTap;
  final VoidCallback onAboutTap;

  const _SettingsList({
    required this.settings,
    required this.onAnimationSpeedTap,
    required this.onTextSizeTap,
    required this.onLanguageTap,
    required this.onClearDataTap,
    required this.onAboutTap,
  });

  /// Get display text for text size
  String _getTextSizeLabel(TextSize size) {
    switch (size) {
      case TextSize.small:
        return 'Small';
      case TextSize.medium:
        return 'Medium';
      case TextSize.large:
        return 'Large';
    }
  }

  /// Get display text for language
  String _getLanguageLabel(String code) {
    return code == 'en' ? 'English' : 'Română';
  }

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
            borderRadius: BorderRadius.circular(StoryForgeTheme.pillRadius),
          ),
          child: Column(
            children: [
              // Animation Speed
              _SettingsItem(
                icon: Icons.speed,
                iconColor: DesignColors.highlightTeal,
                title: 'Animation Speed',
                subtitle: '${settings.animationSpeed}ms per character',
                onTap: onAnimationSpeedTap,
              ),

              _buildDivider(),

              // Text Size
              _SettingsItem(
                icon: Icons.text_fields,
                iconColor: DesignColors.highlightTeal,
                title: 'Text Size',
                subtitle: _getTextSizeLabel(settings.textSize),
                onTap: onTextSizeTap,
              ),

              _buildDivider(),

              // Language
              _SettingsItem(
                icon: Icons.language,
                iconColor: DesignColors.highlightTeal,
                title: 'Language',
                subtitle: _getLanguageLabel(settings.language),
                onTap: onLanguageTap,
              ),

              _buildDivider(),

              // Clear Data
              _SettingsItem(
                icon: Icons.delete_forever,
                iconColor: DesignColors.dDanger,
                title: 'Clear All Data',
                subtitle: 'Delete all stories and settings',
                onTap: onClearDataTap,
              ),

              _buildDivider(),

              // About
              _SettingsItem(
                icon: Icons.info_outline,
                iconColor: DesignColors.dSecondaryText,
                title: 'About StoryForge',
                subtitle: 'Version 1.0.0',
                showChevron: false,
                onTap: onAboutTap,
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
        borderRadius: BorderRadius.circular(StoryForgeTheme.inputRadius),
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
