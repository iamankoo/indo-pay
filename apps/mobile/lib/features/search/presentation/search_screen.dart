import "package:flutter/material.dart";

import "../../../core/app_routes.dart";
import "../../../design_system/indo_pay_tokens.dart";
import "../../../design_system/indo_pay_typography.dart";
import "../../../design_system/widgets/fintech_icon.dart";
import "../../../design_system/widgets/fintech_tap_scale.dart";
import "../../../design_system/widgets/glass_card.dart";
import "../../../design_system/widgets/indo_pay_backdrop.dart";

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  static const List<_SearchTarget> _targets = [
    _SearchTarget(
      label: "ananya@indopay",
      meta: "UPI ID",
      icon: FintechIconGlyph.send,
      route: AppRoute.payments,
      monoLabel: true,
    ),
    _SearchTarget(
      label: "9876543210",
      meta: "Phone number",
      icon: FintechIconGlyph.send,
      route: AppRoute.payments,
      monoLabel: true,
    ),
    _SearchTarget(
      label: "Imphal Campus Cafe",
      meta: "Merchant",
      icon: FintechIconGlyph.offers,
      route: AppRoute.merchant,
    ),
    _SearchTarget(
      label: "Saved beneficiary",
      meta: "Bank transfer",
      icon: FintechIconGlyph.transfer,
      route: AppRoute.transfer,
    ),
    _SearchTarget(
      label: "Passbook",
      meta: "Statements",
      icon: FintechIconGlyph.passbook,
      route: AppRoute.passbook,
    ),
    _SearchTarget(
      label: "Tickets",
      meta: "Travel",
      icon: FintechIconGlyph.tickets,
      route: AppRoute.tickets,
    ),
    _SearchTarget(
      label: "Cashback",
      meta: "Reward center",
      icon: FintechIconGlyph.offers,
      route: AppRoute.offers,
    ),
    _SearchTarget(
      label: "Support",
      meta: "Help",
      icon: FintechIconGlyph.support,
      route: AppRoute.support,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim().toLowerCase();
    final results = _targets.where((target) {
      if (query.isEmpty) {
        return true;
      }

      return target.label.toLowerCase().contains(query) ||
          target.meta.toLowerCase().contains(query);
    }).toList(growable: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Search")),
      body: IndoPayBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(IndoPaySpacing.page),
          children: [
            GlassCard(
              child: Row(
                children: [
                  const FintechIcon(FintechIconGlyph.search),
                  const SizedBox(width: IndoPaySpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: "Search",
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: IndoPaySpacing.xl),
            Text(
              query.isEmpty ? "Quick access" : "Results",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: IndoPaySpacing.md),
            if (results.isEmpty)
              GlassCard(
                child: Text(
                  "No results",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              ...results.map(
                (target) => Padding(
                  padding: const EdgeInsets.only(bottom: IndoPaySpacing.sm),
                  child: _SearchResultTile(target: target),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.target});

  final _SearchTarget target;

  @override
  Widget build(BuildContext context) {
    return FintechTapScale(
      onTap: () => target.route.push(context),
      child: GlassCard(
        child: Row(
          children: [
            FintechIcon(target.icon),
            const SizedBox(width: IndoPaySpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    target.label,
                    style: target.monoLabel
                        ? IndoPayTypography.mono(size: 14, weight: FontWeight.w700)
                        : Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    target.meta,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const FintechIcon(FintechIconGlyph.chevronRight),
          ],
        ),
      ),
    );
  }
}

class _SearchTarget {
  const _SearchTarget({
    required this.label,
    required this.meta,
    required this.icon,
    required this.route,
    this.monoLabel = false,
  });

  final String label;
  final String meta;
  final FintechIconGlyph icon;
  final AppRoute route;
  final bool monoLabel;
}
