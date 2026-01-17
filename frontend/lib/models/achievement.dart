/// Achievement system models for StoryForge
///
/// Tracks unlockable achievements with rarity levels and gem rewards

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

enum AchievementStatus {
  locked,
  claimable,
  claimed,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final int gemReward;
  final AchievementRarity rarity;
  final String trackingKey;
  final int targetCount;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.gemReward,
    required this.rarity,
    required this.trackingKey,
    required this.targetCount,
  });

  /// Static list of all 7 achievements in StoryForge
  /// Updated with realistic targets based on actual gallery content:
  /// - 3 scenes, 3 characters, 2 lore, 2 extras = 10 total items
  /// - 1 legendary item (The Sea Witch)
  static const List<Achievement> all = [
    Achievement(
      id: 'first_steps',
      title: 'First Steps',
      description: 'Unlock 1 item',
      gemReward: 10,
      rarity: AchievementRarity.common,
      trackingKey: 'total_unlocked',
      targetCount: 1,
    ),
    Achievement(
      id: 'scene_explorer',
      title: 'Scene Explorer',
      description: 'Unlock 3 scenes',
      gemReward: 50,
      rarity: AchievementRarity.common,
      trackingKey: 'scenes_unlocked',
      targetCount: 3, // Fixed: was 5, now matches actual 3 scenes
    ),
    Achievement(
      id: 'character_collector',
      title: 'Character Collector',
      description: 'Unlock 3 characters',
      gemReward: 100,
      rarity: AchievementRarity.rare,
      trackingKey: 'characters_unlocked',
      targetCount: 3, // Fixed: was 4, now matches actual 3 characters
    ),
    Achievement(
      id: 'lore_master',
      title: 'Lore Master',
      description: 'Unlock 2 lore items',
      gemReward: 75,
      rarity: AchievementRarity.common,
      trackingKey: 'lore_unlocked',
      targetCount: 2, // Fixed: was 10, now matches actual 2 lore items
    ),
    Achievement(
      id: 'legendary_hunter',
      title: 'Legendary Hunter',
      description: 'Unlock 1 legendary item',
      gemReward: 150,
      rarity: AchievementRarity.epic,
      trackingKey: 'legendary_unlocked',
      targetCount: 1, // Fixed: was 3, now matches actual 1 legendary (The Sea Witch)
    ),
    Achievement(
      id: 'gallery_completionist',
      title: 'Gallery Completionist',
      description: 'Unlock 10 total items',
      gemReward: 300,
      rarity: AchievementRarity.legendary,
      trackingKey: 'total_unlocked',
      targetCount: 10, // Fixed: was 50, now matches actual 10 total items
    ),
    Achievement(
      id: 'story_starter',
      title: 'Story Starter',
      description: 'Start 3 stories',
      gemReward: 25,
      rarity: AchievementRarity.common,
      trackingKey: 'stories_started',
      targetCount: 3,
    ),
    Achievement(
      id: 'first_story',
      title: 'First Story',
      description: 'Complete 1 story',
      gemReward: 10,
      rarity: AchievementRarity.common,
      trackingKey: 'stories_completed',
      targetCount: 1,
    ),
  ];

  /// Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all achievements for a specific tracking key
  static List<Achievement> getByTrackingKey(String trackingKey) {
    return all.where((a) => a.trackingKey == trackingKey).toList();
  }

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, rarity: $rarity, gems: $gemReward)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}