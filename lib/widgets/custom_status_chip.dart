import 'package:flutter/material.dart';

import '../core/theme.dart';

class CustomStatusChip extends StatelessWidget {
  const CustomStatusChip({
    super.key,
    required this.label,
    required this.tone,
  });

  final String label;
  final String tone;

  Color get _foreground {
    switch (tone.toLowerCase()) {
      case 'success':
      case 'disetujui':
      case 'lunas':
      case 'selesai':
        return AppColors.success;
      case 'warning':
      case 'menunggu':
        return AppColors.warning;
      case 'danger':
      case 'ditolak':
      case 'belum dibayar':
        return AppColors.danger;
      case 'info':
      case 'diproses':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final foreground = _foreground;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
