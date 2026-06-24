import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/api_service.dart';
import '../../widgets/list_item_card.dart';
import '../../widgets/main_bottom_nav.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'service_request_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService.instance;

  late TabController _tabController;
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _announcements = [];
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final all = await _apiService.getNotifications('Semua');
    final announcements = await _apiService.getNotifications('Pengumuman');
    final notifications = await _apiService.getNotifications('Notifikasi');

    if (!mounted) return;
    setState(() {
      _all = all;
      _announcements = announcements;
      _notifications = notifications;
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

  void _handleBottomNavTap(int index) {
    if (index == 2) return;

    final Widget target = switch (index) {
      0 => const HomeScreen(),
      1 => const RequestsScreen(),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Semua'),
              Tab(text: 'Pengumuman'),
              Tab(text: 'Notifikasi'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.checklist, size: 16),
                  label: const Text('Tandai semua dibaca'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNotificationList(_all),
                      _buildNotificationList(_announcements),
                      _buildNotificationList(_notifications),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: 2,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  Widget _buildNotificationList(List<Map<String, dynamic>> groups) {
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];
        final items = group['items'] as List;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                group['dateGroup'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            ...items.map((item) {
              final map = item as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: ListItemCard(
                  title: map['title'] as String,
                  subtitle: map['body'] as String,
                  meta: '${map['type']} • ${map['time']}',
                  leadingIcon: map['icon'] as IconData,
                  leadingColor: _toneToColor(map['tone'] as String),
                  isUnread: map['isUnread'] as bool,
                  onTap: () {},
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
