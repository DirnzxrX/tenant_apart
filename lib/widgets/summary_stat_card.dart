import 'package:flutter/material.dart';

import '../core/theme.dart';

class SummaryStatCard extends StatelessWidget {
  const SummaryStatCard({
    super.key,
    required this.count,
    required this.label,
    required this.color,
    this.icon,
  });

  final String count;
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: icon != null
                  ? Icon(icon, color: color, size: 20)
                  : Text(
                      count,
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
