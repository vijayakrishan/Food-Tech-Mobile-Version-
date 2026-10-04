import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_strings.dart';
import '../../models/auth_response.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Save JWT auth token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: AppStrings.tokenKey, value: token);
  }

  /// Retrieve stored JWT auth token
  static Future<String?> getToken() async {
    return await _storage.read(key: AppStrings.tokenKey);
  }

  /// Delete JWT auth token
  static Future<void> deleteToken() async {
    await _storage.delete(key: AppStrings.tokenKey);
  }

  /// Save authenticated user profile
  static Future<void> saveUser(AuthResponse user) async {
    final jsonStr = jsonEncode(user.toJson());
    await _storage.write(key: AppStrings.userKey, value: jsonStr);
  }

  /// Retrieve stored user profile
  static Future<AuthResponse?> getUser() async {
    final jsonStr = await _storage.read(key: AppStrings.userKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return AuthResponse.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Clear all credentials and tokens on logout
  static Future<void> clearAuth() async {
    await _storage.delete(key: AppStrings.tokenKey);
    await _storage.delete(key: AppStrings.userKey);
  }
}
