import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart'; // Keep for now but don't use it to avoid crashes

/// 5 Built-in Themes + Custom
enum AppThemeMode {
  cashewDark,
  cashewLight,
  midnight,
  forest,
  custom,
}

extension AppThemeModeExt on AppThemeMode {
  String get displayName {
    switch (this) {
      case AppThemeMode.cashewDark: return 'Cashew Dark';
      case AppThemeMode.cashewLight: return 'Cashew Light';
      case AppThemeMode.midnight: return 'Midnight';
      case AppThemeMode.forest: return 'Forest';
      case AppThemeMode.custom: return 'Custom';
    }
  }

  String get description {
    switch (this) {
      case AppThemeMode.cashewDark: return 'Deep navy + amber/gold';
      case AppThemeMode.cashewLight: return 'Cream + warm brown';
      case AppThemeMode.midnight: return 'Pure dark + cyan/teal';
      case AppThemeMode.forest: return 'Dark green + lime';
      case AppThemeMode.custom: return 'Your custom colors';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.cashewDark: return Icons.dark_mode;
      case AppThemeMode.cashewLight: return Icons.light_mode;
      case AppThemeMode.midnight: return Icons.nightlight_round;
      case AppThemeMode.forest: return Icons.park;
      case AppThemeMode.custom: return Icons.palette;
    }
  }
}

/// Theme Provider — manages current theme, persists in SharedPreferences
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.cashewDark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_mode') ?? 0;
    state = AppThemeMode.values[index];
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

/// Generate ThemeData for each theme mode
ThemeData getThemeData(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.cashewDark:
      return _buildTheme(
        brightness: Brightness.dark,
        bgMain: const Color(0xFF0D0D0D),
        bgCard: const Color(0xFF1A1A2E),
        bgSurface: const Color(0xFF16213E),
        bgInput: const Color(0xFF232946),
        primary: const Color(0xFFD4A017),
        secondary: const Color(0xFFFFB300),
        accent: const Color(0xFFFFD54F),
        textPrimary: const Color(0xFFEEEEEE),
        textSecondary: const Color(0xFFB0BEC5),
        textMuted: const Color(0xFF78909C),
        glassBorder: const Color(0x33FFFFFF),
      );
    case AppThemeMode.cashewLight:
      return _buildTheme(
        brightness: Brightness.light,
        bgMain: const Color(0xFFFFF8E1),
        bgCard: const Color(0xFFFFFFFF),
        bgSurface: const Color(0xFFFFF3E0),
        bgInput: const Color(0xFFF5F5F5),
        primary: const Color(0xFF8B6914),
        secondary: const Color(0xFF5D4037),
        accent: const Color(0xFFD4A017),
        textPrimary: const Color(0xFF212121),
        textSecondary: const Color(0xFF616161),
        textMuted: const Color(0xFF9E9E9E),
        glassBorder: const Color(0x1A000000),
      );
    case AppThemeMode.midnight:
      return _buildTheme(
        brightness: Brightness.dark,
        bgMain: const Color(0xFF121212),
        bgCard: const Color(0xFF1E1E1E),
        bgSurface: const Color(0xFF252525),
        bgInput: const Color(0xFF2C2C2C),
        primary: const Color(0xFF18FFFF),
        secondary: const Color(0xFF009688),
        accent: const Color(0xFF64FFDA),
        textPrimary: const Color(0xFFE0E0E0),
        textSecondary: const Color(0xFF9E9E9E),
        textMuted: const Color(0xFF757575),
        glassBorder: const Color(0x33FFFFFF),
      );
    case AppThemeMode.forest:
      return _buildTheme(
        brightness: Brightness.dark,
        bgMain: const Color(0xFF0A1A0A),
        bgCard: const Color(0xFF1B2A1B),
        bgSurface: const Color(0xFF1E331E),
        bgInput: const Color(0xFF243D24),
        primary: const Color(0xFF76FF03),
        secondary: const Color(0xFF00E676),
        accent: const Color(0xFFB2FF59),
        textPrimary: const Color(0xFFE0E0E0),
        textSecondary: const Color(0xFFA5D6A7),
        textMuted: const Color(0xFF81C784),
        glassBorder: const Color(0x3376FF03),
      );
    case AppThemeMode.custom:
      // Default custom = same as cashew dark (user can override)
      return _buildTheme(
        brightness: Brightness.dark,
        bgMain: const Color(0xFF0D0D0D),
        bgCard: const Color(0xFF1A1A2E),
        bgSurface: const Color(0xFF16213E),
        bgInput: const Color(0xFF232946),
        primary: const Color(0xFFD4A017),
        secondary: const Color(0xFFFFB300),
        accent: const Color(0xFFFFD54F),
        textPrimary: const Color(0xFFEEEEEE),
        textSecondary: const Color(0xFFB0BEC5),
        textMuted: const Color(0xFF78909C),
        glassBorder: const Color(0x33FFFFFF),
      );
  }
}

ThemeData _buildTheme({
  required Brightness brightness,
  required Color bgMain,
  required Color bgCard,
  required Color bgSurface,
  required Color bgInput,
  required Color primary,
  required Color secondary,
  required Color accent,
  required Color textPrimary,
  required Color textSecondary,
  required Color textMuted,
  required Color glassBorder,
}) {
  final isLight = brightness == Brightness.light;
  final onPrimary = isLight ? Colors.white : const Color(0xFF1A1A2E);
  final baseTextTheme = isLight ? ThemeData.light().textTheme.apply(fontFamily: 'Inter') : ThemeData.dark().textTheme.apply(fontFamily: 'Inter');

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: bgMain,

    colorScheme: ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onPrimary,
      surface: bgCard,
      onSurface: textPrimary,
      error: const Color(0xFFFF5252),
      onError: Colors.white,
      outline: glassBorder,
      tertiary: accent,
      surfaceContainerHighest: bgInput,
    ),

    textTheme: baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
      titleLarge: baseTextTheme.titleLarge?.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
      titleMedium: baseTextTheme.titleMedium?.copyWith(color: textPrimary, fontWeight: FontWeight.w500),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textPrimary),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textSecondary),
      bodySmall: baseTextTheme.bodySmall?.copyWith(color: textMuted),
      labelLarge: baseTextTheme.labelLarge?.copyWith(color: onPrimary, fontWeight: FontWeight.w600),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: bgMain,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
      iconTheme: IconThemeData(color: primary),
    ),

    cardTheme: CardThemeData(
      color: bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: glassBorder, width: 0.5),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgInput,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: glassBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: glassBorder, width: 0.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF5252))),
      labelStyle: TextStyle(color: textSecondary),
      hintStyle: TextStyle(color: textMuted),
    ),

    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: bgCard,
      selectedIconTheme: IconThemeData(color: primary),
      unselectedIconTheme: IconThemeData(color: textMuted),
      selectedLabelTextStyle: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelTextStyle: TextStyle(color: textMuted, fontSize: 11),
      indicatorColor: primary.withValues(alpha: 0.15),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: bgCard,
      selectedItemColor: primary,
      unselectedItemColor: textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      elevation: 4,
    ),

    dividerTheme: DividerThemeData(color: glassBorder, thickness: 0.5, space: 1),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: bgSurface,
      contentTextStyle: TextStyle(color: textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: bgInput,
      selectedColor: primary.withValues(alpha: 0.2),
      side: BorderSide(color: glassBorder, width: 0.5),
      labelStyle: TextStyle(color: textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? primary : textMuted),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? primary.withValues(alpha: 0.3) : bgInput),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(color: primary, linearTrackColor: bgInput),

    tabBarTheme: TabBarThemeData(
      labelColor: primary,
      unselectedLabelColor: textMuted,
      indicatorColor: primary,
      dividerColor: glassBorder,
    ),
  );
}
