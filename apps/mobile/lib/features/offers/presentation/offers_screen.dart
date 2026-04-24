import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "../../../core/app_routes.dart";
import "../../../design_system/indo_pay_colors.dart";
import "../../../design_system/indo_pay_tokens.dart";
import "../../../design_system/indo_pay_typography.dart";
import "../../../design_system/widgets/fintech_icon.dart";
import "../../../design_system/widgets/fintech_tap_scale.dart";
import "../../../design_system/widgets/fintech_shimmer.dart";
import "../../../design_system/widgets/glass_card.dart";
import "../../../design_system/widgets/indo_pay_backdrop.dart";
import "../../wallet/data/wallet_repository.dart";
import "../../wallet/domain/wallet_summary.dart";

class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletSummaryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Cashback & Offers")),
      body: IndoPayBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(IndoPaySpacing.page),
          children: [
            wallet.when(
              data: (data) => Column(
                children: [
                  _RewardSummary(data: data),
                  const SizedBox(height: IndoPaySpacing.xl),
                  _ExpiringRewards(data: data),
                  const SizedBox(height: IndoPaySpacing.xl),
                  GlassCard(
                    child: Column(
                      children: [
                        _OfferActionRow(
                          label: "Cashback history",
                          icon: FintechIconGlyph.passbook,
                          onTap: () => AppRoute.passbook.push(context),
                        ),
                        const SizedBox(height: IndoPaySpacing.sm),
                        _OfferActionRow(
                          label: "Wallet",
                          icon: FintechIconGlyph.wallet,
                          onTap: () => AppRoute.wallet.push(context),
                        ),
                        const SizedBox(height: IndoPaySpacing.sm),
                        _OfferActionRow(
                          label: "Travel offers",
                          icon: FintechIconGlyph.tickets,
                          onTap: () => AppRoute.tickets.push(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              loading: () => const Column(
                children: [
                  FintechShimmer(height: 168, radius: 28),
                  SizedBox(height: IndoPaySpacing.xl),
                  FintechShimmer(height: 180, radius: 28),
                ],
              ),
              error: (error, _) => GlassCard(
                child: Text(
                  "Refresh required",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardSummary extends StatelessWidget {
  const _RewardSummary({required this.data});

  final WalletSummary data;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Rewards", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: IndoPaySpacing.md),
          Text(
            "INR ${data.promoWalletBalance}",
            style: IndoPayTypography.mono(
              size: 30,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: IndoPaySpacing.md),
          Wrap(
            spacing: IndoPaySpacing.sm,
            runSpacing: IndoPaySpacing.sm,
            children: [
              _MetricPill(label: "Redeemed", value: data.monthlyRedeemed),
              _MetricPill(label: "Expiring", value: data.expiringIn7Days),
              _MetricPill(label: "Expired", value: data.monthlyExpired),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpiringRewards extends StatelessWidget {
  const _ExpiringRewards({required this.data});

  final WalletSummary data;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat("dd MMM");
    final items = data.upcomingExpiries.take(3).toList(growable: false);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Expiring", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: IndoPaySpacing.md),
          if (items.isEmpty)
            Text(
              "No expiring rewards",
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: IndoPaySpacing.sm),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: IndoPayColors.accentSoft,
                      child: FintechIcon(
                        FintechIconGlyph.clock,
                        color: IndoPayColors.accent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: IndoPaySpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.expiresAt == null
                                ? "Open credit"
                                : formatter.format(item.expiresAt!),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "INR ${item.amount}",
                      style: IndoPayTypography.mono(
                        size: 12,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OfferActionRow extends StatelessWidget {
  const _OfferActionRow({
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
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: IndoPayColors.textPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(IndoPayRadii.pill),
      ),
      child: Text(
        "$label INR $value",
        style: IndoPayTypography.mono(size: 12),
      ),
    );
  }
}
