// lib/screens/gallery_screen.dart
// Phase B: Gallery screen with polished UI and confirmation dialogs

import 'package:flutter/material.dart';
import '../models/gallery_content.dart';
import '../services/gallery_service.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/typography.dart';
import '../widgets/gallery_content_card.dart';
import '../widgets/gem_counter_widget.dart';
import '../widgets/unlock_confirmation_dialog.dart';

/// Gallery screen displaying unlockable content for a story.
///
/// Features:
/// - Beautiful cards with rarity borders and blur effects
/// - Gem counter in app bar
/// - Confirmation dialog before spending gems
/// - Loading and error states
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => GalleryScreen(storyId: 'pirates'),
///   ),
/// );
/// ```
class GalleryScreen extends StatefulWidget {
  final String storyId;

  const GalleryScreen({required this.storyId, super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with SingleTickerProviderStateMixin {
  final GalleryService _galleryService = GalleryService();
  final String _userId = 'default';

  bool _isLoading = true;
  String? _error;
  Set<int> _unlockedIds = {};
  int _gemBalance = 0;

  // Tab navigation state
  late TabController _tabController;
  int _selectedTabIndex = 0;
  List<GalleryContent> _allContent = [];
  List<GalleryContent> _filteredContent = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadGalleryData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _selectedTabIndex = _tabController.index;
      _filterContent();
    });
  }

  void _filterContent() {
    switch (_selectedTabIndex) {
      case 0: // All
        _filteredContent = List.from(_allContent);
        break;
      case 1: // Scenes
        _filteredContent = _allContent
            .where((c) => c.contentType.toLowerCase() == 'scene')
            .toList();
        break;
      case 2: // Characters
        _filteredContent = _allContent
            .where((c) => c.contentType.toLowerCase() == 'character')
            .toList();
        break;
      case 3: // Lore
        _filteredContent = _allContent
            .where((c) => c.contentType.toLowerCase() == 'lore')
            .toList();
        break;
      case 4: // Extras
        _filteredContent = _allContent
            .where((c) => c.contentType.toLowerCase() == 'extra')
            .toList();
        break;
    }
  }

  String _getEmptyStateMessage() {
    switch (_selectedTabIndex) {
      case 0:
        return 'No content available yet.\nComplete stories to earn gems!';
      case 1:
        return 'No scenes unlocked yet.\nKeep playing to discover epic moments!';
      case 2:
        return 'No characters unlocked yet.\nMeet the crew by progressing through stories!';
      case 3:
        return 'No lore unlocked yet.\nUncover the world\'s secrets!';
      case 4:
        return 'No extras unlocked yet.\nCollect special content as you play!';
      default:
        return 'No content available';
    }
  }

  Future<void> _loadGalleryData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _galleryService.getGalleryContent(widget.storyId);

      setState(() {
        _allContent = response.content;
        _unlockedIds = response.unlockedIds.toSet();
        _gemBalance = response.gemBalance;
        _filterContent();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleUnlock(GalleryContent item) async {
    // Check if already unlocked
    if (_unlockedIds.contains(item.contentId)) {
      _showMessage('Already unlocked!');
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => UnlockConfirmationDialog(
        content: item,
        currentBalance: _gemBalance,
      ),
    );

    // User cancelled or dismissed dialog
    if (confirmed != true) return;

    // Proceed with unlock
    try {
      final result = await _galleryService.unlockContent(_userId, item.contentId);

      if (result.success) {
        setState(() {
          _unlockedIds.add(item.contentId);
          _gemBalance = result.newBalance ?? (_gemBalance - item.unlockCost);
        });
        _showMessage('Unlocked "${item.title}"!');
      } else {
        _showMessage(result.message ?? 'Failed to unlock');
      }
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery - ${widget.storyId}'),
        actions: [
          // Gem counter widget
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: GemCounterWidget(gemBalance: _gemBalance)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          labelStyle: DesignTypography.ctaBold.copyWith(fontSize: 14),
          unselectedLabelStyle: DesignTypography.bodyRegular.copyWith(fontSize: 14),
          labelPadding: const EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
          indicatorWeight: 3.0,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Scenes'),
            Tab(text: 'Characters'),
            Tab(text: 'Lore'),
            Tab(text: 'Extras'),
          ],
        ),
      ),
      body: _buildBody(),
      // Refresh FAB (useful for testing)
      floatingActionButton: FloatingActionButton(
        onPressed: _loadGalleryData,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading gallery...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load gallery',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadGalleryData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredContent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateMessage(),
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredContent.length,
      itemBuilder: (context, index) {
        final item = _filteredContent[index];
        return GalleryContentCard(
          content: item,
          isUnlocked: _unlockedIds.contains(item.contentId),
          hasEnoughGems: _gemBalance >= item.unlockCost,
          onUnlockTap: () => _handleUnlock(item),
        );
      },
    );
  }
}
