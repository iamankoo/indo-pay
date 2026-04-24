import "package:flutter/material.dart";

import "../../../core/app_routes.dart";
import "../../../design_system/indo_pay_tokens.dart";
import "../../../design_system/widgets/fintech_action_card.dart";
import "../../../design_system/widgets/fintech_icon.dart";
import "../../../design_system/widgets/fintech_tap_scale.dart";
import "../../../design_system/widgets/glass_card.dart";
import "../../../design_system/widgets/indo_pay_backdrop.dart";

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Tickets")),
      body: IndoPayBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(IndoPaySpacing.page),
          children: [
            Text("Book", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: IndoPaySpacing.md),
            SizedBox(
              height: 152,
              child: Row(
                children: [
                  Expanded(
                    child: FintechActionCard(
                      label: "Train",
                      icon: FintechIconGlyph.tickets,
                      onTap: () => AppRoute.search.push(context),
                    ),
                  ),
                  const SizedBox(width: IndoPaySpacing.md),
                  Expanded(
                    child: FintechActionCard(
                      label: "Bus",
                      icon: FintechIconGlyph.tickets,
                      onTap: () => AppRoute.search.push(context),
                    ),
                  ),
                  const SizedBox(width: IndoPaySpacing.md),
                  Expanded(
                    child: FintechActionCard(
                      label: "Travel",
                      icon: FintechIconGlyph.tickets,
                      onTap: () => AppRoute.search.push(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: IndoPaySpacing.xl),
            Text("Manage", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: IndoPaySpacing.md),
            _TicketActionTile(
              label: "Travel offers",
              icon: FintechIconGlyph.offers,
              onTap: () => AppRoute.offers.push(context),
            ),
            const SizedBox(height: IndoPaySpacing.sm),
            _TicketActionTile(
              label: "Support",
              icon: FintechIconGlyph.support,
              onTap: () => AppRoute.support.push(context),
            ),
            const SizedBox(height: IndoPaySpacing.xl),
            Text("Recent", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: IndoPaySpacing.md),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("No trips", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    "Bookings will appear here.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketActionTile extends StatelessWidget {
  const _TicketActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final FintechIconGlyph icon;
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
