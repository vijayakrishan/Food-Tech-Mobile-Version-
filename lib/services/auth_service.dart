import '../core/network/api_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/api_response.dart';
import '../models/auth_response.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  /// Authenticate with username or email and password
  Future<AuthResponse> login(String usernameOrEmail, String password) async {
    final responseData = await _client.post(
      '/auth/login',
      data: {
        'username': usernameOrEmail.trim(),
        'password': password,
      },
    );

    final apiResponse = ApiResponse<AuthResponse>.fromJson(
      responseData as Map<String, dynamic>,
      (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );

    if (apiResponse.success && apiResponse.data != null) {
      final authData = apiResponse.data!;
      await SecureStorageService.saveToken(authData.token);
      await SecureStorageService.saveUser(authData);
      return authData;
    } else {
      throw Exception(apiResponse.message.isNotEmpty ? apiResponse.message : 'Login failed');
    }
  }

  /// Register a new account
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    String? organization,
    String role = 'ROLE_PRODUCER',
  }) async {
    final responseData = await _client.post(
      '/auth/register',
      data: {
        'username': username.trim(),
        'email': email.trim(),
        'password': password,
        'firstName': firstName?.trim() ?? '',
        'lastName': lastName?.trim() ?? '',
        'phone': phone?.trim() ?? '',
        'organization': organization?.trim() ?? '',
        'role': role,
      },
    );

    final apiResponse = ApiResponse<AuthResponse>.fromJson(
      responseData as Map<String, dynamic>,
      (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );

    if (apiResponse.success && apiResponse.data != null) {
      final authData = apiResponse.data!;
      await SecureStorageService.saveToken(authData.token);
      await SecureStorageService.saveUser(authData);
      return authData;
    } else {
      throw Exception(apiResponse.message.isNotEmpty ? apiResponse.message : 'Registration failed');
    }
  }

  /// Fetch currently authenticated user profile
  Future<AuthResponse?> getCurrentUser() async {
    try {
      final responseData = await _client.get('/auth/me');
      final apiResponse = ApiResponse<AuthResponse>.fromJson(
        responseData as Map<String, dynamic>,
        (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
      );
      if (apiResponse.success && apiResponse.data != null) {
        final user = apiResponse.data!;
        await SecureStorageService.saveUser(user);
        return user;
      }
    } catch (_) {
      // Fallback to locally cached user
    }
    return await SecureStorageService.getUser();
  }

  /// Log out and clear tokens
  Future<void> logout() async {
    await SecureStorageService.clearAuth();
  }

  /// Retrieve locally stored session
  Future<AuthResponse?> getStoredUser() async {
    return await SecureStorageService.getUser();
  }

  /// Check if user has an active token
  Future<bool> isAuthenticated() async {
    final token = await SecureStorageService.getToken();
    return token != null && token.isNotEmpty;
  }
}
