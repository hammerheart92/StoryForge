class Session {
  final int id;
  final String name;
  final DateTime createdAt;
  final int messageCount;

  Session({
    required this.id,
    required this.name,
    required this.createdAt,
    this.messageCount = 0,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      messageCount: json['messageCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'messageCount': messageCount,
    };
  }
}