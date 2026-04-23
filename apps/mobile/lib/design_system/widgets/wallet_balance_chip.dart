import "package:flutter/material.dart";

import "../indo_pay_colors.dart";
import "../indo_pay_typography.dart";
import "fintech_tap_scale.dart";

class WalletBalanceChip extends StatefulWidget {
  const WalletBalanceChip({
    super.key,
    required this.amount,
  });

  final int amount;

  @override
  State<WalletBalanceChip> createState() => _WalletBalanceChipState();
}

class _WalletBalanceChipState extends State<WalletBalanceChip> {
  bool _masked = true;

  @override
  Widget build(BuildContext context) {
    return FintechTapScale(
      onTap: () => setState(() => _masked = !_masked),
      enableHaptics: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: IndoPayColors.textPrimary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: IndoPayColors.shellBorder.withValues(alpha: 0.8),
          ),
        ),
        child: Text(
          _masked ? "INR ****" : "INR ${widget.amount}",
          style: IndoPayTypography.mono(
            color: IndoPayColors.textPrimary,
            size: 13,
            weight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
