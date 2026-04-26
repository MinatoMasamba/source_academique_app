import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage(this._storage);

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: _keyAccessToken, value: access);
    await _storage.write(key: _keyRefreshToken, value: refresh);
  }

  Future<String?> getAccessToken() async => await _storage.read(key: _keyAccessToken);
  
  Future<String?> getRefreshToken() async => await _storage.read(key: _keyRefreshToken);

  Future<void> clearAll() async => await _storage.deleteAll();
}