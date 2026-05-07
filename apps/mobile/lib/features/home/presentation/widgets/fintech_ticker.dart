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
    duration: const Duration(seconds: 16),
  )..repeat();

  static const List<String> _line1 = [
    "Gold prices rise this week",
    "UPI safety tip of the day",
    "Save more with recurring deposits",
    "Digital payments growing rapidly",
  ];

  static const List<String> _line2 = [
    "Track spending before weekend transfers",
    "Cardless payments gain momentum",
    "Keep alerts active for every debit",
    "Daily budgeting improves cash flow",
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
          _TickerStrip(
            controller: _controller,
            items: _line1,
          ),
          const SizedBox(height: 8),
          _TickerStrip(
            controller: _controller,
            items: _line2,
            reverse: true,
          ),
        ],
      ),
    );
  }

}

class _TickerStrip extends StatelessWidget {
  const _TickerStrip({
    required this.controller,
    required this.items,
    this.reverse = false,
  });

  final Animation<double> controller;
  final List<String> items;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    const estimatedChipWidth = 220.0;
    final stripWidth = items.length * estimatedChipWidth;

    return SizedBox(
      height: 32,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final travel = (controller.value * stripWidth) % stripWidth;
            final offset = reverse ? travel - stripWidth : -travel;

            return Transform.translate(
              offset: Offset(offset, 0),
              child: Row(
                children: [
                  _TickerRow(items: items),
                  const SizedBox(width: 12),
                  _TickerRow(items: items),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TickerRow extends StatelessWidget {
  const _TickerRow({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map((text) => _TickerChip(text: text))
          .toList(growable: false),
    );
  }
}

class _TickerChip extends StatelessWidget {
  const _TickerChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
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
