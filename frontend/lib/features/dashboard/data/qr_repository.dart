import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

class QrRepository {
  final Dio _dio = ApiClient.instance;

  /// Generate atau ambil QR Global Harian (no room needed)
  Future<Map<String, dynamic>> generateDailyQr() async {
    try {
      final response = await _dio.post(ApiConstants.generateQr);
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Gagal generate QR';
    }
  }

  Future<List<dynamic>> listActiveQr() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/qr/list');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Gagal memuat daftar QR';
    }
  }

  Future<Map<String, dynamic>> getTodayQr() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/qr/today');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Belum ada QR untuk hari ini';
    }
  }

  Future<void> revokeQr(int id) async {
    try {
      await _dio.delete('${ApiConstants.baseUrl}/qr/$id/revoke');
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Gagal menonaktifkan QR';
    }
  }
}

