import "package:flutter/material.dart";

import "indo_pay_colors.dart";
import "indo_pay_typography.dart";

ThemeData buildIndoPayTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final surface = isDark ? IndoPayColors.surfaceDark : IndoPayColors.surface;
  final card = isDark ? IndoPayColors.cardDark : IndoPayColors.card;
  final text = isDark ? IndoPayColors.textPrimaryDark : IndoPayColors.textPrimary;
  final muted = isDark ? IndoPayColors.textSecondaryDark : IndoPayColors.textSecondary;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: IndoPayColors.primary,
    onPrimary: Colors.white,
    secondary: IndoPayColors.accent,
    onSecondary: Colors.white,
    error: IndoPayColors.danger,
    onError: Colors.white,
    surface: surface,
    onSurface: text,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: surface,
    textTheme: IndoPayTypography.buildTextTheme(
      primary: text,
      secondary: muted,
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: text,
      titleTextStyle: ThemeData(brightness: brightness).textTheme.titleLarge?.copyWith(
            color: text,
            fontFamily: IndoPayTypography.bodyFamily,
            fontFamilyFallback: IndoPayTypography.bodyFallback,
            fontWeight: FontWeight.w700,
          ),
    ),
    dividerColor: muted.withValues(alpha: 0.14),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? const Color(0xFF171A28) : const Color(0xFF111325),
      contentTextStyle: IndoPayTypography.buildTextTheme(
        primary: Colors.white,
        secondary: Colors.white70,
      ).bodyMedium,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
