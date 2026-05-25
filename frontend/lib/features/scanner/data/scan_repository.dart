import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

class ScanRepository {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> scanQr(String token, bool withInfokus) async {
    try {
      final response = await _dio.post(
        ApiConstants.scan,
        data: {
          'token': token,
          'withInfokus': withInfokus,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Gagal memproses QR Code. Periksa koneksi Anda.';
    } catch (e) {
      throw 'Terjadi kesalahan tidak terduga: $e';
    }
  }
}
