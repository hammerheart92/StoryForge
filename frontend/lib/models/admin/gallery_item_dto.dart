class GalleryItemDto {
  final int contentId;
  final String storyId;
  final String contentType;
  final String? contentCategory;
  final String title;
  final String? description;
  final int unlockCost;
  final String rarity;
  final String? unlockCondition;
  final String? contentUrl;
  final String? thumbnailUrl;
  final int displayOrder;
  final int createdByUserId;
  final DateTime createdAt;

  GalleryItemDto({
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
    required this.createdByUserId,
    required this.createdAt,
  });

  factory GalleryItemDto.fromJson(Map<String, dynamic> json) {
    return GalleryItemDto(
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
      createdByUserId: json['createdByUserId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
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
      'createdByUserId': createdByUserId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  GalleryItemDto copyWith({
    int? contentId,
    String? storyId,
    String? contentType,
    String? contentCategory,
    String? title,
    String? description,
    int? unlockCost,
    String? rarity,
    String? unlockCondition,
    String? contentUrl,
    String? thumbnailUrl,
    int? displayOrder,
    int? createdByUserId,
    DateTime? createdAt,
  }) {
    return GalleryItemDto(
      contentId: contentId ?? this.contentId,
      storyId: storyId ?? this.storyId,
      contentType: contentType ?? this.contentType,
      contentCategory: contentCategory ?? this.contentCategory,
      title: title ?? this.title,
      description: description ?? this.description,
      unlockCost: unlockCost ?? this.unlockCost,
      rarity: rarity ?? this.rarity,
      unlockCondition: unlockCondition ?? this.unlockCondition,
      contentUrl: contentUrl ?? this.contentUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      displayOrder: displayOrder ?? this.displayOrder,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
