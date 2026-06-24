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
      2 => const NotificationScreen(),
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Halo, Tenant!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Selamat datang di TenantHub',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _pushScreen(const NotificationScreen()),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildSectionHeader('Ringkasan Hari Ini', trailingLabel: 'Lihat Semua'),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: _summary
                          .map(
                            (item) => SummaryStatCard(
                              count: item['count'] as String,
                              label: item['label'] as String,
                              color: _toneToColor(item['tone'] as String),
                              icon: item['icon'] as IconData,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Akses Cepat'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: QuickAccessMenu(
                      items: _menus,
                      onTap: _handleQuickMenuTap,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Pengumuman Terbaru', trailingLabel: 'Lihat Semua'),
                  ..._announcements.map(
                    (item) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                ],
              ),
            ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: 0,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? trailingLabel}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (trailingLabel != null)
            TextButton(
              onPressed: () {},
              child: Text(trailingLabel),
            ),
        ],
      ),
    );
  }
}
