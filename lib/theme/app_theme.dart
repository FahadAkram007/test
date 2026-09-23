import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Simplified neutral/monochrome design system for KollektivO.
///
/// Features a clean, distraction-free aesthetic with subtle slate/neutral surfaces
/// and a single refined accent color (Deep Teal #0F766E) used strictly for
/// active states and primary calls-to-action.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // MONOCHROME & ACCENT PALETTE
  // ---------------------------------------------------------------------------
  /// Single focused accent color: Deep Teal
  static const Color primaryAccent = Color(0xFF0F766E);
  static const Color primarySeed = primaryAccent;
  static const Color secondarySeed = primaryAccent;

  /// Neutral tones (Slate scale)
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);

  // Semantic Status (restrained)
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);

  // Surface colors
  static const Color lightBackground = Color(0xFFF8FAFC); // Clean neutral off-white
  static const Color lightCard = Colors.white;
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);

  // ---------------------------------------------------------------------------
  // COLOR SCHEMES
  // ---------------------------------------------------------------------------
  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryAccent,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFCCECE8),
    onPrimaryContainer: const Color(0xFF042F2E),
    secondary: slate700,
    onSecondary: Colors.white,
    secondaryContainer: slate100,
    onSecondaryContainer: slate800,
    tertiary: slate500,
    onTertiary: Colors.white,
    error: error,
    onError: Colors.white,
    surface: lightBackground,
    onSurface: slate900,
    onSurfaceVariant: slate600,
    outline: slate300,
    outlineVariant: slate200,
    surfaceContainerHighest: slate100,
  );

  static final ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF14B8A6), // Teal 500 for high dark-mode contrast
    onPrimary: slate900,
    primaryContainer: const Color(0xFF115E59),
    onPrimaryContainer: const Color(0xFFCCECE8),
    secondary: slate300,
    onSecondary: slate900,
    secondaryContainer: slate800,
    onSecondaryContainer: slate200,
    tertiary: slate400,
    onTertiary: slate900,
    error: const Color(0xFFEF4444),
    onError: Colors.white,
    surface: darkBackground,
    onSurface: const Color(0xFFF1F5F9),
    onSurfaceVariant: slate400,
    outline: slate600,
    outlineVariant: slate700,
    surfaceContainerHighest: slate800,
  );

  // ---------------------------------------------------------------------------
  // TYPOGRAPHY: Plus Jakarta Sans (Headings) + Inter (Body/UI)
  // ---------------------------------------------------------------------------
  static TextTheme _buildTextTheme(TextTheme baseTextTheme) {
    final base = GoogleFonts.interTextTheme(baseTextTheme);

    return base.copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        textStyle: base.displayLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
        ),
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        textStyle: base.displayMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        textStyle: base.displaySmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
        ),
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        textStyle: base.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        textStyle: base.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
        ),
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        textStyle: base.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        textStyle: base.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.15,
        ),
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        textStyle: base.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        textStyle: base.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      bodyLarge: GoogleFonts.inter(
        textStyle: base.bodyLarge?.copyWith(
          letterSpacing: 0.15,
          height: 1.5,
        ),
      ),
      bodyMedium: GoogleFonts.inter(
        textStyle: base.bodyMedium?.copyWith(
          letterSpacing: 0.2,
          height: 1.45,
        ),
      ),
      bodySmall: GoogleFonts.inter(
        textStyle: base.bodySmall?.copyWith(
          letterSpacing: 0.3,
        ),
      ),
      labelLarge: GoogleFonts.inter(
        textStyle: base.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LIGHT THEME (Minimalist, Neutral, One Accent)
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
    );
    final textTheme = _buildTextTheme(baseTheme.textTheme);

    return FlexThemeData.light(
      colorScheme: lightColorScheme,
      useMaterial3: true,
      textTheme: textTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      subThemesData: const FlexSubThemesData(
        interactionEffects: true,
        useM2StyleDividerInM3: false,
        defaultRadius: AppRadius.md,
        cardElevation: 0.0,
        cardRadius: AppRadius.md,
        elevatedButtonElevation: 0.0,
        elevatedButtonRadius: AppRadius.sm,
        filledButtonRadius: AppRadius.sm,
        outlinedButtonRadius: AppRadius.sm,
        inputDecoratorRadius: AppRadius.sm,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorUnfocusedHasBorder: true,
        bottomSheetRadius: AppRadius.lg,
        dialogRadius: AppRadius.lg,
        chipRadius: AppRadius.full,
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarSelectedIconSchemeColor: SchemeColor.primary,
        navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
      ),
    ).copyWith(
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: slate200, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: slate300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: primaryAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: error, width: 1),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DARK THEME (Sleek Dark Slate, One Accent)
  // ---------------------------------------------------------------------------
  static ThemeData get darkTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
    );
    final textTheme = _buildTextTheme(baseTheme.textTheme);

    return FlexThemeData.dark(
      colorScheme: darkColorScheme,
      useMaterial3: true,
      textTheme: textTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      subThemesData: const FlexSubThemesData(
        interactionEffects: true,
        useM2StyleDividerInM3: false,
        defaultRadius: AppRadius.md,
        cardElevation: 0.0,
        cardRadius: AppRadius.md,
        elevatedButtonElevation: 0.0,
        elevatedButtonRadius: AppRadius.sm,
        filledButtonRadius: AppRadius.sm,
        outlinedButtonRadius: AppRadius.sm,
        inputDecoratorRadius: AppRadius.sm,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorUnfocusedHasBorder: true,
        bottomSheetRadius: AppRadius.lg,
        dialogRadius: AppRadius.lg,
        chipRadius: AppRadius.full,
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarSelectedIconSchemeColor: SchemeColor.primary,
        navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
      ),
    ).copyWith(
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: slate700, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: darkColorScheme.primary,
          foregroundColor: slate900,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: slate700, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: darkColorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: darkColorScheme.error, width: 1),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 8-POINT SPATIAL GRID SYSTEM
// ---------------------------------------------------------------------------
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;

  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets horizontalScreen = EdgeInsets.symmetric(horizontal: md);
}

// ---------------------------------------------------------------------------
// CORNER RADII TOKENS
// ---------------------------------------------------------------------------
class AppRadius {
  AppRadius._();

  static const double xs = 6.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double full = 999.0;

  static final BorderRadius xsRadius = BorderRadius.circular(xs);
  static final BorderRadius smRadius = BorderRadius.circular(sm);
  static final BorderRadius mdRadius = BorderRadius.circular(md);
  static final BorderRadius lgRadius = BorderRadius.circular(lg);
  static final BorderRadius fullRadius = BorderRadius.circular(full);
}

// ---------------------------------------------------------------------------
// SOFT MONOCHROMATIC SHADOWS
// ---------------------------------------------------------------------------
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x06000000), // Very light 2.5% opacity
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x08000000), // 3% opacity
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  static List<BoxShadow> heroVoucherGlow(Color primaryColor) => [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.18),
      blurRadius: 20,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];
}
