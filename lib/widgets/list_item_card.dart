import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'custom_status_chip.dart';

class ListItemCard extends StatelessWidget {
  const ListItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.meta,
    this.amount,
    this.status,
    this.statusTone,
    this.leadingIcon,
    this.leadingColor,
    this.isUnread = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String meta;
  final String? amount;
  final String? status;
  final String? statusTone;
  final IconData? leadingIcon;
  final Color? leadingColor;
  final bool isUnread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = leadingColor ?? AppColors.info;

    return Material(
      color: isUnread
          ? AppColors.primaryLight.withValues(alpha: 0.45)
          : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.03),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leadingIcon != null) ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(leadingIcon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (amount != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              amount!,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            meta,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        if (status != null)
                          CustomStatusChip(
                            label: status!,
                            tone: statusTone ?? status!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
