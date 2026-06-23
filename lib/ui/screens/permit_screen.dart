import 'package:flutter/material.dart';

class PermitScreen extends StatefulWidget {
  const PermitScreen({Key? key}) : super(key: key);

  @override
  State<PermitScreen> createState() => _PermitScreenState();
}

class _PermitScreenState extends State<PermitScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // CATATAN ARSITEKTUR:
  // Data statis lagi. Kode ini semakin melanggar prinsip DRY (Don't Repeat Yourself).
  final List<Map<String, dynamic>> _permits = [
    {
      'title': 'Renovasi Interior Toko',
      'id': 'APRA-250323-0006',
      'date': 'Diajukan pada 20 Mar 2024',
      'status': 'Approved',
      'icon': Icons.architecture,
    },
    {
      'title': 'Promosi & Event Area',
      'id': 'APRA-250323-0005',
      'date': 'Diajukan pada 25 Mar 2024',
      'status': 'Pending',
      'icon': Icons.storefront,
    },
    {
      'title': 'Instalasi Signage',
      'id': 'APRA-250324-0004',
      'date': 'Diajukan pada 18 Mar 2024',
      'status': 'Approved',
      'icon': Icons.check_box_outlined,
    },
    {
      'title': 'Pengiriman Barang Besar',
      'id': 'APRA-220324-0004',
      'date': 'Diajukan pada 22 Mar 2024',
      'status': 'To Review',
      'icon': Icons.local_shipping_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3353),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Permit & Approval', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopMetrics(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPermitList('Semua'),
                    _buildPermitList('Menunggu'),
                    _buildPermitList('Disetujui'),
                    _buildPermitList('Status'), // Atau Ditolak
                  ],
                ),
              ),
            ],
          ),
          // Sticky Bottom Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Buat Permohonan Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A56A6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMetrics() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMetricItem(Icons.note_add_outlined, 'New Permit', isIcon: true),
          _buildMetricItem('3', 'Menunggu'),
          _buildMetricItem('4', 'Disetujui'),
          _buildMetricItem(Icons.track_changes_outlined, 'Tracking', isIcon: true),
        ],
      ),
    );
  }

  Widget _buildMetricItem(dynamic content, String label, {bool isIcon = false}) {
    return Column(
      children: [
        isIcon
            ? Icon(content as IconData, color: const Color(0xFF1A56A6), size: 28)
            : Text(content as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF1A56A6),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF1A56A6),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        tabs: const [
          Tab(text: 'Semua'),
          Tab(text: 'Menunggu'),
          Tab(text: 'Disetujui'),
          Tab(text: 'Status'),
        ],
      ),
    );
  }

  Widget _buildPermitList(String filter) {
    // Padding bawah yang besar agar item terakhir tidak tertutup tombol sticky
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 100.0),
      itemCount: _permits.length,
      itemBuilder: (context, index) {
        final permit = _permits[index];
        return _buildPermitCard(permit);
      },
    );
  }

  Widget _buildPermitCard(Map<String, dynamic> permit) {
    Color statusColor;
    Color statusBgColor;

    switch (permit['status']) {
      case 'Approved':
        statusColor = Colors.green[700]!;
        statusBgColor = Colors.green[50]!;
        break;
      case 'Pending':
        statusColor = Colors.orange[700]!;
        statusBgColor = Colors.orange[50]!;
        break;
      case 'To Review':
        statusColor = Colors.red[700]!;
        statusBgColor = Colors.red[50]!;
        break;
      default:
        statusColor = Colors.grey[700]!;
        statusBgColor = Colors.grey[100]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(permit['icon'], color: const Color(0xFF1A56A6), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(permit['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(permit['id'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 4),
                Text(permit['date'], style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              permit['status'],
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}