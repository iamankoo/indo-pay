import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../design_system/indo_pay_colors.dart";
import "../../../design_system/indo_pay_tokens.dart";
import "../../../design_system/indo_pay_typography.dart";
import "../../../design_system/widgets/fintech_icon.dart";
import "../../../design_system/widgets/fintech_shimmer.dart";
import "../../../design_system/widgets/glass_card.dart";
import "../../../design_system/widgets/indo_pay_backdrop.dart";
import "../data/wallet_repository.dart";

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletSummaryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Wallet"),
        backgroundColor: Colors.transparent,
      ),
      body: IndoPayBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(IndoPaySpacing.lg),
          children: [
            wallet.when(
              data: (data) => Column(
                children: [
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Wallet", style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: IndoPaySpacing.sm),
                        Text(
                          "INR ${data.promoWalletBalance}",
                          style: IndoPayTypography.mono(
                            size: 28,
                            weight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: IndoPaySpacing.md + 2),
                        Wrap(
                          spacing: IndoPaySpacing.xs + 2,
                          runSpacing: IndoPaySpacing.xs + 2,
                          children: data.rewardExpiryChips
                              .map(
                                (chip) => Chip(
                                  label: Text(
                                    "${chip.label} | INR ${chip.amount}",
                                    style: IndoPayTypography.mono(
                                      size: 12,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Usage", style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: IndoPaySpacing.sm),
                        LinearProgressIndicator(
                          value: data.redemptionUsageMeter.availableBalance == 0
                              ? 0
                              : (data.redemptionUsageMeter.consumedThisMonth /
                                      data.redemptionUsageMeter.availableBalance)
                                  .clamp(0, 1)
                                  .toDouble(),
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(IndoPayRadii.pill),
                        ),
                        const SizedBox(height: IndoPaySpacing.sm + 2),
                        Text(
                          "Redeemed INR ${data.monthlyRedeemed} | Expired INR ${data.monthlyExpired}",
                          style: IndoPayTypography.mono(
                            size: 13,
                            weight: FontWeight.w600,
                            color: IndoPayColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Expiry", style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: IndoPaySpacing.md),
                        for (final item in data.upcomingExpiries)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: IndoPayColors.warningSoft,
                              child: FintechIcon(
                                FintechIconGlyph.clock,
                                color: IndoPayColors.saffron,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              "INR ${item.amount}",
                              style: IndoPayTypography.mono(
                                weight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(item.description ?? item.label),
                            trailing: Text(
                              item.expiresAt == null
                                  ? "Open"
                                  : "${item.expiresAt!.day}/${item.expiresAt!.month}",
                              style: IndoPayTypography.mono(
                                size: 12,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              loading: () => const Column(
                children: [
                  FintechShimmer(height: 180),
                  SizedBox(height: IndoPaySpacing.md + 2),
                  FintechShimmer(height: 140),
                  SizedBox(height: IndoPaySpacing.md + 2),
                  FintechShimmer(height: 220),
                ],
              ),
              error: (error, _) => Text(error.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
