import 'package:flutter/material.dart';

/// CashewPro ERP — Premium Dark Theme with Amber/Gold Cashew Branding
class AppTheme {
  AppTheme._();

  // ─── Brand Colors ───
  static const Color primaryGold = Color(0xFFD4A017);
  static const Color primaryAmber = Color(0xFFFFB300);
  static const Color primaryLight = Color(0xFFFFD54F);
  static const Color primaryDark = Color(0xFF8B6914);

  // ─── Background Colors ───
  static const Color bgDark = Color(0xFF0D0D0D);
  static const Color bgCard = Color(0xFF1A1A2E);
  static const Color bgSurface = Color(0xFF16213E);
  static const Color bgElevated = Color(0xFF1F2940);
  static const Color bgInput = Color(0xFF232946);

  // ─── Accent Colors ───
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentRed = Color(0xFFFF5252);
  static const Color accentBlue = Color(0xFF448AFF);
  static const Color accentOrange = Color(0xFFFF9100);
  static const Color accentPurple = Color(0xFFB388FF);
  static const Color accentCyan = Color(0xFF18FFFF);

  // ─── Status Colors ───
  static const Color statusRunning = Color(0xFF00E676);
  static const Color statusIdle = Color(0xFFFFD54F);
  static const Color statusMaintenance = Color(0xFFFF9100);
  static const Color statusBreakdown = Color(0xFFFF5252);
  static const Color statusPending = Color(0xFF78909C);
  static const Color statusCompleted = Color(0xFF00E676);

  // ─── Text Colors ───
  static const Color textPrimary = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF78909C);
  static const Color textOnPrimary = Color(0xFF1A1A2E);

  // ─── Glassmorphism ───
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // ─── Gradients ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGold, primaryAmber],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D0D0D), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Border Radius ───
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // ─── Spacing ───
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;

  // ─── Shadows ───
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primaryGold.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  // ─── Glass Card Decoration ───
  static BoxDecoration get glassCard => BoxDecoration(
    color: glassWhite,
    borderRadius: BorderRadius.circular(radiusLg),
    border: Border.all(color: glassBorder, width: 1),
    boxShadow: cardShadow,
  );

  // ─── Theme Data ───
  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme.apply(fontFamily: 'Inter');

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        onPrimary: textOnPrimary,
        secondary: primaryAmber,
        onSecondary: textOnPrimary,
        surface: bgCard,
        onSurface: textPrimary,
        error: accentRed,
        onError: Colors.white,
        outline: glassBorder,
      ),

      // Text Theme
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textPrimary),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textSecondary),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: textMuted),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: textOnPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: primaryGold),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: glassBorder, width: 0.5),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGold,
          side: const BorderSide(color: primaryGold, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGold,
          textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: glassBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primaryGold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: accentRed),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
      ),

      // Bottom Nav
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: primaryGold,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGold,
        foregroundColor: textOnPrimary,
        elevation: 4,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: glassBorder,
        thickness: 0.5,
        space: 1,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgElevated,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: bgInput,
        selectedColor: primaryGold.withValues(alpha: 0.2),
        side: const BorderSide(color: glassBorder, width: 0.5),
        labelStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryGold;
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGold.withValues(alpha: 0.3);
          }
          return bgInput;
        }),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGold,
        linearTrackColor: bgInput,
      ),
    );
  }
}
