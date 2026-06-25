import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/api_service.dart';
import '../../widgets/list_item_card.dart';
import '../../widgets/main_bottom_nav.dart';
import '../../widgets/quick_access_menu.dart';
import '../../widgets/summary_stat_card.dart';
import 'billing_screen.dart';
import 'notification_screen.dart';
import 'permit_screen.dart';
import 'profile_screen.dart';
import 'service_request_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService.instance;

  List<Map<String, dynamic>> _summary = [];
  List<Map<String, dynamic>> _menus = [];
  List<Map<String, String>> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final summary = await _apiService.getHomeSummary();
    final menus = await _apiService.getQuickMenus();
    final announcements = await _apiService.getAnnouncements();

    if (!mounted) return;
    setState(() {
      _summary = summary;
      _menus = menus;
      _announcements = announcements;
      _isLoading = false;
    });
  }

  Color _toneToColor(String tone) {
    switch (tone) {
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'danger':
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }

  void _pushScreen(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _handleQuickMenuTap(String title) {
    switch (title) {
      case 'Service Request':
        _pushScreen(const RequestsScreen());
        return;
      case 'Billing':
        _pushScreen(const BillingScreen());
        return;
      case 'Permit & Approval':
        _pushScreen(const PermitScreen());
        return;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Menu $title masih menggunakan data dummy.')),
        );
    }
  }

  void _handleBottomNavTap(int index) {
    if (index == 0) return;

    final Widget target = switch (index) {
      1 => const RequestsScreen(),
      2 => const BillingScreen(),
      _ => const ProfileScreen(),
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
      body: Stack(
        children: [
          const _HomeBackdrop(),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAppBarCard(),
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          'Ringkasan Hari Ini',
                          trailingLabel: 'Lihat Semua',
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: _summary.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index == _summary.length - 1 ? 0 : 10,
                                ),
                                child: SummaryStatCard(
                                  count: item['count'] as String,
                                  label: item['label'] as String,
                                  color: _toneToColor(item['tone'] as String),
                                  icon: item['icon'] as IconData?,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        _buildSectionHeader('Akses Cepat'),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryDark.withValues(
                                  alpha: 0.04,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: QuickAccessMenu(
                            items: _menus,
                            onTap: _handleQuickMenuTap,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildSectionHeader(
                          'Pengumuman Terbaru',
                          trailingLabel: 'Lihat Semua',
                        ),
                        const SizedBox(height: 10),
                        ..._announcements.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ListItemCard(
                              title: item['title']!,
                              subtitle: item['body']!,
                              meta: item['date']!,
                              leadingIcon: Icons.campaign_outlined,
                              leadingColor: AppColors.info,
                              onTap: () {},
                            ),
                          ),
                        ),
                        const SizedBox(height: 88),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: 0,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  Widget _buildAppBarCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.apartment_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, Tenant!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Selamat datang di Tenant',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _pushScreen(const NotificationScreen()),
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? trailingLabel}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (trailingLabel != null)
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(trailingLabel),
          ),
      ],
    );
  }
}

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(child: CustomPaint(painter: _BackdropPainter())),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = AppColors.primary.withValues(alpha: 0.07);
    canvas.drawCircle(
      Offset(size.width * 0.86, size.height * 0.08),
      120,
      paint,
    );

    paint.color = AppColors.info.withValues(alpha: 0.06);
    canvas.drawCircle(Offset(size.width * 0.08, size.height * 0.28), 90, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
