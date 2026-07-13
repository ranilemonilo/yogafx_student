import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _tokenKey = 'auth_token';
  static const _blockedKey = 'account_blocked';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<void> setAccountBlocked(bool blocked) async {
    if (!blocked) {
      await _storage.delete(key: _blockedKey);
      return;
    }
    await _storage.write(key: _blockedKey, value: 'true');
  }

  static Future<bool> isAccountBlocked() async {
    final value = await _storage.read(key: _blockedKey);
    return value == 'true';
  }

  static Future<bool> hasToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<void> writeValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> readValue(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> deleteValue(String key) async {
    await _storage.delete(key: key);
  }
}
