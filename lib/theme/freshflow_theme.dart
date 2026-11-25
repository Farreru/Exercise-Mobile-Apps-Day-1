import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens & Material 3 theme untuk FreshFlow Modern Laundry OS.
class FreshFlowColors {
  const FreshFlowColors._();

  static const Color background = Color(0xFFF9F9FF);
  static const Color surface = Color(0xFFF9F9FF);
  static const Color surfaceDim = Color(0xFFCFDAF2);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF0F3FF);
  static const Color surfaceContainer = Color(0xFFE7EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDEE8FF);
  static const Color surfaceContainerHighest = Color(0xFFD8E3FB);

  static const Color onSurface = Color(0xFF111C2D);
  static const Color onSurfaceVariant = Color(0xFF434655);
  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFC3C6D7);

  static const Color inverseSurface = Color(0xFF263143);
  static const Color inverseOnSurface = Color(0xFFECF1FF);

  static const Color primary = Color(0xFF004AC6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF2563EB);
  static const Color onPrimaryContainer = Color(0xFFEEEFFF);
  static const Color primaryFixed = Color(0xFFDBE1FF);
  static const Color onPrimaryFixed = Color(0xFF00174B);

  static const Color secondary = Color(0xFF9D4300);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFD761A);
  static const Color onSecondaryContainer = Color(0xFF5C2400);
  static const Color secondaryFixed = Color(0xFFFFDBCA);
  static const Color onSecondaryFixed = Color(0xFF341100);
  static const Color onSecondaryFixedVariant = Color(0xFF783200);

  static const Color tertiary = Color(0xFF006242);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF007D55);
  static const Color onTertiaryContainer = Color(0xFFBDFFDB);
  static const Color tertiaryFixed = Color(0xFF6FFBBE);
  static const Color onTertiaryFixed = Color(0xFF002113);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
}

class FreshFlowTheme {
  const FreshFlowTheme._();

  static const double margin = 20;
  static const double radiusDefault = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 32;

  static List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: Color(0x0A0F172A),
          blurRadius: 24,
          offset: Offset(0, 8),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: Color(0x050F172A),
          blurRadius: 6,
          offset: Offset(0, 2),
          spreadRadius: -1,
        ),
      ];

  static List<BoxShadow> get primaryShadow => const [
        BoxShadow(
          color: Color(0x382563EB),
          blurRadius: 20,
          offset: Offset(0, 8),
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> get secondaryShadow => const [
        BoxShadow(
          color: Color(0x40FD761A),
          blurRadius: 16,
          offset: Offset(0, 6),
          spreadRadius: -2,
        ),
      ];

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: FreshFlowColors.primary,
      onPrimary: FreshFlowColors.onPrimary,
      primaryContainer: FreshFlowColors.primaryContainer,
      onPrimaryContainer: FreshFlowColors.onPrimaryContainer,
      secondary: FreshFlowColors.secondary,
      onSecondary: FreshFlowColors.onSecondary,
      secondaryContainer: FreshFlowColors.secondaryContainer,
      onSecondaryContainer: FreshFlowColors.onSecondaryContainer,
      tertiary: FreshFlowColors.tertiary,
      onTertiary: FreshFlowColors.onTertiary,
      tertiaryContainer: FreshFlowColors.tertiaryContainer,
      onTertiaryContainer: FreshFlowColors.onTertiaryContainer,
      error: FreshFlowColors.error,
      onError: FreshFlowColors.onError,
      errorContainer: FreshFlowColors.errorContainer,
      onErrorContainer: FreshFlowColors.onErrorContainer,
      surface: FreshFlowColors.surface,
      onSurface: FreshFlowColors.onSurface,
      surfaceContainerLowest: FreshFlowColors.surfaceContainerLowest,
      surfaceContainerLow: FreshFlowColors.surfaceContainerLow,
      surfaceContainer: FreshFlowColors.surfaceContainer,
      surfaceContainerHigh: FreshFlowColors.surfaceContainerHigh,
      surfaceContainerHighest: FreshFlowColors.surfaceContainerHighest,
      onSurfaceVariant: FreshFlowColors.onSurfaceVariant,
      outline: FreshFlowColors.outline,
      outlineVariant: FreshFlowColors.outlineVariant,
      inverseSurface: FreshFlowColors.inverseSurface,
      onInverseSurface: FreshFlowColors.inverseOnSurface,
      surfaceTint: Color(0xFF0053DB),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: FreshFlowColors.background,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          height: 38 / 30,
          letterSpacing: -0.75,
          color: FreshFlowColors.onSurface,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 28 / 20,
          letterSpacing: -0.3,
          color: FreshFlowColors.onSurface,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          height: 24 / 17,
          color: FreshFlowColors.onSurface,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 24 / 16,
          color: FreshFlowColors.onSurface,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          color: FreshFlowColors.onSurface,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 18 / 13,
          color: FreshFlowColors.onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 18 / 14,
          color: FreshFlowColors.onSurface,
        ),
        labelMedium: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 16 / 12,
          letterSpacing: 0.12,
          color: FreshFlowColors.onSurfaceVariant,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 14 / 11,
          letterSpacing: 0.33,
          color: FreshFlowColors.onSurfaceVariant,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FreshFlowColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: FreshFlowColors.primaryContainer,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FreshFlowColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FreshFlowColors.error, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: FreshFlowColors.primaryContainer,
          foregroundColor: FreshFlowColors.onPrimaryContainer,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
