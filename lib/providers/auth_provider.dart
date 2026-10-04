import 'package:flutter_riverpod/legacy.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';
import 'api_provider.dart';

class AuthState {
  final bool isLoading;
  final AuthResponse? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null && user!.token.isNotEmpty;

  AuthState copyWith({
    bool? isLoading,
    AuthResponse? user,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState(isLoading: true)) {
    checkAuthStatus();
  }

  /// Check existing token on app launch
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        state = state.copyWith(isLoading: false, user: user);
      } else {
        state = state.copyWith(isLoading: false, clearUser: true);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false, clearUser: true);
    }
  }

  /// Perform login with username or email
  Future<bool> login(String usernameOrEmail, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.login(usernameOrEmail, password);
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Perform registration
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    String? organization,
    String role = 'ROLE_PRODUCER',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        organization: organization,
        role: role,
      );
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Log out
  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(isLoading: false);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
