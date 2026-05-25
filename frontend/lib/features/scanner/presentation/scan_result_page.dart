import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';

class ScanResultPage extends StatelessWidget {
  final Map<String, dynamic> result;

  const ScanResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final bool isAmbil = result['status'] == 'AMBIL';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hasil Scan', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isAmbil ? Icons.lock_open : Icons.lock,
                    size: 80,
                    color: isAmbil ? Colors.greenAccent : Colors.orangeAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isAmbil ? 'Kunci Diambil' : 'Kunci Dikembalikan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result['message'] ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Transaksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Divider(height: 30),
                  _buildDetailRow('Ruangan', '${result['roomCode']} - ${result['roomName'] ?? ''}'),
                  
                  if (isAmbil) ...[
                    const SizedBox(height: 16),
                    _buildDetailRow('Kelas', result['kelas'] ?? '-'),
                    const SizedBox(height: 16),
                    _buildDetailRow('Mata Kuliah', result['mataKuliah'] ?? '-'),
                    const SizedBox(height: 16),
                    _buildDetailRow('Dosen', result['dosen'] ?? '-'),
                    const SizedBox(height: 16),
                    _buildDetailRow('Ambil Infokus?', (result['withInfokus'] == true) ? 'Ya, Diambil' : 'Tidak'),
                    const SizedBox(height: 16),
                    _buildDetailRow('Waktu Ambil', _formatDate(result['waktuAmbil'])),
                  ] else ...[
                    const SizedBox(height: 16),
                    _buildDetailRow('Durasi Pinjam', result['durasi'] ?? '-'),
                    const SizedBox(height: 16),
                    _buildDetailRow('Waktu Kembali', _formatDate(result['waktuKembali'])),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kembali ke Dashboard',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '-';
    try {
      final date = DateTime.parse(isoString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }
}
