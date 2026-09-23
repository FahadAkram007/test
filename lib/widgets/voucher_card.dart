import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/voucher_model.dart';
import '../theme/app_theme.dart';

/// Reusable card displaying an individual voucher or benefit allowance item.
///
/// Features remaining budget progress, merchant tag, and interactive code copy.
class VoucherCard extends StatelessWidget {
  final VoucherModel voucher;
  final int index;
  final VoidCallback? onTap;

  const VoucherCard({
    super.key,
    required this.voucher,
    this.index = 0,
    this.onTap,
  });

  void _copyVoucherCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: voucher.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voucher code "${voucher.code}" copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdRadius,
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon + Title + Status Pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: AppRadius.smRadius,
                    ),
                    child: Icon(
                      voucher.icon,
                      color: colorScheme.onPrimaryContainer,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          voucher.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          voucher.merchant,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (voucher.isExpiringSoon)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withValues(alpha: 0.12),
                        borderRadius: AppRadius.fullRadius,
                        border: Border.all(
                          color: AppTheme.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Expiring',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Progress Bar indicating remaining balance
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: voucher.remainingRatio,
                  minHeight: 6,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    voucher.remainingRatio < 0.2
                        ? AppTheme.warning
                        : colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              // Balance metrics row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Balance: ${voucher.formattedBalance}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Allocated: ${voucher.formattedTotal}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.xs),

              // Bottom row: Voucher code pill + copy button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: AppRadius.xsRadius,
                    ),
                    child: Text(
                      voucher.code,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _copyVoucherCode(context),
                    icon: const Icon(Icons.copy_rounded, size: 14),
                    label: const Text('Copy Code'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        // Subtle staggered entrance animation
        .animate(delay: (index * 60).ms)
        .fadeIn(duration: 350.ms, curve: Curves.easeOut)
        .slideY(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOutCubic);
  }
}
