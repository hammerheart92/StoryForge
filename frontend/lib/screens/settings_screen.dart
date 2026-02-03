// lib/screens/settings_screen.dart
// Dedicated settings screen with organized sections
// All styling uses design tokens - NO hardcoded values

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../services/settings_service.dart';
import '../services/story_state_service.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/storyforge_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  AppSettings _settings = const AppSettings();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.loadSettings();
    if (mounted) {
      setState(() => _settings = settings);
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
          'Settings',
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
                    // Section 1: Appearance
                    _buildSectionHeader('APPEARANCE', isDark),
                    _AppearanceSection(
                      onThemeTap: _showThemeDialog,
                      isDark: isDark,
                    ),

                    SizedBox(height: DesignSpacing.xl),

                    // Section 2: Preferences
                    _buildSectionHeader('PREFERENCES', isDark),
                    _PreferencesSection(
                      settings: _settings,
                      onAnimationSpeedTap: _showAnimationSpeedDialog,
                      onTextSizeTap: _showTextSizeDialog,
                      onLanguageTap: _showLanguageDialog,
                      isDark: isDark,
                    ),

                    SizedBox(height: DesignSpacing.xl),

                    // Section 3: Data & Privacy
                    _buildSectionHeader('DATA & PRIVACY', isDark),
                    _DataPrivacySection(
                      onClearDataTap: _showClearDataDialog,
                      isDark: isDark,
                    ),

                    SizedBox(height: DesignSpacing.xl),

                    // Section 4: About
                    _buildSectionHeader('ABOUT', isDark),
                    _AboutSection(
                      onAboutTap: _showAboutDialog,
                      isDark: isDark,
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

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(
        left: DesignSpacing.xs,
        bottom: DesignSpacing.md,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
        ),
      ),
    );
  }

  // ==================== THEME DIALOG ====================

  Future<void> _showThemeDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMode = ref.read(themeModeProvider);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
        title: Text(
          'Theme',
          style: TextStyle(
            color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(ThemeMode.light, 'Light', Icons.light_mode, currentMode, isDark),
            _buildThemeOption(ThemeMode.dark, 'Dark', Icons.dark_mode, currentMode, isDark),
            _buildThemeOption(ThemeMode.system, 'System', Icons.settings_brightness, currentMode, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(ThemeMode mode, String label, IconData icon, ThemeMode currentMode, bool isDark) {
    return RadioListTile<ThemeMode>(
      title: Row(
        children: [
          Icon(
            icon,
            color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
            size: StoryForgeTheme.iconSizeRegular,
          ),
          SizedBox(width: DesignSpacing.sm),
          Text(
            label,
            style: TextStyle(
              color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
            ),
          ),
        ],
      ),
      value: mode,
      groupValue: currentMode,
      activeColor: DesignColors.highlightTeal,
      onChanged: (value) async {
        if (value != null) {
          await ref.read(themeProvider.notifier).setThemeMode(value);
          if (context.mounted) Navigator.pop(context);
        }
      },
    );
  }

  // ==================== ANIMATION SPEED DIALOG ====================

  Future<void> _showAnimationSpeedDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double speed = _settings.animationSpeed.toDouble();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
          title: Text(
            'Animation Speed',
            style: TextStyle(
              color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
            ),
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
                inactiveColor: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
                label: '${speed.round()}ms',
                onChanged: (value) {
                  setDialogState(() {
                    speed = value;
                  });
                },
              ),
              Text(
                '${speed.round()}ms per character',
                style: TextStyle(
                  color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
                ),
              ),
              SizedBox(height: DesignSpacing.sm),
              Text(
                speed == 0
                    ? 'Instant'
                    : speed < 15
                        ? 'Fast'
                        : speed < 30
                            ? 'Normal'
                            : 'Slow',
                style: TextStyle(
                  color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final newSettings = _settings.copyWith(animationSpeed: speed.round());
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

  // ==================== TEXT SIZE DIALOG ====================

  Future<void> _showTextSizeDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
        title: Text(
          'Text Size',
          style: TextStyle(
            color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextSizeOption(TextSize.small, 'Small', 14, isDark),
            _buildTextSizeOption(TextSize.medium, 'Medium', 16, isDark),
            _buildTextSizeOption(TextSize.large, 'Large', 18, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSizeOption(TextSize size, String label, double fontSize, bool isDark) {
    return RadioListTile<TextSize>(
      title: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
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

  // ==================== LANGUAGE DIALOG ====================

  Future<void> _showLanguageDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
        title: Text(
          'Language',
          style: TextStyle(
            color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('en', 'English', isDark),
            _buildLanguageOption('ro', 'Romana', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String label, bool isDark) {
    return RadioListTile<String>(
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
        ),
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

  // ==================== CLEAR DATA DIALOG ====================

  Future<void> _showClearDataDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
        title: Text(
          'Clear All Data?',
          style: TextStyle(
            color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
          ),
        ),
        content: Text(
          'This will delete all your stories, choices, and settings. '
          'This action cannot be undone.',
          style: TextStyle(
            color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? DesignColors.dDanger : DesignColors.lDanger,
            ),
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
          _settings = const AppSettings();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared'),
            duration: Duration(seconds: 2),
          ),
        );

        // Pop back after clearing
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context, true); // true = data was cleared
          }
        });
      }
    }
  }

  // ==================== ABOUT DIALOG ====================

  Future<void> _showAboutDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
        title: Text(
          'About StoryForge',
          style: TextStyle(
            color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
              ),
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              'AI-powered interactive storytelling',
              style: TextStyle(
                color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
              ),
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              'Built with Flutter & Claude API',
              style: TextStyle(
                color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
              ),
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
}

// ==================== SECTION WIDGETS ====================

/// Appearance section with theme toggle
class _AppearanceSection extends ConsumerWidget {
  final VoidCallback onThemeTap;
  final bool isDark;

  const _AppearanceSection({
    required this.onThemeTap,
    required this.isDark,
  });

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return _SettingsContainer(
      isDark: isDark,
      children: [
        _SettingsItem(
          icon: Icons.palette_outlined,
          iconColor: DesignColors.highlightPurple,
          title: 'Theme',
          subtitle: _getThemeLabel(themeMode),
          onTap: onThemeTap,
          isDark: isDark,
        ),
      ],
    );
  }
}

/// Preferences section
class _PreferencesSection extends StatelessWidget {
  final AppSettings settings;
  final VoidCallback onAnimationSpeedTap;
  final VoidCallback onTextSizeTap;
  final VoidCallback onLanguageTap;
  final bool isDark;

  const _PreferencesSection({
    required this.settings,
    required this.onAnimationSpeedTap,
    required this.onTextSizeTap,
    required this.onLanguageTap,
    required this.isDark,
  });

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

  @override
  Widget build(BuildContext context) {
    return _SettingsContainer(
      isDark: isDark,
      children: [
        _SettingsItem(
          icon: Icons.speed,
          iconColor: DesignColors.highlightTeal,
          title: 'Animation Speed',
          subtitle: '${settings.animationSpeed}ms per character',
          onTap: onAnimationSpeedTap,
          isDark: isDark,
        ),
        _buildDivider(isDark),
        _SettingsItem(
          icon: Icons.text_fields,
          iconColor: DesignColors.highlightTeal,
          title: 'Text Size',
          subtitle: _getTextSizeLabel(settings.textSize),
          onTap: onTextSizeTap,
          isDark: isDark,
        ),
        _buildDivider(isDark),
        _SettingsItem(
          icon: Icons.language,
          iconColor: DesignColors.highlightTeal,
          title: 'Language',
          subtitle: settings.language == 'en' ? 'English' : 'Romana',
          onTap: onLanguageTap,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: (isDark ? DesignColors.dBackground : DesignColors.lBackground)
          .withOpacity(0.5),
      indent: 56,
    );
  }
}

/// Data & Privacy section
class _DataPrivacySection extends StatelessWidget {
  final VoidCallback onClearDataTap;
  final bool isDark;

  const _DataPrivacySection({
    required this.onClearDataTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsContainer(
      isDark: isDark,
      children: [
        _SettingsItem(
          icon: Icons.delete_forever,
          iconColor: isDark ? DesignColors.dDanger : DesignColors.lDanger,
          title: 'Clear All Data',
          subtitle: 'Delete all stories and settings',
          onTap: onClearDataTap,
          isDark: isDark,
        ),
      ],
    );
  }
}

/// About section
class _AboutSection extends StatelessWidget {
  final VoidCallback onAboutTap;
  final bool isDark;

  const _AboutSection({
    required this.onAboutTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsContainer(
      isDark: isDark,
      children: [
        _SettingsItem(
          icon: Icons.info_outline,
          iconColor: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
          title: 'About StoryForge',
          subtitle: 'Version 1.0.0',
          showChevron: false,
          onTap: onAboutTap,
          isDark: isDark,
        ),
      ],
    );
  }
}

// ==================== SHARED WIDGETS ====================

/// Container for settings sections
class _SettingsContainer extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _SettingsContainer({
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
        borderRadius: BorderRadius.circular(StoryForgeTheme.pillRadius),
      ),
      child: Column(children: children),
    );
  }
}

/// Individual settings item (reusable)
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool showChevron;
  final VoidCallback onTap;
  final bool isDark;

  const _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.showChevron = true,
    required this.onTap,
    required this.isDark,
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
              Icon(
                icon,
                color: iconColor,
                size: StoryForgeTheme.iconSizeMedium,
              ),
              SizedBox(width: DesignSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? DesignColors.dPrimaryText
                            : DesignColors.lPrimaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? DesignColors.dSecondaryText
                            : DesignColors.lSecondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              if (showChevron)
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
    );
  }
}
