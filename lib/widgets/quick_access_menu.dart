import 'package:flutter/material.dart';

import '../core/theme.dart';

class QuickAccessMenu extends StatelessWidget {
  const QuickAccessMenu({
    super.key,
    required this.items,
    required this.onTap,
  });

  final List<Map<String, dynamic>> items;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.84,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final icon = item['icon'] as IconData;
        final title = item['title'] as String;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onTap(title),
            borderRadius: BorderRadius.circular(18),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(icon, color: AppColors.info, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
