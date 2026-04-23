import "package:flutter/material.dart";

import "indo_pay_colors.dart";

class IndoPayTypography {
  const IndoPayTypography._();

  static const String bodyFamily = "DM Sans";
  static const String monoFamily = "JetBrains Mono";
  static const List<String> bodyFallback = <String>["sans-serif"];
  static const List<String> monoFallback = <String>["monospace"];

  static TextTheme buildTextTheme({
    required Color primary,
    required Color secondary,
  }) {
    return TextTheme(
      displaySmall: _body(
        size: 30,
        weight: FontWeight.w700,
        color: primary,
        height: 1.05,
        spacing: -0.8,
      ),
      headlineMedium: _body(
        size: 28,
        weight: FontWeight.w700,
        color: primary,
        height: 1.08,
        spacing: -0.7,
      ),
      headlineSmall: _body(
        size: 24,
        weight: FontWeight.w700,
        color: primary,
        height: 1.1,
        spacing: -0.5,
      ),
      titleLarge: _body(
        size: 18,
        weight: FontWeight.w700,
        color: primary,
        height: 1.2,
      ),
      titleMedium: _body(
        size: 16,
        weight: FontWeight.w700,
        color: primary,
        height: 1.2,
      ),
      bodyLarge: _body(
        size: 16,
        weight: FontWeight.w500,
        color: primary,
        height: 1.3,
      ),
      bodyMedium: _body(
        size: 14,
        weight: FontWeight.w500,
        color: secondary,
        height: 1.3,
      ),
      labelLarge: _body(
        size: 14,
        weight: FontWeight.w700,
        color: primary,
        height: 1.2,
      ),
      labelMedium: _body(
        size: 12,
        weight: FontWeight.w600,
        color: secondary,
        height: 1.2,
      ),
    );
  }

  static TextStyle mono({
    Color color = IndoPayColors.textPrimary,
    double size = 13,
    FontWeight weight = FontWeight.w600,
    double height = 1.2,
  }) {
    return TextStyle(
      fontFamily: monoFamily,
      fontFamilyFallback: monoFallback,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      letterSpacing: -0.1,
    );
  }

  static TextStyle _body({
    required double size,
    required FontWeight weight,
    required Color color,
    required double height,
    double spacing = 0,
  }) {
    return TextStyle(
      fontFamily: bodyFamily,
      fontFamilyFallback: bodyFallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: spacing,
    );
  }
}
