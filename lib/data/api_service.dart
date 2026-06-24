import 'package:flutter/material.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static const String demoEmail = 'tenant@acmemall.com';
  static const String demoPassword = 'password123';

  Future<void> _simulateDelay([int milliseconds = 350]) {
    return Future<void>.delayed(Duration(milliseconds: milliseconds));
  }

  Future<bool> login(String email, String password) async {
    await _simulateDelay(900);
    if (email.trim().toLowerCase() == demoEmail && password == demoPassword) {
      return true;
    }
    throw Exception('Email atau password tidak valid.');
  }

  Future<List<Map<String, dynamic>>> getHomeSummary() async {
    await _simulateDelay();
    return const [
      {'count': '12', 'label': 'Permintaan', 'tone': 'info', 'icon': Icons.receipt_long_outlined},
      {'count': '5', 'label': 'Menunggu', 'tone': 'warning', 'icon': Icons.schedule_outlined},
      {'count': '3', 'label': 'Disetujui', 'tone': 'success', 'icon': Icons.check_circle_outline},
      {'count': '2', 'label': 'Ditolak', 'tone': 'danger', 'icon': Icons.cancel_outlined},
    ];
  }

  Future<List<Map<String, dynamic>>> getQuickMenus() async {
    await _simulateDelay();
    return const [
      {'icon': Icons.assignment_outlined, 'title': 'Service Request', 'subtitle': 'Layanan teknis'},
      {'icon': Icons.receipt_long_outlined, 'title': 'Billing', 'subtitle': 'Tagihan tenant'},
      {'icon': Icons.fact_check_outlined, 'title': 'Permit & Approval', 'subtitle': 'Perizinan tenant'},
      {'icon': Icons.campaign_outlined, 'title': 'Announcement', 'subtitle': 'Pengumuman mall'},
      {'icon': Icons.folder_copy_outlined, 'title': 'Document Center', 'subtitle': 'Dokumen tenant'},
      {'icon': Icons.local_shipping_outlined, 'title': 'Loading & Delivery', 'subtitle': 'Pengiriman barang'},
    ];
  }

  Future<List<Map<String, String>>> getAnnouncements() async {
    await _simulateDelay();
    return const [
      {
        'title': 'Maintenance Sistem AC Mall',
        'body': 'Pemeliharaan rutin akan dilakukan pada 25 Mei 2025 pukul 00:00 - 06:00 WIB.',
        'date': '22 Mei 2025',
      },
      {
        'title': 'Jam Operasional Libur Nasional',
        'body': 'Jam operasional mall selama libur nasional berubah menjadi 10:00 - 21:00 WIB.',
        'date': '20 Mei 2025',
      },
    ];
  }

  Future<List<Map<String, dynamic>>> getServiceCategories() async {
    await _simulateDelay();
    return const [
      {
        'icon': Icons.build_circle_outlined,
        'title': 'Fasilitas & Maintenance',
        'subtitle': 'Perbaikan AC, listrik, kebersihan',
      },
      {
        'icon': Icons.language_outlined,
        'title': 'IT & Telekomunikasi',
        'subtitle': 'Internet, Wi-Fi, sistem POS',
      },
      {
        'icon': Icons.shield_outlined,
        'title': 'Keamanan & Keselamatan',
        'subtitle': 'CCTV, akses, keamanan toko',
      },
      {
        'icon': Icons.widgets_outlined,
        'title': 'Lainnya',
        'subtitle': 'Permintaan layanan tambahan',
      },
    ];
  }

  Future<List<Map<String, String>>> getRequestStats() async {
    await _simulateDelay();
    return const [
      {'count': '12', 'label': 'Total', 'tone': 'neutral'},
      {'count': '5', 'label': 'Menunggu', 'tone': 'warning'},
      {'count': '4', 'label': 'Diproses', 'tone': 'info'},
      {'count': '3', 'label': 'Selesai', 'tone': 'success'},
    ];
  }

  Future<List<Map<String, String>>> getRecentRequests() async {
    await _simulateDelay();
    return const [
      {
        'title': 'AC tidak dingin di area toko',
        'subtitle': '#FS-250523-0012',
        'meta': '22 Mei 2025',
        'status': 'Menunggu',
      },
      {
        'title': 'Lampu koridor belakang mati',
        'subtitle': '#FS-250522-0098',
        'meta': '21 Mei 2025',
        'status': 'Diproses',
      },
    ];
  }

  Future<Map<String, String>> getBillingSummary() async {
    await _simulateDelay();
    return const {
      'totalOutstanding': 'Rp 24.560.000',
      'subtitle': '3 Invoice Belum Dibayar',
    };
  }

  Future<List<Map<String, String>>> getInvoices() async {
    await _simulateDelay();
    return const [
      {
        'id': 'INV/2025/05/0012',
        'desc': 'Sewa & Service Charge - Mei 2025',
        'dueDate': '31 Mei 2025',
        'amount': 'Rp 12.750.000',
        'status': 'Belum Dibayar',
      },
      {
        'id': 'INV/2025/04/0011',
        'desc': 'Sewa & Service Charge - Apr 2025',
        'dueDate': '30 Apr 2025',
        'amount': 'Rp 11.810.000',
        'status': 'Belum Dibayar',
      },
      {
        'id': 'INV/2025/03/0009',
        'desc': 'Sewa & Service Charge - Mar 2025',
        'dueDate': '31 Mar 2025',
        'amount': 'Rp 11.250.000',
        'status': 'Lunas',
      },
    ];
  }

  Future<List<Map<String, String>>> getPermitMetrics() async {
    await _simulateDelay();
    return const [
      {'count': '8', 'label': 'Total Permits', 'tone': 'info'},
      {'count': '3', 'label': 'Menunggu', 'tone': 'warning'},
      {'count': '4', 'label': 'Disetujui', 'tone': 'success'},
      {'count': '1', 'label': 'Ditolak', 'tone': 'danger'},
    ];
  }

  Future<List<Map<String, dynamic>>> getPermits() async {
    await _simulateDelay();
    return const [
      {
        'title': 'Renovasi Toko',
        'id': '#PRM-250521-0008',
        'date': 'Diajukan pada 21 Mei 2025',
        'status': 'Disetujui',
        'icon': Icons.storefront_outlined,
      },
      {
        'title': 'Promosi & Event',
        'id': '#PRM-250519-0007',
        'date': 'Diajukan pada 19 Mei 2025',
        'status': 'Menunggu',
        'icon': Icons.campaign_outlined,
      },
      {
        'title': 'Penambahan Signage',
        'id': '#PRM-250515-0006',
        'date': 'Diajukan pada 15 Mei 2025',
        'status': 'Disetujui',
        'icon': Icons.design_services_outlined,
      },
      {
        'title': 'Instalasi Peralatan',
        'id': '#PRM-250510-0005',
        'date': 'Diajukan pada 10 Mei 2025',
        'status': 'Ditolak',
        'icon': Icons.precision_manufacturing_outlined,
      },
    ];
  }

  Future<List<Map<String, dynamic>>> getNotifications(String filter) async {
    await _simulateDelay();
    const allGroups = [
      {
        'dateGroup': 'Hari Ini',
        'items': [
          {
            'type': 'Pengumuman',
            'title': 'Maintenance Sistem AC Mall',
            'body': 'Pemeliharaan rutin akan dilakukan pada 25 Mei 2025 mulai pukul 00:00 WIB.',
            'time': '09:30',
            'icon': Icons.campaign_outlined,
            'tone': 'info',
            'isUnread': true,
          },
          {
            'type': 'Notifikasi',
            'title': 'Permintaan #FS-250523-0012',
            'body': 'Status permintaan Anda telah berubah menjadi diproses oleh tim teknis.',
            'time': '09:15',
            'icon': Icons.assignment_outlined,
            'tone': 'warning',
            'isUnread': true,
          },
          {
            'type': 'Notifikasi',
            'title': 'Persetujuan Permit',
            'body': 'Permohonan renovasi toko Anda telah disetujui oleh manajemen mall.',
            'time': '08:45',
            'icon': Icons.fact_check_outlined,
            'tone': 'success',
            'isUnread': false,
          },
        ],
      },
      {
        'dateGroup': 'Kemarin',
        'items': [
          {
            'type': 'Billing',
            'title': 'Invoice INV/2025/05/0012',
            'body': 'Invoice Mei 2025 sudah tersedia. Silakan cek detail tagihan dan jatuh tempo.',
            'time': '17:30',
            'icon': Icons.receipt_long_outlined,
            'tone': 'danger',
            'isUnread': false,
          },
          {
            'type': 'Pengumuman',
            'title': 'Jam Operasional Mall',
            'body': 'Perubahan jam operasional selama libur nasional berlaku mulai akhir pekan ini.',
            'time': '16:05',
            'icon': Icons.campaign_outlined,
            'tone': 'info',
            'isUnread': false,
          },
        ],
      },
    ];

    if (filter == 'Semua') {
      return allGroups;
    }

    return allGroups
        .map((group) {
          final items = (group['items'] as List<Map<String, dynamic>>)
              .where((item) => item['type'] == filter)
              .toList();
          return {
            'dateGroup': group['dateGroup'],
            'items': items,
          };
        })
        .where((group) => (group['items'] as List).isNotEmpty)
        .toList();
  }

  Future<Map<String, String>> getProfile() async {
    await _simulateDelay(700);
    return const {
      'name': 'Budi Santoso',
      'company': 'PT Maju Bersama',
      'unit': 'Lantai 3 - Unit 305A',
      'email': demoEmail,
      'phone': '+62 812-3456-7890',
    };
  }
}
