import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../data/scan_repository.dart';
import 'scan_result_page.dart';

class ScannerController extends GetxController {
  final ScanRepository _repository = ScanRepository();
  var isScanning = true.obs;
  var isProcessing = false.obs;

  final MobileScannerController mobileScannerController = MobileScannerController();
  final ImagePicker _picker = ImagePicker();

  void processQrCode(String token) {
    if (!isScanning.value || isProcessing.value) return;

    isScanning.value = false;
    _showInfokusDialog(token);
  }

  void _showInfokusDialog(String token) {
    bool withInfokus = false;
    
    Get.defaultDialog(
      title: 'Konfirmasi',
      content: StatefulBuilder(
        builder: (context, setState) {
          return CheckboxListTile(
            title: const Text('Apakah Anda juga mengambil Infokus?'),
            value: withInfokus,
            onChanged: (val) {
              setState(() {
                withInfokus = val ?? false;
              });
            },
          );
        },
      ),
      textConfirm: 'Lanjutkan',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // close dialog
        _submitScan(token, withInfokus);
      },
      onCancel: () {
        // Reset scanning state
        Future.delayed(const Duration(seconds: 2), () {
          isScanning.value = true;
          isProcessing.value = false;
        });
      },
      barrierDismissible: false,
    );
  }

  Future<void> _submitScan(String token, bool withInfokus) async {
    isProcessing.value = true;
    try {
      final result = await _repository.scanQr(token, withInfokus);
      Get.off(() => ScanResultPage(result: result));
    } catch (e) {
      Get.snackbar(
        'Gagal',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      Future.delayed(const Duration(seconds: 2), () {
        isScanning.value = true;
        isProcessing.value = false;
      });
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final BarcodeCapture? capture = await mobileScannerController.analyzeImage(image.path);
        if (capture != null && capture.barcodes.isNotEmpty) {
          final barcode = capture.barcodes.first;
          if (barcode.rawValue != null) {
            processQrCode(barcode.rawValue!);
            return;
          }
        }
        Get.snackbar('Gagal', 'Tidak menemukan QR Code pada gambar');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memproses gambar: $e');
    }
  }

  @override
  void onClose() {
    mobileScannerController.dispose();
    super.onClose();
  }
}
