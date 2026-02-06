import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

/// Auth state
class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;
  bool get isCreator => user?.isCreator ?? false;

  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    // Load stored user on initialization
    _loadStoredUser();
  }

  /// Load user from storage
  Future<void> _loadStoredUser() async {
    final user = await _authService.getStoredUser();
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  /// Login
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.login(email: email, password: password);

    if (result['success']) {
      state = state.copyWith(
        user: result['user'],
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
      return false;
    }
  }

  /// Register
  Future<Map<String, dynamic>> register(
      String username,
      String email,
      String password,
      ) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.register(
      username: username,
      email: email,
      password: password,
    );

    state = state.copyWith(isLoading: false);
    return result;
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    state = AuthState(); // Reset to initial state
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth provider - now uses ApiConfig.authBaseUrl
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthService(baseUrl: ApiConfig.authBaseUrl));
});