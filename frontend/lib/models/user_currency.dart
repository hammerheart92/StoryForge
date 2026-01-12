/// Model for user's gem balance and currency stats.
///
/// Maps to backend response from /api/gallery/user/{userId}/balance
class UserCurrency {
  final String userId;
  final int gemBalance;
  final int totalEarned;
  final int totalSpent;

  UserCurrency({
    required this.userId,
    required this.gemBalance,
    required this.totalEarned,
    required this.totalSpent,
  });

  factory UserCurrency.fromJson(Map<String, dynamic> json) {
    return UserCurrency(
      userId: json['userId'] as String? ?? 'default',
      gemBalance: json['gemBalance'] as int? ?? 0,
      totalEarned: json['totalEarned'] as int? ?? 0,
      totalSpent: json['totalSpent'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'gemBalance': gemBalance,
      'totalEarned': totalEarned,
      'totalSpent': totalSpent,
    };
  }

  @override
  String toString() {
    return 'UserCurrency{userId: $userId, balance: $gemBalance, earned: $totalEarned, spent: $totalSpent}';
  }
}
