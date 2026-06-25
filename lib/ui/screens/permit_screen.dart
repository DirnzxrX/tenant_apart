import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/api_service.dart';
import '../../widgets/list_item_card.dart';
import '../../widgets/main_bottom_nav.dart';
import 'billing_screen.dart';
import 'profile_screen.dart';

class PermitScreen extends StatefulWidget {
  const PermitScreen({super.key});

  @override
  State<PermitScreen> createState() => _PermitScreenState();
}

class _PermitScreenState extends State<PermitScreen>
    with SingleTickerProviderStateMixin {
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

  void _handleBottomNavTap(int index) {
    if (index == 1) return;

    if (index == 0) {
      Navigator.pop(context);
      return;
    }

    final Widget target = switch (index) {
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

  void _showNewPermitForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return const NewPermitRequestFormSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _PermitBackdrop(),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: _buildTopCard(),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildMetrics(),
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
                            _buildPermitList('Semua'),
                            _buildPermitList('Menunggu'),
                            _buildPermitList('Disetujui'),
                            _buildPermitList('Ditolak'),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: ElevatedButton.icon(
                onPressed: _showNewPermitForm,
                icon: const Icon(Icons.add),
                label: const Text('Ajukan Permohonan Baru'),
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

  Widget _buildTopCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.approval_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permit & Approval',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pantau status izin, approval, dan jadwal pelaksanaan dari satu layar.',
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
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: _metrics.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final color = switch (item['tone']) {
            'success' => AppColors.success,
            'warning' => AppColors.warning,
            'danger' => AppColors.danger,
            _ => AppColors.info,
          };

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == _metrics.length - 1 ? 0 : 10,
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        item['count']!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['label']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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
        labelPadding: const EdgeInsets.symmetric(horizontal: 10),
        tabs: const [
          Tab(text: 'Semua'),
          Tab(text: 'Menunggu'),
          Tab(text: 'Disetujui'),
          Tab(text: 'Ditolak'),
        ],
      ),
    );
  }

  Widget _buildPermitList(String filter) {
    final filtered = _permits.where((permit) {
      if (filter == 'Semua') return true;
      return permit['status'] == filter;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 112),
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

class NewPermitRequestFormSheet extends StatefulWidget {
  const NewPermitRequestFormSheet({super.key});

  @override
  State<NewPermitRequestFormSheet> createState() =>
      _NewPermitRequestFormSheetState();
}

class _NewPermitRequestFormSheetState extends State<NewPermitRequestFormSheet> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _permitTypes = [
    'Renovasi Toko',
    'Promosi & Event',
    'Penambahan Signage',
    'Instalasi Peralatan',
    'Lainnya',
  ];
  late String _selectedType;
  bool _isSubmitting = false;

  final TextEditingController _dateController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _selectedType = _permitTypes.first;
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.info,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        final String startText =
            "${picked.start.day}/${picked.start.month}/${picked.start.year}";
        final String endText =
            "${picked.end.day}/${picked.end.month}/${picked.end.year}";
        _dateController.text = picked.start == picked.end
            ? startText
            : "$startText - $endText";
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Permohonan izin berhasil diajukan.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 18, 20, bottomPadding + 20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Ajukan Permohonan Baru',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Flexible(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jenis Izin/Permohonan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      items: _permitTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tanggal Pelaksanaan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: _pickDateRange,
                      decoration: const InputDecoration(
                        hintText: 'Pilih tanggal pelaksanaan',
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Tanggal wajib dipilih'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Detail Keterangan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText:
                            'Jelaskan detail permohonan (misal: area yang direnovasi, deskripsi event, dll)...',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Keterangan tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Kirim Permohonan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermitBackdrop extends StatelessWidget {
  const _PermitBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _PermitBackdropPainter()),
      ),
    );
  }
}

class _PermitBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = AppColors.primary.withValues(alpha: 0.05);
    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.08),
      110,
      paint,
    );

    paint.color = AppColors.warning.withValues(alpha: 0.05);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.2), 90, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
