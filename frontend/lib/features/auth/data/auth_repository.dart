import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/secure_storage.dart';

class AuthRepository {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      final token = response.data['token'];
      final role = response.data['role'];
      final fullName = response.data['fullName'];

      // Simpan di secure storage
      if (token != null) {
        await SecureStorage.saveToken(token);
        await SecureStorage.saveUserRole(role);
        await SecureStorage.saveFullName(fullName);
      }

      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Gagal melakukan login. Periksa koneksi atau kredensial Anda.';
    } catch (e) {
      throw 'Terjadi kesalahan tidak terduga: $e';
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (e) {
      // Abaikan error saat logout
    } finally {
      await SecureStorage.clearAll();
    }
  }
}
