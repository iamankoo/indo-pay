import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../../design_system/indo_pay_colors.dart";
import "../../../../design_system/indo_pay_tokens.dart";
import "../../../../design_system/widgets/fintech_tap_scale.dart";
import "../../data/home_repository.dart";

class AccountCreationSheet extends ConsumerStatefulWidget {
  const AccountCreationSheet({super.key});

  @override
  ConsumerState<AccountCreationSheet> createState() => _AccountCreationSheetState();
}

class _AccountCreationSheetState extends ConsumerState<AccountCreationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(homeIdentityProvider.notifier).setUser(
            _fullNameCtrl.text.trim(),
            _mobileCtrl.text.trim(),
            _emailCtrl.text.trim(),
          );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: IndoPaySpacing.page,
        right: IndoPaySpacing.page,
        top: IndoPaySpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Create your account",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: IndoPaySpacing.md),
            TextFormField(
              controller: _fullNameCtrl,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? "Enter full name" : null,
            ),
            const SizedBox(height: IndoPaySpacing.md),
            TextFormField(
              controller: _mobileCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Mobile Number",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.length < 10 ? "Enter valid mobile" : null,
            ),
            const SizedBox(height: IndoPaySpacing.md),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || !v.contains("@") ? "Enter valid email" : null,
            ),
            const SizedBox(height: IndoPaySpacing.xl),
            FintechTapScale(
              onTap: _submit,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: IndoPayColors.primary,
                  borderRadius: BorderRadius.circular(IndoPayRadii.md),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: IndoPaySpacing.xl),
          ],
        ),
      ),
    );
  }
}
