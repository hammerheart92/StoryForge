class CreateGalleryItemRequest {
  final String storyId;
  final String contentType;
  final String? contentCategory;
  final String title;
  final String? description;
  final int unlockCost;
  final String? rarity;
  final String? unlockCondition;
  final String? contentUrl;
  final String? thumbnailUrl;
  final int? displayOrder;

  CreateGalleryItemRequest({
    required this.storyId,
    required this.contentType,
    this.contentCategory,
    required this.title,
    this.description,
    required this.unlockCost,
    this.rarity,
    this.unlockCondition,
    this.contentUrl,
    this.thumbnailUrl,
    this.displayOrder,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'storyId': storyId,
      'contentType': contentType,
      'title': title,
      'unlockCost': unlockCost,
    };
    if (contentCategory != null) json['contentCategory'] = contentCategory;
    if (description != null) json['description'] = description;
    if (rarity != null) json['rarity'] = rarity;
    if (unlockCondition != null) json['unlockCondition'] = unlockCondition;
    if (contentUrl != null) json['contentUrl'] = contentUrl;
    if (thumbnailUrl != null) json['thumbnailUrl'] = thumbnailUrl;
    if (displayOrder != null) json['displayOrder'] = displayOrder;
    return json;
  }
}

class UpdateGalleryItemRequest {
  final String? contentType;
  final String? contentCategory;
  final String? title;
  final String? description;
  final int? unlockCost;
  final String? rarity;
  final String? unlockCondition;
  final String? contentUrl;
  final String? thumbnailUrl;
  final int? displayOrder;

  UpdateGalleryItemRequest({
    this.contentType,
    this.contentCategory,
    this.title,
    this.description,
    this.unlockCost,
    this.rarity,
    this.unlockCondition,
    this.contentUrl,
    this.thumbnailUrl,
    this.displayOrder,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (contentType != null) json['contentType'] = contentType;
    if (contentCategory != null) json['contentCategory'] = contentCategory;
    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (unlockCost != null) json['unlockCost'] = unlockCost;
    if (rarity != null) json['rarity'] = rarity;
    if (unlockCondition != null) json['unlockCondition'] = unlockCondition;
    if (contentUrl != null) json['contentUrl'] = contentUrl;
    if (thumbnailUrl != null) json['thumbnailUrl'] = thumbnailUrl;
    if (displayOrder != null) json['displayOrder'] = displayOrder;
    return json;
  }
}
