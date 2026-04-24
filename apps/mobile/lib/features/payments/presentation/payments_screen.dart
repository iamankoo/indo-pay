import "package:dio/dio.dart";
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
import "../domain/payment_entry_flow.dart";
import "../data/payments_repository.dart";
import "../domain/payment_models.dart";

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({
    super.key,
    this.flow = PaymentEntryFlow.standard,
    this.initialReference,
  });

  final PaymentEntryFlow flow;
  final String? initialReference;

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _recipientController;
  final DateFormat _dateFormat = DateFormat("dd MMM");
  late String _category;
  PaymentPreview? _preview;
  PaymentReceipt? _receipt;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: "499");
    _recipientController = TextEditingController(
      text: widget.initialReference ?? "",
    );
    _category = widget.flow.initialCategory;
    _refreshPreview();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  Future<void> _refreshPreview() async {
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      if (mounted) {
        setState(() {
          _preview = null;
          _error = null;
        });
      }
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
        setState(() {
          _preview = null;
          // Graceful degradation: A failure in the preview API should not block
          // the user from proceeding with the actual payment flow.
          // We intentionally do NOT set _error here to avoid blocking the UI.
        });
      }
    }
  }

  Future<void> _submitPayment() async {
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      setState(() => _error = "Enter a valid amount.");
      return;
    }

    if (widget.flow.requiresRecipient &&
        _recipientController.text.trim().isEmpty) {
      setState(() => _error = "Enter mobile number or UPI ID.");
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
            referenceLabel: _buildReferenceLabel(),
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
        final message = _formatApiError(
          error,
          fallback: "Payment request failed",
        );
        setState(() {
          _loading = false;
          _error = message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  String? _buildReferenceLabel() {
    final reference = _recipientController.text.trim();
    if (reference.isNotEmpty) {
      return reference;
    }
    return widget.initialReference;
  }

  String _formatApiError(
    Object error, {
    required String fallback,
  }) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data["message"]?.toString();
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }

      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        return "$fallback ($statusCode)";
      }

      if (error.message != null && error.message!.isNotEmpty) {
        return error.message!;
      }
    }

    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final amount = int.tryParse(_amountController.text) ?? 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.flow.title),
        backgroundColor: Colors.transparent,
      ),
      body: IndoPayBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(IndoPaySpacing.lg),
          children: [
            if (widget.flow.showsCategoryChooser) ...[
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
            ],
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.flow.requiresRecipient) ...[
                    Text(
                      widget.flow.recipientLabel,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: IndoPaySpacing.sm),
                    TextField(
                      controller: _recipientController,
                      style: IndoPayTypography.mono(
                        size: 16,
                        weight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        hintText: "name@upi or mobile number",
                      ),
                    ),
                    const SizedBox(height: IndoPaySpacing.md + 2),
                  ],
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
                    label: Text(
                      _loading
                          ? "Processing..."
                          : widget.flow.submitLabel(amount),
                    ),
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
