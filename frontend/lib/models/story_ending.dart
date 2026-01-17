/// Model for story ending information
///
/// Maps to backend EndingSummary DTO from /api/narrative/{storyId}/endings
class StoryEnding {
  final String id;
  final String title;
  final String description;
  final bool discovered;
  final DateTime? discoveredAt;

  StoryEnding({
    required this.id,
    required this.title,
    required this.description,
    required this.discovered,
    this.discoveredAt,
  });

  factory StoryEnding.fromJson(Map<String, dynamic> json) {
    return StoryEnding(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      discovered: json['discovered'] as bool? ?? false,
      discoveredAt: json['discoveredAt'] != null
          ? DateTime.parse(json['discoveredAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'discovered': discovered,
      'discoveredAt': discoveredAt?.toIso8601String(),
    };
  }

  StoryEnding copyWith({
    String? id,
    String? title,
    String? description,
    bool? discovered,
    DateTime? discoveredAt,
  }) {
    return StoryEnding(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      discovered: discovered ?? this.discovered,
      discoveredAt: discoveredAt ?? this.discoveredAt,
    );
  }

  @override
  String toString() {
    return 'StoryEnding{id: $id, title: $title, discovered: $discovered}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoryEnding && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
