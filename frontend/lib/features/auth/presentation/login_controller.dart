import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/auth_repository.dart';
import '../../dashboard/presentation/dashboard_page.dart';

class LoginController extends GetxController {
  final AuthRepository _repository = AuthRepository();
  
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Username dan Password tidak boleh kosong',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _repository.login(username, password);
      
      Get.snackbar(
        'Berhasil',
        'Login berhasil',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
      
      Get.offAll(() => const DashboardPage());
      
    } catch (e) {
      Get.snackbar(
        'Gagal Login',
        e.toString(),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
