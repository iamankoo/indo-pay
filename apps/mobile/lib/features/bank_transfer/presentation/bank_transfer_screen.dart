import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../design_system/indo_pay_colors.dart";
import "../../../design_system/indo_pay_typography.dart";
import "../../../design_system/widgets/fintech_icon.dart";
import "../../../design_system/widgets/glass_card.dart";
import "../../../design_system/widgets/indo_pay_backdrop.dart";
import "../data/bank_transfer_repository.dart";
import "../domain/transfer_models.dart";

class BankTransferScreen extends ConsumerStatefulWidget {
  const BankTransferScreen({super.key});

  @override
  ConsumerState<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends ConsumerState<BankTransferScreen> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _confirmAccountController = TextEditingController();
  final TextEditingController _ifscController =
      TextEditingController(text: "HDFC0001234");
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController(text: "2500");
  String _rail = "SMART_QUICK";
  TransferPreview? _preview;
  TransferReceipt? _receipt;
  Map<String, dynamic>? _ifscMeta;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _accountController.dispose();
    _confirmAccountController.dispose();
    _ifscController.dispose();
    _nameController.dispose();
    _nicknameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _lookupName() async {
    final payload = await ref.read(bankTransferRepositoryProvider).fetchBeneficiaryName(
          accountNumber: _accountController.text,
          ifsc: _ifscController.text,
        );
    setState(() {
      _nameController.text = payload["beneficiaryName"]?.toString() ?? "";
      _nicknameController.text = payload["beneficiaryName"]?.toString().split(" ").first ?? "";
    });
  }

  Future<void> _validateIfsc() async {
    final payload = await ref.read(bankTransferRepositoryProvider).validateIfsc(
          _ifscController.text,
        );
    if (!mounted) {
      return;
    }

    setState(() => _ifscMeta = payload);
  }

  Future<void> _previewTransfer() async {
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await _validateIfsc();
      final preview = await ref.read(bankTransferRepositoryProvider).previewTransfer(
            amount: amount,
            rail: _rail,
          );
      if (mounted) {
        setState(() {
          _busy = false;
          _preview = preview;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.toString();
        });
      }
    }
  }

  Future<void> _submit() async {
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      return;
    }

    if (_accountController.text != _confirmAccountController.text) {
      setState(() => _error = "Account numbers do not match.");
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final receipt = await ref.read(bankTransferRepositoryProvider).submitTransfer(
            accountNumber: _accountController.text,
            ifsc: _ifscController.text,
            beneficiaryName: _nameController.text,
            nickname: _nicknameController.text,
            amount: amount,
            rail: _rail,
            idempotencyKey: "transfer-${DateTime.now().microsecondsSinceEpoch}-$amount",
          );
      if (mounted) {
        setState(() {
          _busy = false;
          _receipt = receipt;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final beneficiaries = ref.watch(recentBeneficiariesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Bank transfer"),
        backgroundColor: Colors.transparent,
      ),
      body: IndoPayBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            beneficiaries.when(
              data: (items) => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: items
                    .map(
                      (item) => ActionChip(
                        label: Text(item.nickname),
                        onPressed: () {
                          _nameController.text = item.beneficiaryName;
                          _nicknameController.text = item.nickname;
                          _ifscController.text = item.ifsc;
                        },
                      ),
                    )
                    .toList(),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  TextField(
                    controller: _accountController,
                    style: IndoPayTypography.mono(),
                    decoration: const InputDecoration(labelText: "Account number"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmAccountController,
                    style: IndoPayTypography.mono(),
                    decoration: const InputDecoration(labelText: "Re-enter account number"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ifscController,
                    style: IndoPayTypography.mono(),
                    decoration: const InputDecoration(labelText: "IFSC"),
                  ),
                  const SizedBox(height: 12),
                  if (_ifscMeta != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0x140B4DFF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        "${_ifscMeta!["bankName"] ?? "Bank"} | ${_ifscMeta!["supportsImmediateSettlement"] == true ? "Immediate settlement available" : "Scheduled settlement"}",
                      ),
                    ),
                  if (_ifscMeta != null) const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Beneficiary name"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(labelText: "Nickname"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: IndoPayTypography.mono(
                      size: 20,
                      weight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(labelText: "Amount"),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _rail,
                    items: const [
                      DropdownMenuItem(value: "SMART_QUICK", child: Text("Smart quick transfer")),
                      DropdownMenuItem(value: "IMPS", child: Text("IMPS")),
                      DropdownMenuItem(value: "NEFT", child: Text("NEFT")),
                      DropdownMenuItem(value: "RTGS", child: Text("RTGS")),
                    ],
                    onChanged: (value) => setState(() => _rail = value ?? "SMART_QUICK"),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(color: Color(0xFFE04F5F)),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: _busy ? null : _lookupName,
                          child: const Text("Fetch name"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: _busy ? null : _previewTransfer,
                          child: Text(_busy ? "Checking..." : "Preview"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: const Text("Transfer now"),
                  ),
                ],
              ),
            ),
            if (_preview != null) ...[
              const SizedBox(height: 16),
              GlassCard(
                child: Row(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Transfer ready", style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            "${_preview!.rail} | ${_preview!.eta}",
                            style: IndoPayTypography.mono(
                              size: 12,
                              weight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(_preview!.railReason),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_receipt != null) ...[
              const SizedBox(height: 16),
              GlassCard(
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0x141BA97C),
                      child: FintechIcon(
                        FintechIconGlyph.success,
                        color: IndoPayColors.success,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Transfer successful",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _receipt!.transactionId,
                            style: IndoPayTypography.mono(
                              size: 12,
                              weight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${_receipt!.rail} | ${_receipt!.eta}",
                            style: IndoPayTypography.mono(size: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
