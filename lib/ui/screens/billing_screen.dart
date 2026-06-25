import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/api_service.dart';
import '../../widgets/list_item_card.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen>
    with SingleTickerProviderStateMixin {
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
      backgroundColor: AppColors.background,
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
          : Stack(
              children: [
                const _BillingBackdrop(),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _buildOutstandingCard(),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildTabBar(),
                    ),
                    const SizedBox(height: 12),
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
              ],
            ),
    );
  }

  Widget _buildOutstandingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Outstanding',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _summary!['totalOutstanding']!,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _summary!['subtitle']!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Semua'),
          Tab(text: 'Belum Dibayar'),
          Tab(text: 'Lunas'),
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
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
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

class _BillingBackdrop extends StatelessWidget {
  const _BillingBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _BillingBackdropPainter()),
      ),
    );
  }
}

class _BillingBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = AppColors.primary.withValues(alpha: 0.06);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.07), 100, paint);

    paint.color = AppColors.info.withValues(alpha: 0.05);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.18), 80, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
