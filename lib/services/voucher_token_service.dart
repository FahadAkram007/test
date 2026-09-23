import 'dart:async';
import 'dart:convert';
import 'dart:math';

/// Representation of a secure, time-bounded redemption token.
///
/// In production, this token is a cryptographically signed payload (e.g., JWT
/// with HMAC-SHA256 or asymmetric Ed25519 signature) generated strictly by the
/// corporate backend service.
class VoucherToken {
  /// The signed token string encoded inside the rotating QR code
  final String token;

  /// Expiry timestamp computed by the server
  final DateTime expiresAt;

  /// Total validity duration in seconds (typically 20-30s)
  final int ttlSeconds;

  /// Unique redemption session identifier
  final String sessionId;

  const VoucherToken({
    required this.token,
    required this.expiresAt,
    required this.ttlSeconds,
    required this.sessionId,
  });

  /// Remaining seconds until this token expires
  int get remainingSeconds =>
      expiresAt.difference(DateTime.now()).inSeconds.clamp(0, ttlSeconds);

  /// Normalized progress value between 0.0 (expired) and 1.0 (fresh)
  double get remainingRatio =>
      (remainingSeconds / ttlSeconds).clamp(0.0, 1.0);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Service responsible for fetching short-lived, server-signed redemption tokens.
///
/// ============================================================================
/// SECURITY NOTICE:
/// Tokens MUST NOT be created or signed client-side on the device. Generating
/// tokens on-device exposes signing keys and redemption business logic to
/// reverse-engineering. The corporate backend server (e.g., GET /api/voucher/token)
/// must remain the single source of truth for all valid redemption signatures.
/// ============================================================================
class VoucherTokenService {
  final Random _random = Random();

  /// Fetches a fresh signed redemption token for the employee's current session.
  ///
  /// [ttlSeconds]: Token lifespan in seconds (default: 20 seconds).
  /// [simulateFailure]: For testing error handling and retry UI states.
  Future<VoucherToken> fetchRedemptionToken({
    String employeeId = 'EMP-98214',
    int ttlSeconds = 20,
    bool simulateFailure = false,
  }) async {
    // Simulate real network latency (300-600ms)
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(300)));

    if (simulateFailure) {
      throw Exception('Network timeout: Failed to connect to /api/voucher/token');
    }

    // -------------------------------------------------------------------------
    // TODO: PRODUCTION BACKEND INTEGRATION
    // Replace this placeholder stub with a real authenticated HTTP request:
    //
    // final response = await http.get(
    //   Uri.parse('https://api.perkflow.internal/api/voucher/token'),
    //   headers: {
    //     'Authorization': 'Bearer $employeeAuthToken',
    //     'X-Device-Id': deviceFingerprint,
    //   },
    // );
    // if (response.statusCode == 200) {
    //   return VoucherToken.fromJson(jsonDecode(response.body));
    // } else {
    //   throw ServerException('Failed to retrieve signed token');
    // }
    // -------------------------------------------------------------------------

    final now = DateTime.now();
    final expiresAt = now.add(Duration(seconds: ttlSeconds));
    final nonce = _random.nextInt(999999).toString().padLeft(6, '0');
    final sessionId = 'SESS-${now.millisecondsSinceEpoch}-$nonce';

    // Mock signed payload: base64(employee:nonce:timestamp) + mock signature
    final rawPayload = '$employeeId:$nonce:${now.toIso8601String()}';
    final encodedPayload = base64Url.encode(utf8.encode(rawPayload));
    final mockSignature = 'sig_${_random.nextInt(0xFFFFFF).toRadixString(16)}';
    final serverSignedToken = 'prf.$encodedPayload.$mockSignature';

    return VoucherToken(
      token: serverSignedToken,
      expiresAt: expiresAt,
      ttlSeconds: ttlSeconds,
      sessionId: sessionId,
    );
  }
}
