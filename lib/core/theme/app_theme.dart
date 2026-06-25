import 'package:flutter/material.dart';

class AppColors {
  // ── Neutral / Backgrounds (sesuai DESIGN_SYSTEM.md §1) ──
  static const background = Color(0xFF060908);       // Neutral Black 1 - bg utama
  static const surface = Color(0xFF141110);           // Neutral Black 2 - header/footer
  static const surfaceElevated = Color(0xFF120F0E);   // Neutral Black 3 - card/panel
  static const surfaceCard = Color(0xFF281D16);       // Brown - card hover
  static const overlayDark = Color(0xFF161210);       // Brown - overlay gelap

  // ── Brand (Primary / Red) ──
  static const primary = Color(0xFFDB202C);
  static const primaryHover = Color(0xFFF6121D);      // hover = lebih cerah, bukan lebih gelap

  // ── Secondary (Emerald - sukses/badge) ──
  static const secondary = Color(0xFF00B14F);

  // ── Text (pakai opacity putih sesuai aturan tipografi §2) ──
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xA6FFFFFF);     // rgba(255,255,255,0.65)
  static const textMuted = Color(0x73FFFFFF);         // rgba(255,255,255,0.45)

  // ── Utility ──
  static const divider = Color(0x1AFFFFFF);           // rgba(255,255,255,0.1)
  static const inputFill = Color(0x1AFFFFFF);         // rgba(255,255,255,0.1) default
  static const inputFillFocus = Color(0x26FFFFFF);    // rgba(255,255,255,0.15) focus
  static const shimmer = Color(0xFF281D16);
  static const shimmerHighlight = Color(0xFF3A2A1E);
  static const success = Color(0xFF00B14F);
  static const error = Color(0xFFDB202C);             // error border/icon = merah (§5)
  static const warning = Color(0xFFE87C03);           // dipakai di OTP screen, dipertahankan
}

class AppRadius {
  static const button = 4.0;
  static const input = 4.0;
  static const dropdown = 4.0;
  static const card = 4.0;
  static const badge = 2.0;
  static const avatar = 8.0;
  static const modal = 8.0;
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      fontFamily: 'Montserrat',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Montserrat',
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      // Skala tipe disesuaikan dengan §2 (Caption 12 / Body 14 / Headline1 22 / Title2 24 / Title1 28 / Header 36 / Display 48)
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 48, letterSpacing: -0.5),
        displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 36, letterSpacing: -0.3),
        headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 28),
        headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 24),
        headlineSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 22),
        titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
        titleSmall: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.textMuted, fontSize: 12),
        labelLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.surfaceCard,
          minimumSize: const Size(double.infinity, 42), // Large/Default §4
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ).copyWith(
          overlayColor: const WidgetStatePropertyAll(AppColors.primaryHover),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: Color(0x4DFFFFFF)), // rgba(255,255,255,0.3) default
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: Color(0x4DFFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.textPrimary), // putih solid saat focus
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}