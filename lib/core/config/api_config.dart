import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

class ApiConfig {
  // Built-in environment define overrides
  static const String _envHost = String.fromEnvironment('API_HOST', defaultValue: '');
  static const String _envPort = String.fromEnvironment('API_PORT', defaultValue: '8080');

  static String _activeHost = '';
  static String _activePort = _envPort;

  /// Initialize configured host from shared preferences or platform defaults
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHost = prefs.getString(AppStrings.customApiHostKey);
    final savedPort = prefs.getString(AppStrings.customApiPortKey);

    if (savedHost != null && savedHost.trim().isNotEmpty) {
      _activeHost = savedHost.trim();
    } else if (_envHost.isNotEmpty) {
      _activeHost = _envHost;
    } else {
      _activeHost = _detectDefaultHost();
    }

    if (savedPort != null && savedPort.trim().isNotEmpty) {
      _activePort = savedPort.trim();
    } else {
      _activePort = _envPort;
    }
  }

  /// Automatically detect optimal default host based on target platform
  static String _detectDefaultHost() {
    if (kIsWeb) {
      return 'localhost';
    }
    try {
      if (Platform.isAndroid) {
        // 10.0.2.2 is the special Android Emulator alias to localhost of host PC
        return '10.0.2.2';
      } else if (Platform.isIOS || Platform.isMacOS) {
        return 'localhost';
      }
    } catch (_) {
      // Fallback
    }
    return 'localhost';
  }

  static String get currentHost => _activeHost.isNotEmpty ? _activeHost : _detectDefaultHost();
  static String get currentPort => _activePort;

  /// Returns full base URL like: http://10.0.2.2:8080/api
  static String get baseUrl => 'http://$currentHost:$currentPort/api';

  /// Save new custom host and port at runtime (e.g. from Settings screen)
  static Future<void> setCustomHost(String host, {String port = '8080'}) async {
    final prefs = await SharedPreferences.getInstance();
    _activeHost = host.trim();
    _activePort = port.trim();
    await prefs.setString(AppStrings.customApiHostKey, _activeHost);
    await prefs.setString(AppStrings.customApiPortKey, _activePort);
  }

  /// Reset to auto-detected default
  static Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppStrings.customApiHostKey);
    await prefs.remove(AppStrings.customApiPortKey);
    _activeHost = _detectDefaultHost();
    _activePort = _envPort;
  }
}
