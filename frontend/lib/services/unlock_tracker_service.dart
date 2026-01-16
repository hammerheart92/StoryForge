// lib/services/unlock_tracker_service.dart
// Service for converting gallery unlocks to achievement progress

import '../models/gallery_content.dart';
import 'achievement_service.dart';

/// Service for tracking gallery unlocks and updating achievement progress
///
/// Tracking keys:
/// - total_unlocked: All content
/// - scenes_unlocked: Scene type
/// - characters_unlocked: Character type
/// - lore_unlocked: Lore type
/// - legendary_unlocked: Legendary rarity
/// - stories_started: Save slots created
class UnlockTrackerService {
  /// Map content type to tracking key
  static const Map<String, String> _typeToTrackingKey = {
    'scene': 'scenes_unlocked',
    'character': 'characters_unlocked',
    'lore': 'lore_unlocked',
    // 'extra' type doesn't have a dedicated tracking key
  };

  /// Track a gallery content unlock and update achievement progress
  ///
  /// Returns list of achievement IDs that became claimable
  static Future<List<String>> trackUnlock(GalleryContent content) async {
    try {
      print('🔓 Tracking unlock: ${content.title} (${content.contentType}, ${content.rarity})');

      final newlyClaimable = <String>[];

      // 1. Increment total_unlocked counter
      final totalClaimable = await AchievementService.incrementCounter('total_unlocked');
      newlyClaimable.addAll(totalClaimable);

      // 2. Increment type-specific counter
      final typeKey = _typeToTrackingKey[content.contentType.toLowerCase()];
      if (typeKey != null) {
        final typeClaimable = await AchievementService.incrementCounter(typeKey);
        newlyClaimable.addAll(typeClaimable);
      }

      // 3. If legendary rarity, increment legendary_unlocked
      if (content.rarity.toLowerCase() == 'legendary') {
        final legendaryClaimable = await AchievementService.incrementCounter('legendary_unlocked');
        newlyClaimable.addAll(legendaryClaimable);
      }

      // Remove duplicates and return
      final uniqueClaimable = newlyClaimable.toSet().toList();

      if (uniqueClaimable.isNotEmpty) {
        print('🏆 Newly claimable achievements: $uniqueClaimable');
      }

      return uniqueClaimable;
    } catch (e) {
      print('❌ Error tracking unlock: $e');
      return [];
    }
  }

  /// Track a story start (when creating a new save slot)
  ///
  /// Returns list of achievement IDs that became claimable
  static Future<List<String>> trackStoryStart() async {
    try {
      print('📖 Tracking story start');

      final claimable = await AchievementService.incrementCounter('stories_started');

      if (claimable.isNotEmpty) {
        print('🏆 Newly claimable achievements: $claimable');
      }

      return claimable;
    } catch (e) {
      print('❌ Error tracking story start: $e');
      return [];
    }
  }
}
