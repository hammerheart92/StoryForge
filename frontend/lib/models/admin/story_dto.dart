class StoryDto {
  final int id;
  final String storyId;
  final String title;
  final String? description;
  final String? coverImageUrl;
  final int createdByUserId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool published;

  StoryDto({
    required this.id,
    required this.storyId,
    required this.title,
    this.description,
    this.coverImageUrl,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
    required this.published,
  });

  factory StoryDto.fromJson(Map<String, dynamic> json) {
    return StoryDto(
      id: json['id'] as int,
      storyId: json['storyId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      createdByUserId: json['createdByUserId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      published: json['published'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storyId': storyId,
      'title': title,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'createdByUserId': createdByUserId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'published': published,
    };
  }

  StoryDto copyWith({
    int? id,
    String? storyId,
    String? title,
    String? description,
    String? coverImageUrl,
    int? createdByUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? published,
  }) {
    return StoryDto(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      published: published ?? this.published,
    );
  }
}
