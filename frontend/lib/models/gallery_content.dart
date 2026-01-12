/// Model for gallery content items (unlockable artwork, lore, etc.)
///
/// Maps to backend StoryContent entity from /api/gallery/{storyId}/content
class GalleryContent {
  final int contentId;
  final String storyId;
  final String contentType; // scene, character, lore, extra
  final String? contentCategory;
  final String title;
  final String? description;
  final int unlockCost;
  final String rarity; // common, rare, epic, legendary
  final String? unlockCondition;
  final String? contentUrl;
  final String? thumbnailUrl;
  final int displayOrder;

  GalleryContent({
    required this.contentId,
    required this.storyId,
    required this.contentType,
    this.contentCategory,
    required this.title,
    this.description,
    required this.unlockCost,
    required this.rarity,
    this.unlockCondition,
    this.contentUrl,
    this.thumbnailUrl,
    required this.displayOrder,
  });

  factory GalleryContent.fromJson(Map<String, dynamic> json) {
    return GalleryContent(
      contentId: json['contentId'] as int,
      storyId: json['storyId'] as String,
      contentType: json['contentType'] as String,
      contentCategory: json['contentCategory'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      unlockCost: json['unlockCost'] as int,
      rarity: json['rarity'] as String? ?? 'common',
      unlockCondition: json['unlockCondition'] as String?,
      contentUrl: json['contentUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      displayOrder: json['displayOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contentId': contentId,
      'storyId': storyId,
      'contentType': contentType,
      'contentCategory': contentCategory,
      'title': title,
      'description': description,
      'unlockCost': unlockCost,
      'rarity': rarity,
      'unlockCondition': unlockCondition,
      'contentUrl': contentUrl,
      'thumbnailUrl': thumbnailUrl,
      'displayOrder': displayOrder,
    };
  }

  @override
  String toString() {
    return 'GalleryContent{id: $contentId, title: $title, cost: $unlockCost, rarity: $rarity}';
  }
}
