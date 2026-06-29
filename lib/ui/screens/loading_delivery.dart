import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/api_service.dart';
import '../../widgets/list_item_card.dart';

class LoadingDeliveryScreen extends StatefulWidget {
  const LoadingDeliveryScreen({super.key});

  @override
  State<LoadingDeliveryScreen> createState() => _LoadingDeliveryScreenState();
}

class _LoadingDeliveryScreenState extends State<LoadingDeliveryScreen> {
  final ApiService _apiService = ApiService.instance;
  final TextEditingController _searchController = TextEditingController();

  List<LoadingDelivery> _deliveries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDeliveries() async {
    try {
      final query = _searchController.text.trim();
      final deliveries = await _apiService.getLoadingDeliveries(
        perPage: 20,
        search: query.isEmpty ? null : query,
      );

      if (!mounted) return;
      setState(() {
        _deliveries = deliveries;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _deliveries = const [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value.isEmpty ? '-' : value;
    return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
  }

  Color _toneToColor(String tone) {
    switch (tone.toLowerCase()) {
      case 'success':
      case 'approved':
      case 'disetujui':
        return AppColors.success;
      case 'warning':
      case 'pending':
      case 'menunggu':
        return AppColors.warning;
      case 'danger':
      case 'rejected':
      case 'ditolak':
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }

  Future<void> _openDetail(LoadingDelivery delivery) async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _LoadingDeliveryDetailSheet(delivery: delivery);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Loading Delivery')),
      body: Stack(
        children: [
          const _LoadingBackdrop(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _loadDeliveries(),
                    decoration: InputDecoration(
                      hintText: 'Cari loading delivery',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _loadDeliveries();
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Data loading & delivery aktif',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: _loadDeliveries,
                          child: _deliveries.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                                  children: const [
                                    Center(
                                      child: Text('Belum ada data loading delivery.'),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
                                  itemCount: _deliveries.length,
                                  itemBuilder: (context, index) {
                                    final delivery = _deliveries[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: ListItemCard(
                                        title: delivery.activityType,
                                        subtitle: delivery.description.isNotEmpty
                                            ? delivery.description
                                            : 'Tidak ada deskripsi.',
                                        meta:
                                            '${delivery.requestNumber} | ${_formatDate(delivery.scheduledAt)}',
                                        status: delivery.status,
                                        statusTone: delivery.status,
                                        leadingIcon: Icons.local_shipping_outlined,
                                        leadingColor: _toneToColor(delivery.status),
                                        onTap: () => _openDetail(delivery),
                                      ),
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDeliveryDetailSheet extends StatelessWidget {
  const _LoadingDeliveryDetailSheet({required this.delivery});

  final LoadingDelivery delivery;

  String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value.isEmpty ? '-' : value;
    return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
            Text(
              delivery.activityType,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              delivery.description.isNotEmpty
                  ? delivery.description
                  : 'Tidak ada deskripsi tambahan.',
              style: const TextStyle(height: 1.45),
            ),
            const SizedBox(height: 14),
            _InfoRow(label: 'Nomor Request', value: delivery.requestNumber),
            _InfoRow(label: 'Status', value: delivery.status),
            _InfoRow(label: 'Jadwal', value: _formatDate(delivery.scheduledAt)),
            _InfoRow(label: 'Diajukan', value: _formatDate(delivery.submittedAt)),
            const SizedBox(height: 16),
            Text(
              'Lampiran (${delivery.attachments.length})',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (delivery.attachments.isEmpty)
              const Text('Belum ada lampiran.')
            else
              ...delivery.attachments.map(
                (attachment) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.attachment_outlined),
                    title: Text(attachment.originalName),
                    subtitle: Text(
                      '${attachment.mimeType} | ${attachment.size} B',
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Timeline (${delivery.timeline.length})',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (delivery.timeline.isEmpty)
              const Text('Belum ada riwayat status.')
            else
              ...delivery.timeline.map(
                (history) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${history.fromStatus} -> ${history.toStatus}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(history.note),
                        const SizedBox(height: 4),
                        Text(
                          history.occurredAt,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBackdrop extends StatelessWidget {
  const _LoadingBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _LoadingBackdropPainter()),
      ),
    );
  }
}

class _LoadingBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = AppColors.primary.withValues(alpha: 0.05);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.08), 98, paint);

    paint.color = AppColors.warning.withValues(alpha: 0.05);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.22), 82, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
