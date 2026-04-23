import "package:flutter/material.dart";

import "../../../core/app_routes.dart";
import "../../../design_system/indo_pay_tokens.dart";
import "../../../design_system/widgets/fintech_icon.dart";
import "../../../design_system/widgets/fintech_tap_scale.dart";
import "../../../design_system/widgets/glass_card.dart";
import "../../../design_system/widgets/indo_pay_backdrop.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Settings")),
      body: IndoPayBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(IndoPaySpacing.page),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Preferences", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: IndoPaySpacing.md),
                  const _SettingRow(
                    icon: FintechIconGlyph.settings,
                    label: "Appearance",
                    value: "System",
                  ),
                  const SizedBox(height: IndoPaySpacing.sm),
                  const _SettingRow(
                    icon: FintechIconGlyph.bell,
                    label: "Notifications",
                    value: "Active",
                  ),
                  const SizedBox(height: IndoPaySpacing.sm),
                  _SettingRow(
                    icon: FintechIconGlyph.passbook,
                    label: "Statements",
                    value: "Export",
                    onTap: () => AppRoute.passbook.go(context),
                  ),
                  const SizedBox(height: IndoPaySpacing.sm),
                  _SettingRow(
                    icon: FintechIconGlyph.shield,
                    label: "Security",
                    value: "Open",
                    onTap: () => AppRoute.security.go(context),
                  ),
                  const SizedBox(height: IndoPaySpacing.sm),
                  _SettingRow(
                    icon: FintechIconGlyph.support,
                    label: "Support",
                    value: "Open",
                    onTap: () => AppRoute.support.go(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: IndoPaySpacing.xl),
            const GlassCard(
              child: _SettingRow(
                icon: FintechIconGlyph.settings,
                label: "App",
                value: "v0.2.0+2",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final FintechIconGlyph icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        FintechIcon(icon),
        const SizedBox(width: IndoPaySpacing.md),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );

    if (onTap == null) {
      return content;
    }

    return FintechTapScale(
      onTap: onTap!,
      child: content,
    );
  }
}
