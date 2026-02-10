import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_state_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/storyforge_theme.dart';

class AdminNavigationDrawer extends ConsumerWidget {
  const AdminNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSection = ref.watch(selectedAdminSectionProvider);
    final authState = ref.watch(authProvider);
    final userEmail = authState.user?.email ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? DesignColors.dBackground : DesignColors.lBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          DrawerHeader(
            decoration: const BoxDecoration(
              color: DesignColors.highlightTeal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: StoryForgeTheme.iconSizeXL,
                  color: Colors.white,
                ),
                const SizedBox(height: DesignSpacing.sm),
                Text(
                  'Creator Tools',
                  style: TextStyle(
                    fontFamily: 'Merriweather',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: DesignSpacing.xs),
                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Stories Management
          _DrawerItem(
            icon: Icons.book,
            title: 'Stories Management',
            selected: selectedSection == AdminSection.stories,
            isDark: isDark,
            onTap: () {
              ref.read(selectedAdminSectionProvider.notifier).state =
                  AdminSection.stories;
              Navigator.pop(context);
            },
          ),

          // Gallery Items
          _DrawerItem(
            icon: Icons.photo_library,
            title: 'Gallery Items',
            selected: selectedSection == AdminSection.gallery,
            isDark: isDark,
            onTap: () {
              ref.read(selectedAdminSectionProvider.notifier).state =
                  AdminSection.gallery;
              Navigator.pop(context);
            },
          ),

          const Divider(),

          // Back to App
          _DrawerItem(
            icon: Icons.arrow_back,
            title: 'Back to App',
            selected: false,
            isDark: isDark,
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pop(context); // Go back to profile
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected
            ? DesignColors.highlightTeal
            : (isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText),
        size: StoryForgeTheme.iconSizeMedium,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected
              ? DesignColors.highlightTeal
              : (isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText),
        ),
      ),
      selected: selected,
      selectedTileColor: DesignColors.highlightTeal.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StoryForgeTheme.inputRadius),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.xs,
      ),
      onTap: onTap,
    );
  }
}
