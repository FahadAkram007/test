import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/voucher_token_service.dart';
import '../theme/app_theme.dart';

/// Screen displaying the dynamically rotating anti-screenshot QR code for in-store redemption.
class RedeemScreen extends StatefulWidget {
  final double availableBalance;

  const RedeemScreen({
    super.key,
    this.availableBalance = 550.50,
  });

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> with WidgetsBindingObserver {
  final VoucherTokenService _tokenService = VoucherTokenService();

  VoucherToken? _currentToken;
  bool _isLoading = true;
  String? _errorMessage;

  Timer? _countdownTimer;
  Timer? _rotationTimer;

  // Refresh token every 20 seconds
  static const int _tokenLifespanSeconds = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadFreshToken();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimers();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the user resumes the app, immediately refresh the token for security
    if (state == AppLifecycleState.resumed) {
      _loadFreshToken();
    }
  }

  void _stopTimers() {
    _countdownTimer?.cancel();
    _rotationTimer?.cancel();
  }

  void _startTimers(VoucherToken token) {
    _stopTimers();

    // High-resolution UI timer for smooth progress bar countdown
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (token.isExpired) {
        timer.cancel();
        _loadFreshToken();
      } else {
        setState(() {}); // updates the smooth countdown bar
      }
    });
  }

  Future<void> _loadFreshToken({bool simulateFailure = false}) async {
    _stopTimers();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _tokenService.fetchRedemptionToken(
        ttlSeconds: _tokenLifespanSeconds,
        simulateFailure: simulateFailure,
      );
      if (mounted) {
        setState(() {
          _currentToken = token;
          _isLoading = false;
        });
        _startTimers(token);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _showCameraPermissionExplainer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Theme.of(ctx).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Camera Access for In-Store Pay',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'PerkFlow uses your camera exclusively to scan merchant point-of-sale terminal codes and activate touch-free company voucher redemptions. No photos or video feeds are ever stored or shared.',
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Understood'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final token = _currentToken;
    final remainingSecs = token?.remainingSeconds ?? 0;
    final progress = token?.remainingRatio ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay with Voucher'),
        actions: [
          IconButton(
            tooltip: 'Camera & Scanner Permissions Info',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showCameraPermissionExplainer(context),
          ),
          IconButton(
            tooltip: 'Refresh Token Now',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : () => _loadFreshToken(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Security Notice Card
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.4),
                borderRadius: AppRadius.smRadius,
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: cs.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Anti-Screenshot Protection Active: Code refreshes dynamically every $_tokenLifespanSeconds seconds.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Main QR Code Container Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.lgRadius,
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  width: 1.2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    // Balance Header inside Card
                    Text(
                      'Redemption Balance',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '\$${widget.availableBalance.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // QR Code or State (Loading, Error, Display)
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.mdRadius,
                        boxShadow: AppShadows.card,
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: _buildQrContent(theme, cs),
                    ).animate(key: ValueKey(token?.sessionId)).fadeIn(duration: 250.ms),

                    const SizedBox(height: AppSpacing.lg),

                    // Countdown Progress Indicator
                    if (!_isLoading && _errorMessage == null && token != null) ...[
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 16,
                                    color: remainingSecs <= 5
                                        ? AppTheme.warning
                                        : cs.primary,
                                  ),
                                  const SizedBox(width: AppSpacing.xxs),
                                  Text(
                                    'Code expires in:',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${remainingSecs}s',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: remainingSecs <= 5
                                      ? AppTheme.warning
                                      : cs.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          ClipRRect(
                            borderRadius: AppRadius.fullRadius,
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: cs.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                remainingSecs <= 5
                                    ? AppTheme.warning
                                    : cs.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: AppSpacing.md),

                    // Session/Token Metadata Pill
                    if (token != null && _errorMessage == null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: AppRadius.xsRadius,
                        ),
                        child: Text(
                          'SESSION: ${token.sessionId}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontFamily: 'monospace',
                            color: cs.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Instructions for Cashier
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        color: AppTheme.secondarySeed, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How to pay at checkout',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'Present this screen to the cashier or position it in front of the merchant terminal scanner. Screenshots cannot be redeemed.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrContent(ThemeData theme, ColorScheme cs) {
    if (_isLoading && _currentToken == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: cs.primary, strokeWidth: 3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Requesting signed token...',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black87),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppTheme.error, size: 36),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Connection Error',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black54,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.tonalIcon(
              onPressed: () => _loadFreshToken(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_currentToken != null) {
      return QrImageView(
        data: _currentToken!.token,
        version: QrVersions.auto,
        size: 210.0,
        backgroundColor: Colors.white,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Color(0xFF0F766E), // Deep Teal
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Color(0xFF0F172A),
        ),
      );
    }

    return const SizedBox();
  }
}
