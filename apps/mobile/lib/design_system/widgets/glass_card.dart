import "dart:ui";

import "package:flutter/material.dart";

import "../indo_pay_colors.dart";
import "../indo_pay_tokens.dart";

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = IndoPayRadii.xl,
    this.borderColor,
    this.backgroundColor,
    this.blur = 18,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? borderColor;
  final Color? backgroundColor;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = backgroundColor ??
        (isDark ? IndoPayColors.cardDark.withValues(alpha: 0.74) : Colors.white.withValues(alpha: 0.86));

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor ??
                  (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : IndoPayColors.shellBorder.withValues(alpha: 0.9)),
            ),
            gradient: LinearGradient(
              colors: [
                surface,
                surface.withValues(alpha: isDark ? 0.7 : 0.76),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: IndoPayShadows.surface(isDark),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
