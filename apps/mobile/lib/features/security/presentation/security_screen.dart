import "package:flutter/material.dart";

import "../../../core/app_routes.dart";
import "../../../design_system/indo_pay_colors.dart";
import "../../../design_system/indo_pay_tokens.dart";
import "../../../design_system/indo_pay_typography.dart";
import "../../../design_system/widgets/fintech_icon.dart";
import "../../../design_system/widgets/fintech_tap_scale.dart";
import "../../../design_system/widgets/glass_card.dart";
import "../../../design_system/widgets/indo_pay_backdrop.dart";

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Security")),
      body: IndoPayBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(IndoPaySpacing.page),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: IndoPayColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: FintechIcon(
                            FintechIconGlyph.shield,
                            color: IndoPayColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(width: IndoPaySpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Protection", style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text(
                              "KYC verified",
                              style: IndoPayTypography.mono(
                                size: 12,
                                color: IndoPayColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: IndoPaySpacing.md),
                  Wrap(
                    spacing: IndoPaySpacing.sm,
                    runSpacing: IndoPaySpacing.sm,
                    children: const [
                      _SecurityChip(label: "Device bound"),
                      _SecurityChip(label: "App lock"),
                      _SecurityChip(label: "Transfer checks"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: IndoPaySpacing.xl),
            _SecurityTile(
              icon: FintechIconGlyph.shield,
              label: "Device binding",
              value: "Active",
            ),
            const SizedBox(height: IndoPaySpacing.sm),
            _SecurityTile(
              icon: FintechIconGlyph.shield,
              label: "App lock",
              value: "Recommended",
            ),
            const SizedBox(height: IndoPaySpacing.sm),
            _SecurityTile(
              icon: FintechIconGlyph.transfer,
              label: "Transfer controls",
              value: "Review",
              onTap: () => AppRoute.transfer.push(context),
            ),
            const SizedBox(height: IndoPaySpacing.sm),
            _SecurityTile(
              icon: FintechIconGlyph.support,
              label: "Support",
              value: "Open",
              onTap: () => AppRoute.support.push(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  const _SecurityTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final FintechIconGlyph icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = GlassCard(
      child: Row(
        children: [
          FintechIcon(icon),
          const SizedBox(width: IndoPaySpacing.md),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return FintechTapScale(
      onTap: onTap!,
      child: content,
    );
  }
}

class _SecurityChip extends StatelessWidget {
  const _SecurityChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: IndoPayColors.textPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: IndoPayTypography.mono(size: 12),
      ),
    );
  }
}
