import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../scanner/presentation/scanner_page.dart';
import 'dashboard_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Obx(() {
      final role = controller.role.value;

      if (role == 'ADMIN') {
        return _AdminDashboard(controller: controller);
      } else if (role == 'DOSEN') {
        return _DosenDashboard(controller: controller);
      } else {
        return _MahasiswaDashboard(controller: controller);
      }
    });
  }
}

// ─────────────────────────────────────────────────────────
// ADMIN DASHBOARD
// ─────────────────────────────────────────────────────────
class _AdminDashboard extends StatelessWidget {
  final DashboardController controller;
  const _AdminDashboard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Stack(
        children: [
          _GradientHeader(
            title: 'Panel Admin',
            subtitle: 'Selamat datang, ${controller.fullName.value}',
            onLogout: controller.logout,
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Row
                        Obx(() => Row(
                          children: [
                            _StatCard(
                              icon: Icons.door_back_door,
                              label: 'Total Ruangan',
                              value: '${controller.rooms.length}',
                              color: Colors.indigo,
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              icon: Icons.qr_code,
                              label: 'QR Aktif',
                              value: controller.activeQrList.isEmpty ? 'Belum Ada' : 'Ada',
                              color: controller.activeQrList.isEmpty ? Colors.grey : Colors.teal,
                            ),
                          ],
                        )),
                        const SizedBox(height: 24),

                        // Generate QR Section
                        _SectionTitle('QR Global Harian'),
                        const SizedBox(height: 4),
                        Text(
                          '1 QR berlaku untuk semua ruangan, reset otomatis jam 00:01',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 12),
                        _GenerateQrCard(controller: controller),
                        const SizedBox(height: 24),

                        // Active QR List
                        _SectionTitle('QR Aktif Hari Ini'),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (controller.activeQrList.isEmpty) {
                            return _EmptyCard('Belum ada QR yang di-generate hari ini');
                          }
                          return Column(
                            children: controller.activeQrList.map<Widget>((qr) {
                              return _ActiveQrTile(
                                qr: qr,
                                onRevoke: () => controller.revokeQr(qr['id']),
                                onView: () => _showQrDialog(context, qr),
                              );
                            }).toList(),
                          );
                        }),

                        const SizedBox(height: 24),

                        // All Transactions Audit
                        _SectionTitle('Audit Semua Transaksi'),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (controller.isLoadingTransactions.value) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (controller.transactions.isEmpty) {
                            return _EmptyCard('Belum ada transaksi');
                          }
                          return Column(
                            children: controller.transactions.reversed.take(10).map<Widget>((trx) {
                              return _TransactionTile(trx: trx);
                            }).toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Logout button in top-right
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: controller.logout,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQrDialog(BuildContext context, Map<String, dynamic> qr) {
    final qrImageBase64 = qr['qrImageBase64'];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(qr['roomCode'] ?? 'QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (qrImageBase64 != null)
              Image.memory(
                base64Decode(qrImageBase64),
                width: 220,
                height: 220,
              )
            else
              const Text('Gambar QR tidak tersedia.\nGenerate ulang untuk mendapatkan gambar.'),
            const SizedBox(height: 12),
            Text('Berlaku hingga: ${_formatDate(qr['expiredAt'])}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

// ─────────────────────────────────────────────────────────
// DOSEN DASHBOARD
// ─────────────────────────────────────────────────────────
class _DosenDashboard extends StatelessWidget {
  final DashboardController controller;
  const _DosenDashboard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Stack(
        children: [
          _GradientHeader(
            title: 'Dashboard Dosen',
            subtitle: 'Halo, ${controller.fullName.value}',
            onLogout: controller.logout,
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle('Riwayat Peminjaman Kelas Anda'),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (controller.isLoadingTransactions.value) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (controller.transactions.isEmpty) {
                            return _EmptyCard(
                                'Belum ada mahasiswa yang meminjam kunci\nuntuk jadwal kelas Anda');
                          }
                          return Column(
                            children: controller.transactions.reversed
                                .map<Widget>((trx) => _TransactionTile(trx: trx))
                                .toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: controller.logout,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// MAHASISWA DASHBOARD
// ─────────────────────────────────────────────────────────
class _MahasiswaDashboard extends StatelessWidget {
  final DashboardController controller;
  const _MahasiswaDashboard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Stack(
        children: [
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white24,
                            child: Text(
                              controller.fullName.value.isNotEmpty
                                  ? controller.fullName.value[0].toUpperCase()
                                  : 'M',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Selamat Datang 👋',
                                  style: TextStyle(color: Colors.white70, fontSize: 12)),
                              Obx(() => Text(controller.fullName.value,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: controller.logout,
                      ),
                    ],
                  ),
                ),

                // Status Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.key, color: Colors.white, size: 36),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Status Kunci', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Obx(() => Text(
                              controller.status.value,
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuickActionBtn(
                          icon: Icons.qr_code_scanner,
                          label: 'Scan QR',
                          color: Colors.deepPurple,
                          onTap: () async {
                            await Get.to(() => const ScannerPage());
                            controller.loadTransactions();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionBtn(
                          icon: Icons.history,
                          label: 'Riwayat',
                          color: Colors.teal,
                          onTap: () => _showHistoryBottomSheet(context, controller),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Recent History
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F6FB),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle('Transaksi Terakhir'),
                          const SizedBox(height: 12),
                          Obx(() {
                            if (controller.isLoadingTransactions.value) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (controller.transactions.isEmpty) {
                              return _EmptyCard('Belum ada riwayat peminjaman.\nScan QR untuk meminjam kunci ruangan.');
                            }
                            return Column(
                              children: controller.transactions.reversed
                                  .take(5)
                                  .map<Widget>((trx) => _TransactionTile(trx: trx))
                                  .toList(),
                            );
                          }),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => const ScannerPage());
          controller.loadTransactions();
        },
        backgroundColor: AppColors.primary,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Obx(() => Icon(Icons.home,
                    color: controller.currentTabIndex.value == 0 ? AppColors.primary : Colors.grey)),
                onPressed: () => controller.changeTab(0),
              ),
              const SizedBox(width: 48),
              IconButton(
                icon: Obx(() => Icon(Icons.history,
                    color: controller.currentTabIndex.value == 1 ? AppColors.primary : Colors.grey)),
                onPressed: () => _showHistoryBottomSheet(context, controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoryBottomSheet(BuildContext context, DashboardController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                  color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text('Riwayat Peminjaman',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.transactions.isEmpty) {
                  return const Center(child: Text('Belum ada riwayat peminjaman'));
                }
                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.transactions.length,
                  itemBuilder: (_, i) {
                    final trx = controller.transactions.reversed.toList()[i];
                    return _TransactionTile(trx: trx);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────
class _GradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onLogout;

  const _GradientHeader({required this.title, required this.subtitle, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.admin_panel_settings, color: Colors.white70, size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)));
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                      overflow: TextOverflow.ellipsis),
                  Text(label,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenerateQrCard extends StatelessWidget {
  final DashboardController controller;
  const _GenerateQrCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Satu QR untuk semua ruangan. Mahasiswa scan QR ini → sistem mendeteksi jadwal otomatis.',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() => ElevatedButton.icon(
                  onPressed: controller.isGeneratingQr.value
                      ? null
                      : () => controller.generateGlobalDailyQr(),
                  icon: controller.isGeneratingQr.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.qr_code, size: 18),
                  label: Text(controller.isGeneratingQr.value
                      ? 'Generating...'
                      : 'Generate / Tampilkan QR Hari Ini'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveQrTile extends StatelessWidget {
  final dynamic qr;
  final VoidCallback onRevoke;
  final VoidCallback onView;

  const _ActiveQrTile({required this.qr, required this.onRevoke, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.qr_code, color: Colors.teal, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${qr['roomCode']} — ${qr['roomName'] ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Berlaku: ${qr['sessionDate'] ?? '-'}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          // View QR
          IconButton(
            icon: const Icon(Icons.visibility, color: Colors.indigo),
            tooltip: 'Lihat QR',
            onPressed: onView,
          ),
          // Revoke
          IconButton(
            icon: const Icon(Icons.block, color: Colors.red),
            tooltip: 'Nonaktifkan',
            onPressed: () {
              Get.defaultDialog(
                title: 'Konfirmasi',
                middleText: 'Nonaktifkan QR untuk ${qr['roomCode']}?',
                textConfirm: 'Ya',
                textCancel: 'Batal',
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () {
                  Get.back();
                  onRevoke();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final dynamic trx;
  const _TransactionTile({required this.trx});

  @override
  Widget build(BuildContext context) {
    final bool isAmbil = trx['status'] == 'AMBIL';
    final withInfokus = trx['withInfokus'] == true;
    final dosenSnap = trx['dosenSnapshot'] ?? '-';
    final mkSnap = trx['mataKuliahSnapshot'] ?? '-';
    final kelasSnap = trx['kelasSnapshot'] ?? '-';

    // TransactionResponse: roomCode & roomName sekarang flat (bukan nested)
    final String roomCode = trx['roomCode'] ?? '-';
    final String roomName = trx['roomName'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isAmbil ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isAmbil ? Icons.lock_open_rounded : Icons.lock_rounded,
              color: isAmbil ? Colors.green : Colors.orange,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        roomCode == '-' ? 'Semua Ruangan' : roomCode,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isAmbil ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isAmbil ? 'PINJAM' : 'KEMBALI',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (withInfokus) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tv, color: Colors.white, size: 10),
                            SizedBox(width: 3),
                            Text('Infokus', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text('$mkSnap • $kelasSnap',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
                Text('Dosen: $dosenSnap',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
