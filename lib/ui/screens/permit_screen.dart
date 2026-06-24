import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/api_service.dart';
import '../../widgets/list_item_card.dart';

class PermitScreen extends StatefulWidget {
  const PermitScreen({super.key});

  @override
  State<PermitScreen> createState() => _PermitScreenState();
}

class _PermitScreenState extends State<PermitScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService.instance;

  late TabController _tabController;
  List<Map<String, String>> _metrics = [];
  List<Map<String, dynamic>> _permits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final metrics = await _apiService.getPermitMetrics();
    final permits = await _apiService.getPermits();

    if (!mounted) return;
    setState(() {
      _metrics = metrics;
      _permits = permits;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permit & Approval'),
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
            Column(
              children: [
                _buildMetrics(),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Semua'),
                    Tab(text: 'Menunggu'),
                    Tab(text: 'Disetujui'),
                    Tab(text: 'Ditolak'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPermitList('Semua'),
                      _buildPermitList('Menunggu'),
                      _buildPermitList('Disetujui'),
                      _buildPermitList('Ditolak'),
                    ],
                  ),
                ),
              ],
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
                    const SnackBar(content: Text('Form permit baru masih dummy.')),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Ajukan Permohonan Baru'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _metrics.map((item) {
          final color = switch (item['tone']) {
            'success' => AppColors.success,
            'warning' => AppColors.warning,
            'danger' => AppColors.danger,
            _ => AppColors.info,
          };

          return Column(
            children: [
              Text(
                item['count']!,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                item['label']!,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPermitList(String filter) {
    final filtered = _permits.where((permit) {
      if (filter == 'Semua') return true;
      return permit['status'] == filter;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final permit = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ListItemCard(
            title: permit['title'] as String,
            subtitle: permit['id'] as String,
            meta: permit['date'] as String,
            status: permit['status'] as String,
            statusTone: permit['status'] as String,
            leadingIcon: permit['icon'] as IconData,
            leadingColor: AppColors.info,
            onTap: () {},
          ),
        );
      },
    );
  }
}
