import 'package:flutter/material.dart';

/// Reusable KollektivO Brand Logo Widget.
///
/// Loads the official brand logo asset with fallback support.
class KollektivoLogo extends StatelessWidget {
  final double? height;
  final double? width;
  final BoxFit fit;

  const KollektivoLogo({
    super.key,
    this.height = 40.0,
    this.width,
    this.fit = BoxFit.contain,
  });

  /// Compact variation suited for AppBars and navigation headers
  const KollektivoLogo.compact({
    super.key,
    this.height = 30.0,
    this.width,
    this.fit = BoxFit.contain,
  });

  /// Prominent hero variation suited for Authentication and Onboarding screens
  const KollektivoLogo.hero({
    super.key,
    this.height = 76.0,
    this.width,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_kollektivo.png',
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback typographic logo if asset load fails
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.wallet_giftcard_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'KollektivO',
              style: TextStyle(
                fontSize: (height ?? 32) * 0.5,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
          ],
        );
      },
    );
  }
}
