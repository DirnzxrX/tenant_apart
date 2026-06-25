import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/api_service.dart';
import '../../widgets/main_bottom_nav.dart';
import 'auth/login_screen.dart';
import 'billing_screen.dart';
import 'home_screen.dart';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memuat profil')));
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
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi Tenant?',
          ),
          actions: [
            TextButton(
              onPressed: _isLoggingOut
                  ? null
                  : () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: _isLoggingOut ? null : _processLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
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
      _ => const BillingScreen(),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profil Tenant')),
      body: Stack(
        children: [
          const _ProfileBackdrop(),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_userData != null)
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 18),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: Colors.white.withValues(alpha: 0.16),
                child: Text(
                  _userData!['name']![0],
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
          const SizedBox(height: 14),
          Text(
            _userData!['name']!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userData!['company']!,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Unit: ${_userData!['unit']}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
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
            _buildMenuItem(
              Icons.email_outlined,
              'Email',
              trailingText: _userData!['email'],
            ),
            _buildMenuItem(
              Icons.phone_outlined,
              'Nomor Telepon',
              trailingText: _userData!['phone'],
            ),
            _buildMenuItem(Icons.lock_outline, 'Ubah Password', isAction: true),
          ],
        ),
        const SizedBox(height: 16),
        _buildMenuGroup(
          title: 'Pengaturan',
          items: [
            _buildMenuItem(
              Icons.notifications_outlined,
              'Pengaturan Notifikasi',
              isAction: true,
            ),
            _buildMenuItem(
              Icons.language,
              'Bahasa',
              trailingText: 'Indonesia',
              isAction: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMenuGroup(
          title: 'Lainnya',
          items: [
            _buildMenuItem(Icons.help_outline, 'Pusat Bantuan', isAction: true),
            _buildMenuItem(
              Icons.description_outlined,
              'Syarat & Ketentuan',
              isAction: true,
            ),
            _buildMenuItem(
              Icons.privacy_tip_outlined,
              'Kebijakan Privasi',
              isAction: true,
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
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
      ],
    );
  }

  Widget _buildMenuGroup({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    String? trailingText,
    bool isAction = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.info, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          if (isAction)
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
      onTap: isAction ? () {} : null,
    );
  }
}

class _ProfileBackdrop extends StatelessWidget {
  const _ProfileBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _ProfileBackdropPainter()),
      ),
    );
  }
}

class _ProfileBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = AppColors.primary.withValues(alpha: 0.06);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.06), 110, paint);

    paint.color = AppColors.info.withValues(alpha: 0.05);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.2), 90, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
