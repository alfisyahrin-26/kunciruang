import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';

class TransactionRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<dynamic>> getMyTransactions() async {
    try {
      final response = await _dio.get(
        ApiConstants.baseUrl + '/transactions',
      );
      return response.data;
    } catch (e) {
      throw Exception('Gagal memuat transaksi: $e');
    }
  }
}
