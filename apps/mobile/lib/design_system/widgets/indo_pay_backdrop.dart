import "package:flutter/material.dart";

import "../indo_pay_colors.dart";

class IndoPayBackdrop extends StatelessWidget {
  const IndoPayBackdrop({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isDark
            ? IndoPayColors.darkBackground
            : IndoPayColors.lightBackground,
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -110,
            right: -32,
            child: _BackdropGlow(
              size: 220,
              color: IndoPayColors.backdropGlowAccent,
            ),
          ),
          const Positioned(
            top: 180,
            left: -72,
            child: _BackdropGlow(
              size: 190,
              color: IndoPayColors.backdropGlowPrimary,
            ),
          ),
          const Positioned(
            right: -44,
            bottom: 48,
            child: _BackdropGlow(
              size: 170,
              color: IndoPayColors.backdropGlowSuccess,
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _BackdropGlow extends StatelessWidget {
  const _BackdropGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
