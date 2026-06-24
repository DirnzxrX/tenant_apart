import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/api_service.dart';
import '../../widgets/main_bottom_nav.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';
import 'notification_screen.dart';
import 'service_request_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService.instance;

  bool _isLoading = true;
  bool _isLoggingOut = false;
  Map<String, String>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final profile = await _apiService.getProfile();

      if (!mounted) return;
      setState(() {
        _userData = profile;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat profil')),
      );
    }
  }

  Future<void> _processLogout() async {
    Navigator.pop(context);

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        (route) => false,
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal keluar. Periksa koneksi Anda.')),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: !_isLoggingOut,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi TenantHub?'),
          actions: [
            TextButton(
              onPressed: _isLoggingOut ? null : () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: _isLoggingOut ? null : _processLogout,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  void _handleBottomNavTap(int index) {
    if (index == 3) return;

    final Widget target = switch (index) {
      0 => const HomeScreen(),
      1 => const RequestsScreen(),
      _ => const NotificationScreen(),
    };

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => target,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Tenant'),
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_userData != null)
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildMenuSection(),
                ],
              ),
            ),
          if (_isLoggingOut)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: 3,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  _userData!['name']![0],
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.info,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _userData!['name']!,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _userData!['company']!,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Unit: ${_userData!['unit']}',
              style: const TextStyle(
                color: AppColors.info,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoggingOut ? null : _showLogoutDialog,
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: const Text(
                'Keluar',
                style: TextStyle(color: AppColors.danger),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.grey[700], size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          if (isAction) const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: isAction ? () {} : null,
    );
  }
}
