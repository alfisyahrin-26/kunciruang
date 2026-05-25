import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      // Token expired / Unauthorized → redirect ke login
      await SecureStorage.clearAll();
      Get.offAllNamed('/login'); // Assuming route is defined in main.dart
    }
    handler.next(err);
  }
}
