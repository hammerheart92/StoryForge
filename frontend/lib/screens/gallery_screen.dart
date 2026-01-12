// lib/screens/gallery_screen.dart
// Phase B: Gallery screen with polished UI and confirmation dialogs

import 'package:flutter/material.dart';
import '../models/gallery_content.dart';
import '../services/gallery_service.dart';
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

class _GalleryScreenState extends State<GalleryScreen> {
  final GalleryService _galleryService = GalleryService();
  final String _userId = 'default';

  bool _isLoading = true;
  String? _error;
  List<GalleryContent> _content = [];
  Set<int> _unlockedIds = {};
  int _gemBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadGalleryData();
  }

  Future<void> _loadGalleryData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _galleryService.getGalleryContent(widget.storyId);

      setState(() {
        _content = response.content;
        _unlockedIds = response.unlockedIds.toSet();
        _gemBalance = response.gemBalance;
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

    if (_content.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No content available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for unlockable content!',
              style: TextStyle(color: Colors.grey.shade600),
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
      itemCount: _content.length,
      itemBuilder: (context, index) {
        final item = _content[index];
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
