// lib/screens/gallery_screen.dart
// Phase A: Basic gallery screen with grid of unlockable content

import 'package:flutter/material.dart';
import '../models/gallery_content.dart';
import '../services/gallery_service.dart';

/// Gallery screen displaying unlockable content for a story.
///
/// Phase A: Basic functionality with simple UI.
/// - Fetches content from backend
/// - Shows gem balance
/// - Allows unlocking items
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
      // Fetch content and balance
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

    // Check if enough gems
    if (_gemBalance < item.unlockCost) {
      _showMessage('Not enough gems! Need ${item.unlockCost}, have $_gemBalance');
      return;
    }

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
          // Gem balance badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade700,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.diamond, size: 18, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '$_gemBalance',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      // Temporary FAB for testing - refresh data
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
      return const Center(
        child: Text('No content available for this story'),
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
        final isUnlocked = _unlockedIds.contains(item.contentId);
        return _GalleryItemCard(
          item: item,
          isUnlocked: isUnlocked,
          canAfford: _gemBalance >= item.unlockCost,
          onUnlock: () => _handleUnlock(item),
        );
      },
    );
  }
}

/// Card widget for a single gallery content item
class _GalleryItemCard extends StatelessWidget {
  final GalleryContent item;
  final bool isUnlocked;
  final bool canAfford;
  final VoidCallback onUnlock;

  const _GalleryItemCard({
    required this.item,
    required this.isUnlocked,
    required this.canAfford,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thumbnail area
          Expanded(
            flex: 3,
            child: Container(
              color: _getRarityColor().withOpacity(0.2),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder icon based on content type
                  Center(
                    child: Icon(
                      _getContentTypeIcon(),
                      size: 48,
                      color: _getRarityColor(),
                    ),
                  ),
                  // Locked overlay
                  if (!isUnlocked)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Icon(
                          Icons.lock,
                          size: 32,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  // Unlocked checkmark
                  if (isUnlocked)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  // Rarity badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRarityColor(),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.rarity.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info area
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Status/Action row
                  if (isUnlocked)
                    const Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'Unlocked',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canAfford ? onUnlock : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          textStyle: const TextStyle(fontSize: 11),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.diamond, size: 14),
                            const SizedBox(width: 4),
                            Text('${item.unlockCost}'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor() {
    switch (item.rarity.toLowerCase()) {
      case 'legendary':
        return Colors.orange;
      case 'epic':
        return Colors.purple;
      case 'rare':
        return Colors.blue;
      case 'common':
      default:
        return Colors.grey;
    }
  }

  IconData _getContentTypeIcon() {
    switch (item.contentType.toLowerCase()) {
      case 'scene':
        return Icons.landscape;
      case 'character':
        return Icons.person;
      case 'lore':
        return Icons.menu_book;
      case 'extra':
        return Icons.star;
      default:
        return Icons.image;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TEMPORARY: Add this FAB to any existing screen to test navigation
// ═══════════════════════════════════════════════════════════════════════════
// floatingActionButton: FloatingActionButton(
//   onPressed: () => Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (_) => const GalleryScreen(storyId: 'pirates'),
//     ),
//   ),
//   child: const Icon(Icons.image),
// ),
// ═══════════════════════════════════════════════════════════════════════════
