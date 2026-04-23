import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../indo_pay_tokens.dart";

class FintechTapScale extends StatefulWidget {
  const FintechTapScale({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.96,
    this.enableHaptics = true,
  });

  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final bool enableHaptics;

  @override
  State<FintechTapScale> createState() => _FintechTapScaleState();
}

class _FintechTapScaleState extends State<FintechTapScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        if (widget.enableHaptics) {
          HapticFeedback.lightImpact();
        }
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: IndoPayMotion.press,
        curve: IndoPayMotion.interactive,
        child: widget.child,
      ),
    );
  }
}
