import "dart:ui";

import "package:flutter/material.dart";

import "../indo_pay_colors.dart";
import "../indo_pay_tokens.dart";
import "fintech_icon.dart";
import "fintech_tap_scale.dart";

class FintechActionCard extends StatelessWidget {
  const FintechActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final FintechIconGlyph icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FintechTapScale(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(IndoPayRadii.lg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(IndoPaySpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(IndoPayRadii.lg),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : IndoPayColors.shellBorder.withValues(alpha: 0.9),
              ),
              gradient: LinearGradient(
                colors: [
                  (isDark ? IndoPayColors.cardDark : Colors.white).withValues(alpha: 0.94),
                  (isDark ? const Color(0xFF111528) : const Color(0xFFFDFDFF))
                      .withValues(alpha: 0.88),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: IndoPayShadows.surface(isDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: IndoPayColors.primary.withValues(alpha: isDark ? 0.22 : 0.08),
                  ),
                  child: Center(
                    child: FintechIcon(
                      icon,
                      color: isDark ? Colors.white : IndoPayColors.textPrimary,
                    ),
                  ),
                ),
                const Spacer(),
                Text(label, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
