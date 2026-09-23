import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Interactive palette inspector allowing users to preview and test the Material 3 ColorScheme.
class ColorSchemePreviewCard extends StatelessWidget {
  const ColorSchemePreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette_outlined, color: cs.primary, size: 20),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Material 3 Color Tokens',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Dynamic seed-generated tonal palette with WCAG compliant contrast.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Color Swatches Grid
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _SwatchChip(name: 'Primary', color: cs.primary, onColor: cs.onPrimary),
                _SwatchChip(name: 'Primary Container', color: cs.primaryContainer, onColor: cs.onPrimaryContainer),
                _SwatchChip(name: 'Secondary', color: cs.secondary, onColor: cs.onSecondary),
                _SwatchChip(name: 'Secondary Container', color: cs.secondaryContainer, onColor: cs.onSecondaryContainer),
                _SwatchChip(name: 'Tertiary', color: cs.tertiary, onColor: cs.onTertiary),
                _SwatchChip(name: 'Surface', color: cs.surface, onColor: cs.onSurface),
                _SwatchChip(name: 'Surface Container', color: cs.surfaceContainerHighest, onColor: cs.onSurfaceVariant),
                _SwatchChip(name: 'Error', color: cs.error, onColor: cs.onError),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SwatchChip extends StatelessWidget {
  final String name;
  final Color color;
  final Color onColor;

  const _SwatchChip({
    required this.name,
    required this.color,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.smRadius,
        border: Border.all(
          color: onColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              color: onColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
            style: TextStyle(
              color: onColor.withValues(alpha: 0.75),
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
