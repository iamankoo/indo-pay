import "package:flutter/material.dart";

class IndoPaySpacing {
  const IndoPaySpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double page = 24;
  static const double navBottom = 110;
}

class IndoPayRadii {
  const IndoPayRadii._();

  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 28;
  static const double xxl = 32;
  static const double pill = 999;
}

class IndoPayMotion {
  const IndoPayMotion._();

  static const Duration standard = Duration(milliseconds: 220);
  static const Duration hero = Duration(milliseconds: 350);
  static const Duration press = Duration(milliseconds: 100);
  static const Duration splash = Duration(seconds: 1);
  static const Duration pulse = Duration(seconds: 2);

  static const Curve interactive = Curves.easeOutExpo;
  static const Curve enter = Curves.easeOut;
}

class IndoPayShadows {
  const IndoPayShadows._();

  static List<BoxShadow> surface(bool isDark) => [
        BoxShadow(
          color: isDark
              ? const Color(0x40000000)
              : const Color(0x160B1020),
          blurRadius: 28,
          offset: const Offset(0, 16),
        ),
      ];

  static List<BoxShadow> heroGlow(bool isDark) => [
        BoxShadow(
          color: isDark
              ? const Color(0x552B7FFF)
              : const Color(0x382B7FFF),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> nav(bool isDark) => [
        BoxShadow(
          color: isDark
              ? const Color(0x55000000)
              : const Color(0x1A0F0F1A),
          blurRadius: 36,
          offset: const Offset(0, 18),
        ),
      ];
}
