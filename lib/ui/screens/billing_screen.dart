import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/api_service.dart';
import '../../widgets/list_item_card.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService.instance;

  late TabController _tabController;
  List<Map<String, String>> _invoices = [];
  Map<String, String>? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      _apiService.getBillingSummary(),
      _apiService.getInvoices(),
    ]);

    if (!mounted) return;
    setState(() {
      _summary = results[0] as Map<String, String>;
      _invoices = results[1] as List<Map<String, String>>;
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
        title: const Text('Billing Information'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildOutstandingCard(),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Semua'),
                    Tab(text: 'Belum Dibayar'),
                    Tab(text: 'Lunas'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInvoiceList('Semua'),
                      _buildInvoiceList('Belum Dibayar'),
                      _buildInvoiceList('Lunas'),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Riwayat Pembayaran'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOutstandingCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Outstanding',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _summary!['totalOutstanding']!,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _summary!['subtitle']!,
                style: const TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_outlined, color: AppColors.info, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceList(String filter) {
    final filtered = _invoices.where((invoice) {
      if (filter == 'Semua') return true;
      return invoice['status'] == filter;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final invoice = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ListItemCard(
            title: invoice['id']!,
            subtitle: invoice['desc']!,
            meta: 'Jatuh Tempo: ${invoice['dueDate']}',
            amount: invoice['amount']!,
            status: invoice['status']!,
            statusTone: invoice['status']!,
            leadingIcon: Icons.receipt_long_outlined,
            leadingColor: AppColors.info,
            onTap: () {},
          ),
        );
      },
    );
  }
}
