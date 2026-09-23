import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/kollektivo_logo.dart';
import 'home_screen.dart';

/// Authentication Screen for KollektivO.
///
/// Features employee email/password validation, credential error handling,
/// and brand presentation following the clean monochrome design system.
class LoginScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const LoginScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate standard authentication network latency
    await Future.delayed(const Duration(milliseconds: 400));

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // =========================================================================
    // TODO: PRODUCTION AUTHENTICATION INTEGRATION
    // -------------------------------------------------------------------------
    // The hardcoded credentials ("123" / "123") below are TEMPORARY and strictly
    // for local development and QA testing.
    //
    // CRITICAL: Before deploying to staging or production, replace this block
    // with real enterprise authentication (e.g., OAuth 2.0 / OpenID Connect,
    // Firebase Auth, or your backend SSO / LDAP endpoint) because this app
    // manages financial voucher balances and sensitive employee benefit allowances.
    // =========================================================================
    final bool isAuthorized = (email == '123' && password == '123');

    if (!mounted) return;

    if (isAuthorized) {
      setState(() {
        _isLoading = false;
      });

      // Navigate to the main application shell
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            currentThemeMode: widget.currentThemeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Invalid credentials. Please enter email "123" and password "123" for testing.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        actions: [
          // Theme Mode Switcher
          IconButton(
            tooltip: 'Switch Theme Mode',
            icon: Icon(
              widget.currentThemeMode == ThemeMode.dark
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              color: cs.onSurface,
            ),
            onPressed: () {
              final next = widget.currentThemeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              widget.onThemeModeChanged(next);
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. KollektivO Brand Logo
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.slate800 : Colors.white,
                          borderRadius: AppRadius.mdRadius,
                          border: Border.all(
                            color: isDark ? AppTheme.slate700 : AppTheme.slate200,
                          ),
                          boxShadow: AppShadows.soft,
                        ),
                        child: const KollektivoLogo.hero(),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 2. Screen Title & Subtitle
                    Text(
                      'Welcome to KollektivO',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Sign in to access your company benefit vouchers and partner perks',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 3. Error Banner (if credentials invalid)
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.08),
                          borderRadius: AppRadius.smRadius,
                          border: Border.all(
                            color: AppTheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppTheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // 4. Email / Username Input
                    Text(
                      'Email or Employee ID',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email or 123',
                        prefixIcon: Icon(Icons.badge_outlined, size: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email or ID';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 5. Password Input
                    Text(
                      'Password',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      decoration: InputDecoration(
                        hintText: 'Enter password or 123',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 6. Sign In Button (single accent color)
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 7. Test Credentials Hint Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                        borderRadius: AppRadius.smRadius,
                        border: Border.all(
                          color: cs.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              'Testing mode: Use email 123 and password 123',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
