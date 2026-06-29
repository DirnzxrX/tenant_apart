import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/api_service.dart';
import '../../widgets/list_item_card.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final ApiService _apiService = ApiService.instance;
  final TextEditingController _searchController = TextEditingController();

  List<DocumentItem> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    try {
      final query = _searchController.text.trim();
      final documents = await _apiService.getDocuments(
        perPage: 20,
        search: query.isEmpty ? null : query,
      );

      if (!mounted) return;
      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _documents = const [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Future<void> _openDocumentDetail(DocumentItem document) async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _DocumentDetailSheet(
          document: document,
          onDownload: () async {
            Navigator.pop(context);
            try {
              final result = await _apiService.downloadDocument(document.id);
              if (!mounted) return;
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(content: Text(result.isEmpty ? 'Dokumen siap diunduh.' : result)),
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
              );
            }
          },
        );
      },
    );
  }

  String _formatSize(int size) {
    if (size <= 0) return '-';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value.isEmpty ? '-' : value;
    return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Documents'),
      ),
      body: Stack(
        children: [
          const _DocumentBackdrop(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _loadDocuments(),
                    decoration: InputDecoration(
                      hintText: 'Cari dokumen',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _loadDocuments();
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
                      'Dokumen aktif dari API',
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
                          onRefresh: _loadDocuments,
                          child: _documents.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                                  children: const [
                                    Center(child: Text('Belum ada dokumen tersedia.')),
                                  ],
                                )
                              : ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
                                  itemCount: _documents.length,
                                  itemBuilder: (context, index) {
                                    final document = _documents[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: ListItemCard(
                                        title: document.title,
                                        subtitle:
                                            document.description?.isNotEmpty == true
                                            ? document.description!
                                            : document.mimeType,
                                        meta:
                                            '${_formatDate(document.publishedAt)} | ${_formatSize(document.size)}',
                                        leadingIcon: Icons.description_outlined,
                                        leadingColor: AppColors.info,
                                        onTap: () => _openDocumentDetail(document),
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

class _DocumentDetailSheet extends StatelessWidget {
  const _DocumentDetailSheet({
    required this.document,
    required this.onDownload,
  });

  final DocumentItem document;
  final Future<void> Function() onDownload;

  String _formatSize(int size) {
    if (size <= 0) return '-';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
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
          Text(
            document.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            document.description?.isNotEmpty == true
                ? document.description!
                : 'Tidak ada deskripsi tambahan.',
            style: const TextStyle(height: 1.45),
          ),
          const SizedBox(height: 14),
          _InfoRow(label: 'Tipe', value: document.mimeType),
          _InfoRow(label: 'Ukuran', value: _formatSize(document.size)),
          _InfoRow(label: 'Tanggal Terbit', value: document.publishedAt),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.download_rounded),
              label: const Text('Unduh Dokumen'),
            ),
          ),
        ],
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

class _DocumentBackdrop extends StatelessWidget {
  const _DocumentBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _DocumentBackdropPainter()),
      ),
    );
  }
}

class _DocumentBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = AppColors.info.withValues(alpha: 0.06);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.08), 100, paint);

    paint.color = AppColors.primary.withValues(alpha: 0.05);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.22), 82, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
