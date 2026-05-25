import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/login_page.dart';
import '../data/transaction_repository.dart';
import '../data/room_repository.dart';
import '../data/qr_repository.dart';

class DashboardController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();
  final RoomRepository _roomRepository = RoomRepository();
  final QrRepository _qrRepository = QrRepository();

  var fullName = ''.obs;
  var role = ''.obs;
  var status = 'Belum Ada Pinjaman'.obs;
  var currentTabIndex = 0.obs;

  // For admin
  var rooms = <dynamic>[].obs;
  var activeQrList = <dynamic>[].obs;
  var selectedRoom = Rxn<dynamic>();
  var generatedQrData = Rxn<Map<String, dynamic>>();
  var isGeneratingQr = false.obs;
  var isLoadingRooms = false.obs;

  // For all users — transaction list
  var transactions = <dynamic>[].obs;
  var isLoadingTransactions = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    fullName.value = await SecureStorage.getFullName() ?? 'User';
    role.value = await SecureStorage.getUserRole() ?? 'USER';
    await loadTransactions();
    if (role.value == 'ADMIN') {
      await loadRooms();
      await loadActiveQr();
    }
  }

  Future<void> loadTransactions() async {
    isLoadingTransactions.value = true;
    try {
      final data = await _transactionRepository.getMyTransactions();
      transactions.value = data;
      if (data.isNotEmpty) {
        // Cari transaksi AMBIL yang aktif
        final activeAmbil = data.firstWhereOrNull(
          (trx) => trx['status'] == 'AMBIL',
        );
        if (activeAmbil != null) {
          // TransactionResponse sekarang pakai field flat: roomCode & roomName
          final roomCode = activeAmbil['roomCode'] ?? 'Lab';
          final roomName = activeAmbil['roomName'] ?? '';
          status.value = roomCode == '-' || roomCode == 'null'
              ? 'Sedang Meminjam Kunci'
              : 'Meminjam $roomCode${roomName.isNotEmpty ? " - $roomName" : ""}';
        } else {
          status.value = 'Tidak Ada Pinjaman Aktif';
        }
      } else {
        status.value = 'Tidak Ada Pinjaman Aktif';
      }
    } catch (e) {
      status.value = 'Gagal memuat status';
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  Future<void> loadRooms() async {
    isLoadingRooms.value = true;
    try {
      final data = await _roomRepository.getAllRooms();
      rooms.value = data;
    } catch (e) {
      debugPrint('Gagal load rooms: $e');
    } finally {
      isLoadingRooms.value = false;
    }
  }

  Future<void> loadActiveQr() async {
    try {
      // Ambil daftar QR aktif (tanpa gambar)
      final data = await _qrRepository.listActiveQr();
      // Coba ambil juga gambar QR hari ini jika ada
      try {
        final todayQr = await _qrRepository.getTodayQr();
        // Merge qrImageBase64 ke item pertama jika ada
        if (data.isNotEmpty && todayQr['qrImageBase64'] != null) {
          final merged = Map<String, dynamic>.from(data.first);
          merged['qrImageBase64'] = todayQr['qrImageBase64'];
          activeQrList.value = [merged, ...data.skip(1)];
        } else {
          activeQrList.value = data;
        }
      } catch (_) {
        activeQrList.value = data;
      }
    } catch (e) {
      debugPrint('Gagal load QR: $e');
    }
  }

  Future<void> generateGlobalDailyQr() async {
    isGeneratingQr.value = true;
    try {
      final data = await _qrRepository.generateDailyQr();
      generatedQrData.value = data;
      await loadActiveQr();
      // Show QR image dialog
      final base64Img = data['qrImageBase64'] as String?;
      if (base64Img != null) {
        Get.dialog(
          AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.qr_code, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Text('QR Global Hari Ini'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.memory(base64Decode(base64Img), width: 240, height: 240),
                const SizedBox(height: 12),
                Text(
                  'Berlaku: ${data['sessionDate'] ?? '-'} s/d 23:59',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                const Text(
                  '1 QR ini berlaku untuk SEMUA ruangan\ndan akan reset otomatis jam 00:01',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      }
      Get.snackbar(
        'Berhasil', 'QR Global hari ini berhasil dibuat/ditampilkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isGeneratingQr.value = false;
    }
  }

  Future<void> revokeQr(int id) async {
    try {
      await _qrRepository.revokeQr(id);
      await loadActiveQr();
      Get.snackbar('Berhasil', 'QR berhasil dinonaktifkan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    Get.offAll(() => const LoginPage());
  }
}
