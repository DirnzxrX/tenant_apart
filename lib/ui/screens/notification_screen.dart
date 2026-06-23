import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // CATATAN ARSITEKTUR:
  // Data statis terakhir. Perhatikan bagaimana kita harus melakukan hardcode
  // pengelompokan "Hari ini" dan "Kemarin" di UI. Di aplikasi nyata, 
  // grouping data berdasarkan tanggal ini HARUS dilakukan di layer BLoC/ViewModel, 
  // bukan di dalam fungsi build() karena akan membebani memori saat data bertambah.
  final List<Map<String, dynamic>> _notifications = [
    {
      'dateGroup': 'Hari ini',
      'items': [
        {
          'type': 'Pengumuman',
          'title': 'Pemeliharaan Rutin AC Mall',
          'body': 'Pemeliharaan rutin akan dilakukan pada AC Mall, pastikan...',
          'time': '08:42',
          'icon': Icons.campaign,
          'iconColor': Colors.blue,
          'bgColor': Colors.blue[50],
          'isUnread': true,
        },
        {
          'type': 'Notifikasi',
          'title': 'Permohonan PSA-250322-0012',
          'body': 'Status permohonan Anda telah melalui persetujuan...',
          'time': '06:45',
          'icon': Icons.assignment,
          'iconColor': Colors.indigo,
          'bgColor': Colors.indigo[50],
          'isUnread': true,
        },
        {
          'type': 'Pengumuman Mall',
          'title': 'Renovasi Toilet Disetujui',
          'body': 'Status permohonan Anda APRA-250321-0012 telah...',
          'time': '06:45',
          'icon': Icons.fact_check_outlined,
          'iconColor': Colors.green,
          'bgColor': Colors.green[50],
          'isUnread': false,
        },
      ]
    },
    {
      'dateGroup': 'Kemarin',
      'items': [
        {
          'type': 'Billing',
          'title': 'Invoice INV/2023/03/0012',
          'body': 'Invoice tagihan Anda bulan ini telah terbit, segera...',
          'time': '17:30',
          'icon': Icons.receipt_long,
          'iconColor': Colors.orange,
          'bgColor': Colors.orange[50],
          'isUnread': false,
        },
        {
          'type': 'Pengumuman',
          'title': 'Jam Operasional Mall',
          'body': 'Perubahan jam operasional selama libur nasional...',
          'time': '11:30',
          'icon': Icons.campaign,
          'iconColor': Colors.blue,
          'bgColor': Colors.blue[50],
          'isUnread': false,
        },
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih utuh untuk layar ini
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3353),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Notifikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          _buildMarkAllReadBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList('Semua'),
                _buildNotificationList('Pengumuman'),
                _buildNotificationList('Notifikasi'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF1A56A6),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF1A56A6),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        tabs: const [
          Tab(text: 'Semua'),
          Tab(text: 'Pengumuman'),
          Tab(text: 'Notifikasi'),
        ],
      ),
    );
  }

  Widget _buildMarkAllReadBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.checklist, size: 16, color: Color(0xFF1A56A6)),
            label: const Text(
              'Tandai semua Dibaca',
              style: TextStyle(fontSize: 12, color: Color(0xFF1A56A6), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(String filter) {
    // Catatan: Logika filtering diabaikan sementara untuk menyederhanakan UI mockup
    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, groupIndex) {
        final group = _notifications[groupIndex];
        final items = group['items'] as List;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                group['dateGroup'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
            ),
            ...items.map((item) => _buildNotificationItem(item)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> item) {
    return Container(
      color: item['isUnread'] ? Colors.blue[50]?.withOpacity(0.3) : Colors.white,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item['bgColor'],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item['icon'], color: item['iconColor'], size: 24),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['type'],
                  style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                Text(
                  item['time'],
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  item['title'],
                  style: TextStyle(
                    fontWeight: item['isUnread'] ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['body'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            onTap: () {},
          ),
          Divider(height: 1, color: Colors.grey[100], indent: 72),
        ],
      ),
    );
  }
}