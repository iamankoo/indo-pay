import "package:flutter/material.dart";

import "../../../../design_system/indo_pay_colors.dart";
import "../../../../design_system/indo_pay_tokens.dart";

class FintechTicker extends StatefulWidget {
  const FintechTicker({super.key});

  @override
  State<FintechTicker> createState() => _FintechTickerState();
}

class _FintechTickerState extends State<FintechTicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  final List<String> _line1 = [
    "Invest in gold this month",
    "Start SIP for long-term wealth",
    "Save before you spend",
    "Emergency fund is important",
  ];

  final List<String> _line2 = [
    "UPI safety tip of the day",
    "RBI digital payment update",
    "Smart savings improve freedom",
    "Track your monthly expenses",
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: IndoPaySpacing.md),
      padding: const EdgeInsets.symmetric(vertical: IndoPaySpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? IndoPayColors.shell.withValues(alpha: 0.5)
            : IndoPayColors.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(IndoPayRadii.lg),
        border: Border.all(
          color: IndoPayColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: IndoPaySpacing.md),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 18,
                  color: IndoPayColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  "Smart Insights",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: IndoPayColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      left: -(_controller.value * 500) % 500,
                      child: _buildRow(_line1),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      right: -(_controller.value * 500) % 500,
                      child: _buildRow(_line2),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> items) {
    return Row(
      children: [
        for (int i = 0; i < 4; i++) // Repeat for infinite scroll effect
          ...items.map((text) => _buildChip(text)),
      ],
    );
  }

  Widget _buildChip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(IndoPayRadii.pill),
        border: Border.all(
          color: IndoPayColors.shellBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
