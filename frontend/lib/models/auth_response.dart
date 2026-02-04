import 'auth_user.dart';

class AuthResponse {
  final String token;
  final AuthUser user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: AuthUser(
        userId: json['userId'],
        username: json['username'],
        email: json['email'],
        role: json['role'],
      ),
    );
  }
}