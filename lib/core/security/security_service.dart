import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

class SecurityService {
  final FlutterSecureStorage _storage;

  SecurityService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  String hashPassword(String password) {
    const salt = 'bello_horizonte_2024_salt';
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }

  Future<void> saveSession(String userId) async {
    await _storage.write(key: AppConstants.sessionUserIdKey, value: userId);
  }

  Future<String?> getSessionUserId() async {
    try {
      return await _storage.read(key: AppConstants.sessionUserIdKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    try {
      await _storage.delete(key: AppConstants.sessionUserIdKey);
      await _storage.delete(key: AppConstants.sessionTokenKey);
    } catch (_) {}
  }

  Future<bool> hasActiveSession() async {
    final userId = await getSessionUserId();
    return userId != null && userId.isNotEmpty;
  }

  Future<void> saveTheme(String theme) async {
    try {
      await _storage.write(key: AppConstants.themeKey, value: theme);
    } catch (_) {}
  }

  Future<String?> getSavedTheme() async {
    try {
      return await _storage.read(key: AppConstants.themeKey);
    } catch (_) {
      return null;
    }
  }

  String sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp(r'''[<>"';&]'''), '');
  }
}
