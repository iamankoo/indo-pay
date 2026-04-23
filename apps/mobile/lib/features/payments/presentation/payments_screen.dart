import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "../../../design_system/indo_pay_colors.dart";
import "../../../design_system/indo_pay_tokens.dart";
import "../../../design_system/indo_pay_typography.dart";
import "../../../design_system/widgets/fintech_icon.dart";
import "../../../design_system/widgets/glass_card.dart";
import "../../../design_system/widgets/indo_pay_backdrop.dart";
import "../data/payments_repository.dart";
import "../domain/payment_models.dart";

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  final TextEditingController _amountController =
      TextEditingController(text: "499");
  final DateFormat _dateFormat = DateFormat("dd MMM");
  String _category = "QR_PAYMENT";
  PaymentPreview? _preview;
  PaymentReceipt? _receipt;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refreshPreview();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _refreshPreview() async {
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      return;
    }

    try {
      final preview = await ref.read(paymentsRepositoryProvider).previewSplit(amount);
      if (mounted) {
        setState(() {
          _preview = preview;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    }
  }

  Future<void> _submitPayment() async {
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final receipt = await ref.read(paymentsRepositoryProvider).pay(
            amount: amount,
            category: _category,
            idempotencyKey: "mobile-pay-${DateTime.now().microsecondsSinceEpoch}-$amount",
          );
      HapticFeedback.mediumImpact();
      if (mounted) {
        setState(() {
          _loading = false;
          _receipt = receipt;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = error.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment failed: $error")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = int.tryParse(_amountController.text) ?? 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Payments"),
        backgroundColor: Colors.transparent,
      ),
      body: IndoPayBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(IndoPaySpacing.lg),
          children: [
            Wrap(
              spacing: IndoPaySpacing.xs + 2,
              runSpacing: IndoPaySpacing.xs + 2,
              children: [
                for (final option in ["QR_PAYMENT", "RECHARGE", "BILL_PAY"])
                  ChoiceChip(
                    label: Text(option.replaceAll("_", " ")),
                    selected: _category == option,
                    onSelected: (_) {
                      setState(() => _category = option);
                      _refreshPreview();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Amount", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: IndoPaySpacing.sm),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: IndoPayTypography.mono(
                      size: 24,
                      weight: FontWeight.w700,
                    ),
                    onChanged: (_) => _refreshPreview(),
                    decoration: const InputDecoration(
                      prefixText: "INR ",
                      hintText: "Enter amount",
                    ),
                  ),
                  const SizedBox(height: IndoPaySpacing.md + 2),
                  if (_preview != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Split preview",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: IndoPaySpacing.xs),
                        Text(
                          "Wallet INR ${_preview!.walletUse} | Bank INR ${_preview!.bankAmount}",
                          style: IndoPayTypography.mono(weight: FontWeight.w600),
                        ),
                      ],
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: IndoPaySpacing.sm),
                    Text(
                      _error!,
                      style: const TextStyle(color: IndoPayColors.dangerForeground),
                    ),
                  ],
                  const SizedBox(height: IndoPaySpacing.md + 2),
                  FilledButton.icon(
                    onPressed: _loading ? null : _submitPayment,
                    icon: const FintechIcon(
                      FintechIconGlyph.scan,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text(_loading ? "Processing..." : "Pay INR $amount"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: IndoPaySpacing.md + 2),
            if (_receipt != null)
              AnimatedScale(
                scale: 1,
                duration: IndoPayMotion.hero,
                curve: Curves.easeOutBack,
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: IndoPayColors.successSoft,
                            child: FintechIcon(
                              FintechIconGlyph.success,
                              color: IndoPayColors.success,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: IndoPaySpacing.sm),
                          Text(
                            "Transaction success",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: IndoPaySpacing.md),
                      Text(
                        "Transaction ID: ${_receipt!.transactionId}",
                        style: IndoPayTypography.mono(size: 12, weight: FontWeight.w600),
                      ),
                      Text(
                        "Bank debit: INR ${_receipt!.bankAmount}",
                        style: IndoPayTypography.mono(),
                      ),
                      Text(
                        "Wallet debit: INR ${_receipt!.walletAmount}",
                        style: IndoPayTypography.mono(),
                      ),
                      if (_receipt!.cashbackAmount != null) ...[
                        const SizedBox(height: IndoPaySpacing.sm),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(IndoPaySpacing.sm + 2),
                          decoration: BoxDecoration(
                            color: IndoPayColors.accentSoft,
                            borderRadius: BorderRadius.circular(IndoPayRadii.md),
                          ),
                          child: Text(
                            _receipt!.cashbackExpiresAt == null
                                ? "Reward earned: INR ${_receipt!.cashbackAmount}"
                                : "Reward earned: INR ${_receipt!.cashbackAmount} until ${_dateFormat.format(_receipt!.cashbackExpiresAt!)}",
                            style: IndoPayTypography.mono(weight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
