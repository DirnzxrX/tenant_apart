import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/api_service.dart';
import '../../widgets/list_item_card.dart';
import '../../widgets/main_bottom_nav.dart';
import '../../widgets/summary_stat_card.dart';
import 'home_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final ApiService _apiService = ApiService.instance;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, String>> _stats = [];
  List<Map<String, String>> _recentRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final categories = await _apiService.getServiceCategories();
    final stats = await _apiService.getRequestStats();
    final recentRequests = await _apiService.getRecentRequests();

    if (!mounted) return;
    setState(() {
      _categories = categories;
      _stats = stats;
      _recentRequests = recentRequests;
      _isLoading = false;
    });
  }

  Color _toneToColor(String tone) {
    switch (tone) {
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'neutral':
        return AppColors.textPrimary;
      default:
        return AppColors.info;
    }
  }

  void _handleBottomNavTap(int index) {
    if (index == 1) return;

    final Widget target = switch (index) {
      0 => const HomeScreen(),
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
        title: const Text('Service Request'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Kategori Layanan'),
                  _buildCategories(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Status Permintaan'),
                  _buildStats(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Permintaan Terbaru', trailingLabel: 'Lihat Semua'),
                  ..._recentRequests.map(
                    (request) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: ListItemCard(
                        title: request['title']!,
                        subtitle: request['subtitle']!,
                        meta: request['meta']!,
                        status: request['status']!,
                        statusTone: request['status']!,
                        leadingIcon: Icons.campaign_outlined,
                        leadingColor: AppColors.info,
                        onTap: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Form permintaan baru masih dummy.')),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Buat Permintaan Baru'),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: 1,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari layanan atau kategori',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.tune_rounded, color: AppColors.info),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: _categories.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item['icon'] as IconData, color: AppColors.info),
                ),
                title: Text(
                  item['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                subtitle: Text(item['subtitle'] as String),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              if (index < _categories.length - 1) const Divider(indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: _stats
            .map(
              (item) => SummaryStatCard(
                count: item['count']!,
                label: item['label']!,
                color: _toneToColor(item['tone']!),
              ),
            )
            .toList(),
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
