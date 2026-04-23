import "package:flutter/material.dart";

import "../indo_pay_colors.dart";
import "../indo_pay_typography.dart";

class NotificationDot extends StatelessWidget {
  const NotificationDot({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    final label = count > 99 ? "99+" : "$count";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: IndoPayColors.danger,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 1.4),
      ),
      child: Text(
        label,
        style: IndoPayTypography.mono(
          color: Colors.white,
          size: 10,
          weight: FontWeight.w700,
        ),
      ),
    );
  }
}
