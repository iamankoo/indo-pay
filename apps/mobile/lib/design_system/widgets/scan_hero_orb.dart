import "dart:ui";

import "package:flutter/material.dart";

import "../indo_pay_colors.dart";
import "../indo_pay_tokens.dart";
import "fintech_icon.dart";

class ScanHeroOrb extends StatelessWidget {
  const ScanHeroOrb({
    super.key,
    required this.diameter,
  });

  final double diameter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: diameter,
      width: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: diameter,
            width: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  IndoPayColors.glowBlue.withValues(alpha: isDark ? 0.4 : 0.22),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                height: diameter * 0.92,
                width: diameter * 0.92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.14 : 0.48),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: diameter * 0.72,
            width: diameter * 0.72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: IndoPayColors.primaryGradient,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
              boxShadow: IndoPayShadows.heroGlow(isDark),
            ),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: IndoPayColors.glowRing,
                  width: 1.4,
                ),
              ),
              child: Center(
                child: FintechIcon(
                  FintechIconGlyph.scan,
                  color: Colors.white,
                  size: diameter * 0.23,
                  strokeWidth: 2.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
