import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_state_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/tokens/colors.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/storyforge_theme.dart';
import '../../widgets/admin_navigation_drawer.dart';
import 'gallery_item_form_screen.dart';
import 'gallery_items_list_screen.dart';
import 'stories_list_screen.dart';
import 'story_form_screen.dart';

class AdminLayoutScreen extends ConsumerStatefulWidget {
  const AdminLayoutScreen({super.key});

  @override
  ConsumerState<AdminLayoutScreen> createState() => _AdminLayoutScreenState();
}

class _AdminLayoutScreenState extends ConsumerState<AdminLayoutScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brightness = Theme.of(context).brightness;

    // Security check: Only CREATOR can access
    if (!authState.isCreator) {
      return _UnauthorizedScreen(isDark: isDark, brightness: brightness);
    }

    final selectedSection = ref.watch(selectedAdminSectionProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: StoryForgeTheme.getPrimaryTextColor(brightness),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.admin_panel_settings,
              color: DesignColors.highlightTeal,
              size: StoryForgeTheme.iconSizeRegular,
            ),
            const SizedBox(width: DesignSpacing.sm),
            Text(
              'Creator Tools',
              style: TextStyle(
                fontFamily: 'Merriweather',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: StoryForgeTheme.getPrimaryTextColor(brightness),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      drawer: const AdminNavigationDrawer(),
      floatingActionButton: _buildFab(selectedSection, context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: StoryForgeTheme.getGradientColors(brightness),
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: _buildSectionContent(selectedSection, isDark),
        ),
      ),
    );
  }

  Widget? _buildFab(AdminSection section, BuildContext context) {
    switch (section) {
      case AdminSection.stories:
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StoryFormScreen(),
              ),
            );
          },
          backgroundColor: DesignColors.highlightTeal,
          child: const Icon(Icons.add, color: Colors.white),
        );
      case AdminSection.gallery:
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GalleryItemFormScreen(),
              ),
            );
          },
          backgroundColor: DesignColors.highlightTeal,
          child: const Icon(Icons.add, color: Colors.white),
        );
    }
  }

  Widget _buildSectionContent(AdminSection section, bool isDark) {
    switch (section) {
      case AdminSection.stories:
        return const StoriesListScreen();
      case AdminSection.gallery:
        return const GalleryItemsListScreen();
    }
  }
}

/// Shown when a non-CREATOR user somehow accesses this screen
class _UnauthorizedScreen extends StatelessWidget {
  final bool isDark;
  final Brightness brightness;

  const _UnauthorizedScreen({
    required this.isDark,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: StoryForgeTheme.getPrimaryTextColor(brightness),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: StoryForgeTheme.getGradientColors(brightness),
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: StoryForgeTheme.iconSizeXL,
                color: DesignColors.lDanger.withOpacity(0.7),
              ),
              const SizedBox(height: DesignSpacing.md),
              Text(
                'Unauthorized',
                style: TextStyle(
                  fontFamily: 'Merriweather',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
                ),
              ),
              const SizedBox(height: DesignSpacing.sm),
              Text(
                'Only creators can access this area',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
