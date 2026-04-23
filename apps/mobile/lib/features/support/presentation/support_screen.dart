import "package:flutter/material.dart";

import "../../../core/app_routes.dart";
import "../../../design_system/indo_pay_tokens.dart";
import "../../../design_system/widgets/fintech_icon.dart";
import "../../../design_system/widgets/fintech_tap_scale.dart";
import "../../../design_system/widgets/glass_card.dart";
import "../../../design_system/widgets/indo_pay_backdrop.dart";

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Support")),
      body: IndoPayBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(IndoPaySpacing.page),
          children: [
            GlassCard(
              child: Row(
                children: [
                  const FintechIcon(FintechIconGlyph.support),
                  const SizedBox(width: IndoPaySpacing.md),
                  Expanded(
                    child: Text(
                      "Choose a flow",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: IndoPaySpacing.xl),
            _SupportTile(
              icon: FintechIconGlyph.passbook,
              label: "Statement issue",
              onTap: () => AppRoute.passbook.go(context),
            ),
            const SizedBox(height: IndoPaySpacing.sm),
            _SupportTile(
              icon: FintechIconGlyph.transfer,
              label: "Bank transfer",
              onTap: () => AppRoute.transfer.go(context),
            ),
            const SizedBox(height: IndoPaySpacing.sm),
            _SupportTile(
              icon: FintechIconGlyph.offers,
              label: "Merchant support",
              onTap: () => AppRoute.merchant.go(context),
            ),
            const SizedBox(height: IndoPaySpacing.sm),
            _SupportTile(
              icon: FintechIconGlyph.shield,
              label: "Security help",
              onTap: () => AppRoute.security.go(context),
            ),
            const SizedBox(height: IndoPaySpacing.sm),
            _SupportTile(
              icon: FintechIconGlyph.tickets,
              label: "Travel",
              onTap: () => AppRoute.tickets.go(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  const _SupportTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final FintechIconGlyph icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FintechTapScale(
      onTap: onTap,
      child: GlassCard(
        child: Row(
          children: [
            FintechIcon(icon),
            const SizedBox(width: IndoPaySpacing.md),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.titleMedium),
            ),
            const FintechIcon(FintechIconGlyph.chevronRight),
          ],
        ),
      ),
    );
  }
}
