import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) =>
      _storage.write(key: 'jwt_token', value: token);

  static Future<String?> getToken() =>
      _storage.read(key: 'jwt_token');

  static Future<void> deleteToken() =>
      _storage.delete(key: 'jwt_token');
      
  static Future<void> saveUserRole(String role) =>
      _storage.write(key: 'user_role', value: role);

  static Future<String?> getUserRole() =>
      _storage.read(key: 'user_role');
      
  static Future<void> saveFullName(String name) =>
      _storage.write(key: 'full_name', value: name);

  static Future<String?> getFullName() =>
      _storage.read(key: 'full_name');
      
  static Future<void> clearAll() => _storage.deleteAll();
}
