import "package:flutter/material.dart";

class IndoPayColors {
  const IndoPayColors._();

  static const primary = Color(0xFF3D2EAF);
  static const accent = Color(0xFF2B7FFF);
  static const success = Color(0xFF00C48C);
  static const surface = Color(0xFFF8F8FC);
  static const card = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0F0F1A);
  static const textSecondary = Color(0xFF6B6B80);
  static const danger = Color(0xFFE5383B);

  static const surfaceDark = Color(0xFF090B14);
  static const cardDark = Color(0xFF121624);
  static const textPrimaryDark = Color(0xFFF5F7FF);
  static const textSecondaryDark = Color(0xFFA7ADC7);

  static const heroStart = Color(0xFF2B1F8F);
  static const heroEnd = Color(0xFF2B7FFF);
  static const glowRing = Color(0x663D2EAF);
  static const glowBlue = Color(0x4D2B7FFF);
  static const shellBorder = Color(0x1F0F0F1A);
  static const chipSurface = Color(0x140F0F1A);
  static const backdropGlowAccent = Color(0x262B7FFF);
  static const backdropGlowPrimary = Color(0x223D2EAF);
  static const backdropGlowSuccess = Color(0x1F00C48C);
  static const accentSoft = Color(0x140B4DFF);
  static const successSoft = Color(0x141BA97C);
  static const warningSoft = Color(0x14FFA028);
  static const dangerSoft = Color(0x14E04F5F);
  static const dangerForeground = Color(0xFFE04F5F);

  static const lightBackground = LinearGradient(
    colors: [
      Color(0xFFF8F8FC),
      Color(0xFFF0F4FF),
      Color(0xFFF8F8FC),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkBackground = LinearGradient(
    colors: [
      Color(0xFF090B14),
      Color(0xFF121930),
      Color(0xFF090B14),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const primaryGradient = LinearGradient(
    colors: [
      heroStart,
      heroEnd,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const glassGradient = LinearGradient(
    colors: [
      Color(0xE6FFFFFF),
      Color(0xBFFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const fintechBlue = accent;
  static const fintechBlueDeep = heroStart;
  static const saffron = Color(0xFFFFA028);
  static const shell = Color(0xFFEAF1FF);
  static const ink = textPrimary;
  static const inkMuted = textSecondary;
}
