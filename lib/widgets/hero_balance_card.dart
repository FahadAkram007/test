import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Visually prominent hero card displaying the user's primary voucher / benefits balance.
///
/// Features a subtle gradient, soft corporate elevation glow, quick action triggers,
/// and responsive layout adhering strictly to the 8pt spatial grid.
class HeroBalanceCard extends StatelessWidget {
  final double totalBalance;
  final int activeVouchersCount;
  final VoidCallback? onScanTap;
  final VoidCallback? onTopUpTap;
  final VoidCallback? onHistoryTap;

  const HeroBalanceCard({
    super.key,
    required this.totalBalance,
    required this.activeVouchersCount,
    this.onScanTap,
    this.onTopUpTap,
    this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        // Subtle dual-tone corporate gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0F766E), // Deep Teal
                  const Color(0xFF1E293B), // Slate 800
                ]
              : [
                  const Color(0xFF0F766E), // Deep Teal
                  const Color(0xFF115E59), // Rich Teal 800
                ],
        ),
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppShadows.heroVoucherGlow(const Color(0xFF0F766E)),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lgRadius,
        child: Stack(
          children: [
            // Decorative background geometric accents (low opacity)
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Row: Corporate badge + Status pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: AppRadius.xsRadius,
                            ),
                            child: const Icon(
                              Icons.wallet_giftcard_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Corporate Benefits',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondarySeed.withValues(alpha: 0.25),
                          borderRadius: AppRadius.fullRadius,
                          border: Border.all(
                            color: AppTheme.secondarySeed.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              size: 14,
                              color: Color(0xFFFBBF24), // Amber gold
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              '$activeVouchersCount Active',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFFFBBF24),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Middle: Balance display
                  Text(
                    'Available Balance',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        totalBalance.toStringAsFixed(2),
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Bottom Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: _ActionPill(
                          icon: Icons.qr_code_scanner_rounded,
                          label: 'Pay / Scan',
                          isPrimary: true,
                          onTap: onScanTap,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _ActionPill(
                          icon: Icons.add_card_rounded,
                          label: 'Redeem',
                          isPrimary: false,
                          onTap: onTopUpTap,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _IconActionButton(
                        icon: Icons.receipt_long_rounded,
                        tooltip: 'History',
                        onTap: onHistoryTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        // Subtle entrance animation using flutter_animate
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.08, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}

/// Tactile button inside the hero balance card
class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.isPrimary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isPrimary
                ? Colors.white
                : Colors.white.withValues(alpha: 0.15),
            borderRadius: AppRadius.smRadius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary ? AppTheme.primarySeed : Colors.white,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isPrimary ? AppTheme.primarySeed : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Secondary circular icon button for quick utility actions
class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _IconActionButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smRadius,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: AppRadius.smRadius,
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
