import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/partner.dart';
import '../theme/app_theme.dart';

/// Reusable card displaying partner merchant venue details, live open/closed status,
/// distance from user, weekly opening schedule, and direct Google Maps navigation.
class PartnerCard extends StatefulWidget {
  final PartnerModel partner;
  final int index;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  const PartnerCard({
    super.key,
    required this.partner,
    this.index = 0,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  @override
  State<PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends State<PartnerCard> {
  bool _isExpanded = false;

  Future<void> _openGoogleMaps(BuildContext context, PartnerModel partner) async {
    // Google Maps universal search URL using latitude and longitude
    final mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${partner.latitude},${partner.longitude}',
    );

    try {
      final launched = await launchUrl(
        mapsUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        // Fallback to in-app webview or standard browser if external app launch fails
        await launchUrl(mapsUri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open map: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final partner = widget.partner;

    final now = DateTime.now();
    final isOpen = partner.isOpenNow(now);
    final statusText = partner.getOpenStatus(now);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdRadius,
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: AppRadius.mdRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header: Logo/Icon + Name + Category + Distance
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: partner.categoryColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.smRadius,
                      border: Border.all(
                        color: partner.categoryColor.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      partner.icon,
                      color: partner.categoryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partner.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: AppRadius.xsRadius,
                              ),
                              child: Text(
                                partner.category,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (partner.distanceInKm != null) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '•',
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Icon(
                                Icons.near_me_rounded,
                                size: 12,
                                color: cs.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${partner.distanceInKm!.toStringAsFixed(1)} km away',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: cs.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // 2. Open Now / Closed Status Pill + Address Summary
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isOpen
                          ? AppTheme.success.withValues(alpha: 0.12)
                          : AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: AppRadius.fullRadius,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOpen ? AppTheme.success : AppTheme.error,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          statusText,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isOpen ? AppTheme.success : AppTheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      partner.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),

              // 3. Expanded Details (Weekly Schedule + Full Address + Maps CTA)
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.sm),

                    // Full Address Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: cs.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            partner.address,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Weekly Schedule Heading
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Opening Hours (This Week)',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Weekly Hours List
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: AppRadius.smRadius,
                      ),
                      child: Column(
                        children: List.generate(7, (i) {
                          final dayIndex = i + 1; // 1 = Monday
                          final isToday = dayIndex == now.weekday;
                          final hours = partner.weeklyOpeningHours[dayIndex];
                          final dayName = PartnerModel.dayNames[i];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (isToday)
                                      Container(
                                        width: 5,
                                        height: 5,
                                        margin: const EdgeInsets.only(right: 6),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: cs.primary,
                                        ),
                                      ),
                                    Text(
                                      dayName,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight:
                                            isToday ? FontWeight.bold : FontWeight.w500,
                                        color: isToday ? cs.primary : cs.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  hours?.format() ?? 'Closed',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight:
                                        isToday ? FontWeight.bold : FontWeight.normal,
                                    color: isToday ? cs.primary : cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // CTA: Open in Google Maps
                    FilledButton.icon(
                      onPressed: () => _openGoogleMaps(context, partner),
                      icon: const Icon(Icons.directions_rounded, size: 18),
                      label: const Text('Open in Google Maps'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.smRadius,
                        ),
                      ),
                    ),
                  ],
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      ),
    )
        // Subtle entrance animation with index stagger
        .animate(delay: (widget.index * 50).ms)
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .slideY(begin: 0.04, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
  }
}
