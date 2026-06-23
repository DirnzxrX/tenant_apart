import 'package:flutter/material.dart';
// Perhatikan: Nama file disesuaikan dengan yang ada di Explorer VS Code Anda
import 'service_request_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- Fungsi Navigasi dari Menu Akses Cepat ---
  void _navigateToScreen(BuildContext context, String title) {
    Widget targetScreen;
    
    switch (title) {
      case 'Service Request':
        // Pastikan nama class di file service_request_screen.dart adalah RequestsScreen
        targetScreen = const RequestsScreen(); 
        break;
      case 'Billing':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Billing segera hadir')));
        return; 
      case 'Permit & Approval':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Permit segera hadir')));
        return;
      default:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Menuju $title...')));
        return;
    }

    // Mengganti MaterialPageRoute dengan PageRouteBuilder agar error hilang
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3353), // Biru gelap tenant
        elevation: 0,
        automaticallyImplyLeading: false, // Hilangkan tombol back default
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Halo, Tenant!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Selamat datang di TenantHub', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildRingkasanHariIni(),
            const SizedBox(height: 24),
            _buildAksesCepat(context),
            const SizedBox(height: 24),
            _buildPengumumanTerbaru(),
            const SizedBox(height: 32), // Padding bawah
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1A56A6),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), activeIcon: Icon(Icons.grid_view_rounded), label: 'Layanan'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  // --- KOMPONEN UI: Ringkasan Hari Ini ---
  Widget _buildRingkasanHariIni() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ringkasan Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              TextButton(
                onPressed: () {},
                child: const Text('Lihat Semua', style: TextStyle(fontSize: 12, color: Color(0xFF1A56A6), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('12', 'Permintaan', Colors.blue),
              _buildStatItem('5', 'Menunggu', Colors.orange),
              _buildStatItem('3', 'Disetujui', Colors.green),
              _buildStatItem('2', 'Ditolak', Colors.red),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String count, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // Mengubah withOpacity menjadi withValues sesuai standar baru
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(count, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87)),
      ],
    );
  }

  // --- KOMPONEN UI: Akses Cepat ---
  Widget _buildAksesCepat(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.assignment_outlined, 'title': 'Service Request', 'color': const Color(0xFF1A56A6)},
      {'icon': Icons.receipt_long_outlined, 'title': 'Billing', 'color': const Color(0xFF1A56A6)},
      {'icon': Icons.fact_check_outlined, 'title': 'Permit & Approval', 'color': const Color(0xFF1A56A6)},
      {'icon': Icons.campaign_outlined, 'title': 'Announcement', 'color': const Color(0xFF1A56A6)},
      {'icon': Icons.folder_copy_outlined, 'title': 'Document Center', 'color': const Color(0xFF1A56A6)},
      {'icon': Icons.local_shipping_outlined, 'title': 'Loading & Delivery', 'color': const Color(0xFF1A56A6)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Akses Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return _buildAksesCepatItem(context, item['icon'] as IconData, item['title'] as String, item['color'] as Color);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAksesCepatItem(BuildContext context, IconData icon, String title, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToScreen(context, title),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --- KOMPONEN UI: Pengumuman Terbaru ---
  Widget _buildPengumumanTerbaru() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pengumuman Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              TextButton(
                onPressed: () {},
                child: const Text('Lihat Semua', style: TextStyle(fontSize: 12, color: Color(0xFF1A56A6), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
                decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                child: const Icon(Icons.campaign, color: Color(0xFF1A56A6)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Maintenance Sistem AC Mall', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      'Pemberitahuan rutin akan dilakukan pada 25 Des 2023, 00:00 - 05:00 WIB.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    Text('22 Des 2023', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}