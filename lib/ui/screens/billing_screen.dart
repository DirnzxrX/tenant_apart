import 'package:flutter/material.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({Key? key}) : super(key: key);

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // CATATAN ARSITEKTUR: 
  // Sekali lagi, karena tidak ada State Management, data dummy ini ditanam paksa di UI.
  // Bayangkan jika data ini berjumlah 500 baris dari API, file UI Anda akan hang saat memfilternya.
  final List<Map<String, dynamic>> _invoices = [
    {
      'id': 'INV/2023/05/0072',
      'desc': 'Sewa & Service Charge - Mei 2023',
      'dueDate': '31 Mei 2023',
      'amount': 'Rp 13.700.000',
      'status': 'Belum Dibayar',
    },
    {
      'id': 'INV/2023/04/0038',
      'desc': 'Sewa & Service Charge - Apr 2023',
      'dueDate': '29 Apr 2023',
      'amount': 'Rp 14.842.000',
      'status': 'Belum Dibayar',
    },
    {
      'id': 'INV/2023/03/0069',
      'desc': 'Sewa & Service Charge - Mar 2023',
      'dueDate': '31 Mar 2023',
      'amount': 'Rp 13.250.000',
      'status': 'Lunas',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3353),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Billing Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildOutstandingCard(),
          _buildTabBar(),
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
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildOutstandingCard() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Outstanding', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              const Text('Rp 24.560.000', style: TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('3 Invoice Belum Dibayar', style: TextStyle(color: Colors.red[400], fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long, color: Color(0xFF1A56A6), size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF1A56A6),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF1A56A6),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        tabs: const [
          Tab(text: 'Semua'),
          Tab(text: 'Belum Dibayar'),
          Tab(text: 'Lunas'),
        ],
      ),
    );
  }

  Widget _buildInvoiceList(String filter) {
    // Logika filter statis di dalam UI (Anti-pattern jika datanya besar)
    final filteredInvoices = _invoices.where((inv) {
      if (filter == 'Semua') return true;
      return inv['status'] == filter;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: filteredInvoices.length,
      itemBuilder: (context, index) {
        final inv = filteredInvoices[index];
        final isLunas = inv['status'] == 'Lunas';

        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(inv['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(inv['amount'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              Text(inv['desc'], style: TextStyle(color: Colors.grey[700], fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Jatuh Tempo: ${inv['dueDate']}', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isLunas ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isLunas ? Colors.green[200]! : Colors.red[200]!),
                    ),
                    child: Text(
                      inv['status'],
                      style: TextStyle(
                        color: isLunas ? Colors.green[700] : Colors.red[700],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: Color(0xFF1A56A6)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Riwayat Pembayaran', style: TextStyle(color: Color(0xFF1A56A6), fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
} 