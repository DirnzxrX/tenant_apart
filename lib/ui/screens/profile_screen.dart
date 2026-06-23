import 'package:flutter/material.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key}); 

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // STATE UI & DATA
  bool _isLoading = true;
  bool _isLoggingOut = false;
  Map<String, String>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // --- LOGIKA BISNIS DI DALAM UI (Anti-Pattern) ---
  // Mengambil data dari API langsung di Screen
  Future<void> _fetchProfileData() async {
    try {
      // Simulasi delay HTTP Request (misal: ApiService().getProfile())
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _userData = {
            'name': 'Budi Santoso',
            'company': 'PT Maju Bersama',
            'unit': 'Lantai 3 - Unit 305A',
            'email': 'tenant@acmemall.com',
            'phone': '+62 812-3456-7890',
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      // Gunakan context.mounted untuk ScaffoldMessenger setelah await
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat profil')),
        );
      }
    }
  }

  // Logika Logout + HTTP Request di dalam UI
  Future<void> _processLogout(BuildContext context) async {
    Navigator.pop(context); // Tutup dialog konfirmasi
    
    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Simulasi memanggil API untuk menghancurkan token di server
      await Future.delayed(const Duration(seconds: 1)); 

      // Gunakan context.mounted (standar Flutter terbaru)
      if (!context.mounted) return;

      // Navigasi ke Login menggunakan PageRouteBuilder sebagai alternatif
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal keluar. Periksa koneksi Anda.')),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: !_isLoggingOut,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi TenantHub?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: _isLoggingOut ? null : () => Navigator.pop(dialogContext),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: _isLoggingOut ? null : () => _processLogout(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
              child: const Text('Keluar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3353), 
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profil Tenant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: Stack(
        children: [
          // Kondisi Loading Data Profil
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFF1A56A6)))
          else if (_userData != null)
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildMenuSection(context),
                ],
              ),
            ),
            
          // Overlay Loading saat Logout
          if (_isLoggingOut)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue[100],
                child: Text(
                  _userData!['name']![0], 
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF1A56A6)),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFF1A56A6), shape: BoxShape.circle),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _userData!['name']!,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            _userData!['company']!,
            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Unit: ${_userData!['unit']}',
              style: const TextStyle(color: Color(0xFF1A56A6), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _buildMenuGroup(
          title: 'Informasi Akun',
          items: [
            _buildMenuItem(Icons.email_outlined, 'Email', trailingText: _userData!['email']),
            _buildMenuItem(Icons.phone_outlined, 'Nomor Telepon', trailingText: _userData!['phone']),
            _buildMenuItem(Icons.lock_outline, 'Ubah Password', isAction: true),
          ],
        ),
        const SizedBox(height: 16),
        _buildMenuGroup(
          title: 'Pengaturan',
          items: [
            _buildMenuItem(Icons.notifications_outlined, 'Pengaturan Notifikasi', isAction: true),
            _buildMenuItem(Icons.language, 'Bahasa', trailingText: 'Indonesia', isAction: true),
          ],
        ),
        const SizedBox(height: 16),
        _buildMenuGroup(
          title: 'Lainnya',
          items: [
            _buildMenuItem(Icons.help_outline, 'Pusat Bantuan', isAction: true),
            _buildMenuItem(Icons.description_outlined, 'Syarat & Ketentuan', isAction: true),
            _buildMenuItem(Icons.privacy_tip_outlined, 'Kebijakan Privasi', isAction: true),
          ],
        ),
        const SizedBox(height: 24),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoggingOut ? null : () => _showLogoutDialog(context),
              icon: Icon(Icons.logout, color: Colors.red[700]),
              label: Text('Keluar', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.red[700]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildMenuGroup({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {String? trailingText, bool isAction = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.grey[700], size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) 
            Text(trailingText, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          if (isAction) 
            const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: isAction ? () {} : null,
    );
  }
}