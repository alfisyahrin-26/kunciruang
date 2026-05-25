import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

class RoomRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<dynamic>> getAllRooms() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/rooms');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Gagal memuat data ruangan';
    }
  }
}
