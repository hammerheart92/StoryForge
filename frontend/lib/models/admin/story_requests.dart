class CreateStoryRequest {
  final String title;
  final String? description;
  final String? coverImageUrl;

  CreateStoryRequest({
    required this.title,
    this.description,
    this.coverImageUrl,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'title': title,
    };
    if (description != null) json['description'] = description;
    if (coverImageUrl != null) json['coverImageUrl'] = coverImageUrl;
    return json;
  }
}

class UpdateStoryRequest {
  final String? title;
  final String? description;
  final String? coverImageUrl;

  UpdateStoryRequest({
    this.title,
    this.description,
    this.coverImageUrl,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (coverImageUrl != null) json['coverImageUrl'] = coverImageUrl;
    return json;
  }
}
