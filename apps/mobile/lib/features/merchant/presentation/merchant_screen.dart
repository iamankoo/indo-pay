import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../design_system/indo_pay_colors.dart";
import "../../../design_system/indo_pay_typography.dart";
import "../../../design_system/widgets/fintech_icon.dart";
import "../../../design_system/widgets/glass_card.dart";
import "../../../design_system/widgets/indo_pay_backdrop.dart";
import "../data/merchant_repository.dart";

class MerchantScreen extends ConsumerStatefulWidget {
  const MerchantScreen({super.key});

  @override
  ConsumerState<MerchantScreen> createState() => _MerchantScreenState();
}

class _MerchantScreenState extends ConsumerState<MerchantScreen> {
  Map<String, dynamic>? _link;
  Map<String, dynamic>? _qr;

  Future<void> _createLink() async {
    final payload = await ref.read(merchantRepositoryProvider).createPaymentLink(299);
    setState(() => _link = payload);
  }

  Future<void> _createQr() async {
    final payload = await ref.read(merchantRepositoryProvider).issueDynamicQr(299);
    setState(() => _qr = payload);
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(merchantDashboardProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Merchant"),
        backgroundColor: Colors.transparent,
      ),
      body: IndoPayBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            dashboard.when(
              data: (data) => Column(
                children: [
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.businessName, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 6),
                        Text("${data.city} | ${data.kycStatus}"),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: _createQr,
                                child: const Text("Dynamic QR"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: _createLink,
                                child: const Text("Payment link"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_qr != null)
                    GlassCard(
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0x140B4DFF),
                            child: FintechIcon(
                              FintechIconGlyph.scan,
                              color: IndoPayColors.accent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "QR ready for INR ${_qr!["amount"]}",
                              style: IndoPayTypography.mono(weight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_link != null) ...[
                    const SizedBox(height: 16),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Color(0x140B4DFF),
                                child: FintechIcon(
                                  FintechIconGlyph.transfer,
                                  color: IndoPayColors.accent,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text("Share link", style: Theme.of(context).textTheme.titleMedium),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _link!["shareUrl"]?.toString() ?? "",
                            style: IndoPayTypography.mono(size: 12, weight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Daily settlements", style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        for (final item in data.settlements)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.businessDay),
                            subtitle: Text("${item.orders} orders"),
                            trailing: Text(
                              "INR ${item.netSettlement}",
                              style: IndoPayTypography.mono(
                                size: 12,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text(error.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
