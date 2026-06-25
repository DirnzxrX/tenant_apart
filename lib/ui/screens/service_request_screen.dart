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

  void _showNewRequestForm(String initialCategory) {
    final List<String> categoryNames = _categories
        .map((c) => c['title'] as String)
        .toList();

    if (categoryNames.isEmpty) {
      categoryNames.add('Lainnya');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return NewServiceRequestFormSheet(
          initialCategory: initialCategory,
          availableCategories: categoryNames,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _RequestsBackdrop(),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopCard(),
                        const SizedBox(height: 16),
                        _buildHeroCard(),
                        const SizedBox(height: 18),
                        _buildSectionHeader('Kategori Layanan'),
                        const SizedBox(height: 10),
                        _buildCategories(),
                        const SizedBox(height: 18),
                        _buildSectionHeader('Status Permintaan'),
                        const SizedBox(height: 10),
                        Row(
                          children: _stats.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index == _stats.length - 1 ? 0 : 10,
                                ),
                                child: SummaryStatCard(
                                  count: item['count']!,
                                  label: item['label']!,
                                  color: _toneToColor(item['tone']!),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        _buildSectionHeader(
                          'Permintaan Terbaru',
                          trailingLabel: 'Lihat Semua',
                        ),
                        const SizedBox(height: 10),
                        ..._recentRequests.map(
                          (request) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
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
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: ElevatedButton.icon(
                onPressed: () => _showNewRequestForm('Lainnya'),
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
            child: const Icon(Icons.support_agent_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Ajukan, pantau, dan selesaikan permintaan tanpa berpindah layar.',
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
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.info,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buat permintaan lebih cepat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  'Kategori dibuat ringkas, detail lebih jelas, dan statusnya lebih mudah dilacak.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: _categories.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(item['icon'] as IconData, color: AppColors.info),
                ),
                title: Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  item['subtitle'] as String,
                  style: const TextStyle(height: 1.3),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showNewRequestForm(item['title'] as String),
              ),
              if (index < _categories.length - 1)
                const Divider(indent: 16, endIndent: 16, height: 1),
            ],
          );
        }).toList(),
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

class NewServiceRequestFormSheet extends StatefulWidget {
  final String initialCategory;
  final List<String> availableCategories;

  const NewServiceRequestFormSheet({
    super.key,
    required this.initialCategory,
    required this.availableCategories,
  });

  @override
  State<NewServiceRequestFormSheet> createState() =>
      _NewServiceRequestFormSheetState();
}

class _NewServiceRequestFormSheetState
    extends State<NewServiceRequestFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedCategory;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory =
        widget.availableCategories.contains(widget.initialCategory)
        ? widget.initialCategory
        : widget.availableCategories.first;
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
        content: Text('Permintaan layanan berhasil dikirim.'),
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
                  'Buat Permintaan Baru',
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
                      'Kategori Layanan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(),
                      items: widget.availableCategories
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCategory = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sub Kategori',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText:
                            'Misal: Perbaikan AC, Instalasi Software, dll',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Sub Kategori wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Detail Kendala / Permintaan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText:
                            'Jelaskan secara detail masalah yang dialami...',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Detail tidak boleh kosong'
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
                  : const Text('Kirim Permintaan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestsBackdrop extends StatelessWidget {
  const _RequestsBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _RequestsBackdropPainter()),
      ),
    );
  }
}

class _RequestsBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = AppColors.info.withValues(alpha: 0.06);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.05), 110, paint);

    paint.color = AppColors.primary.withValues(alpha: 0.05);
    canvas.drawCircle(Offset(size.width * 0.08, size.height * 0.24), 85, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
