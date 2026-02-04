class AuthUser {
  final int userId;
  final String username;
  final String email;
  final String role;

  AuthUser({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
  });

  bool get isCreator => role == 'CREATOR';
  bool get isUser => role == 'USER';

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'role': role,
    };
  }
}