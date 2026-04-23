import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../../../../core/app_routes.dart";
import "../../../../design_system/indo_pay_colors.dart";
import "../../../../design_system/indo_pay_tokens.dart";
import "../../../../design_system/indo_pay_typography.dart";
import "../../../../design_system/widgets/fintech_icon.dart";
import "../../../../design_system/widgets/fintech_tap_scale.dart";
import "../../../../design_system/widgets/glass_card.dart";
import "../../../../design_system/widgets/indo_pay_backdrop.dart";
import "../../data/home_repository.dart";

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({
    super.key,
    required this.identity,
  });

  final HomeIdentity identity;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.84;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: width,
      backgroundColor: Colors.transparent,
      child: IndoPayBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(IndoPaySpacing.page),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(identity.avatarUrl),
                        ),
                        const SizedBox(width: IndoPaySpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                identity.fullName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: IndoPaySpacing.xs),
                              Text(
                                identity.upiId,
                                style: IndoPayTypography.mono(
                                  color: isDark ? Colors.white : IndoPayColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: IndoPayColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            identity.kycStatus,
                            style: IndoPayTypography.mono(
                              size: 11,
                              color: IndoPayColors.success,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: IndoPaySpacing.md),
                    Text(
                      identity.phoneNumber,
                      style: IndoPayTypography.mono(
                        color: isDark ? Colors.white70 : IndoPayColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: IndoPaySpacing.md),
                    Wrap(
                      spacing: IndoPaySpacing.sm,
                      runSpacing: IndoPaySpacing.sm,
                      children: [
                        _ProfileChip(
                          label: "${identity.linkedBankAccounts} bank",
                        ),
                        _ProfileChip(
                          label: "${identity.savedBeneficiaries} saved",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: IndoPaySpacing.xl),
              const _SectionTitle("Account"),
              const SizedBox(height: IndoPaySpacing.sm),
              _DrawerAction(
                label: "Wallet",
                icon: FintechIconGlyph.wallet,
                onTap: () => _openRoute(context, AppRoute.wallet),
              ),
              const SizedBox(height: IndoPaySpacing.sm),
              _DrawerAction(
                label: "Passbook",
                icon: FintechIconGlyph.passbook,
                onTap: () => _openRoute(context, AppRoute.passbook),
              ),
              const SizedBox(height: IndoPaySpacing.sm),
              _DrawerAction(
                label: "Linked accounts",
                icon: FintechIconGlyph.transfer,
                meta: "${identity.linkedBankAccounts}",
                onTap: () => _openRoute(context, AppRoute.wallet),
              ),
              const SizedBox(height: IndoPaySpacing.sm),
              _DrawerAction(
                label: "Saved beneficiaries",
                icon: FintechIconGlyph.send,
                meta: "${identity.savedBeneficiaries}",
                onTap: () => _openRoute(context, AppRoute.transfer),
              ),
              const SizedBox(height: IndoPaySpacing.xl),
              const _SectionTitle("Controls"),
              const SizedBox(height: IndoPaySpacing.sm),
              _DrawerAction(
                label: "Security",
                icon: FintechIconGlyph.shield,
                onTap: () => _openRoute(context, AppRoute.security),
              ),
              const SizedBox(height: IndoPaySpacing.sm),
              _DrawerAction(
                label: "Settings",
                icon: FintechIconGlyph.settings,
                onTap: () => _openRoute(context, AppRoute.settings),
              ),
              const SizedBox(height: IndoPaySpacing.sm),
              _DrawerAction(
                label: "Statements",
                icon: FintechIconGlyph.passbook,
                onTap: () => _openRoute(context, AppRoute.passbook),
              ),
              const SizedBox(height: IndoPaySpacing.sm),
              _DrawerAction(
                label: "Support",
                icon: FintechIconGlyph.support,
                onTap: () => _openRoute(context, AppRoute.support),
              ),
              const SizedBox(height: IndoPaySpacing.xl),
              _DrawerAction(
                label: "Logout",
                icon: FintechIconGlyph.logout,
                destructive: true,
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openRoute(BuildContext context, AppRoute route) {
    final router = GoRouter.of(context);
    context.pop();
    Future<void>.microtask(() => router.go(route.path));
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Logout", style: Theme.of(dialogContext).textTheme.titleLarge),
                    const SizedBox(height: IndoPaySpacing.sm),
                    Text(
                      "End this demo session?",
                      style: Theme.of(dialogContext).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: IndoPaySpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: IndoPaySpacing.sm),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: const Text("Logout"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;

    if (!shouldLogout || !context.mounted) {
      return;
    }

    final router = GoRouter.of(context);
    context.pop();
    Future<void>.microtask(() => router.go(AppRoute.splash.path));
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _DrawerAction extends StatelessWidget {
  const _DrawerAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.meta,
    this.destructive = false,
  });

  final String label;
  final FintechIconGlyph icon;
  final VoidCallback onTap;
  final String? meta;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final actionColor = destructive ? IndoPayColors.danger : null;

    return FintechTapScale(
      onTap: onTap,
      child: GlassCard(
        child: Row(
          children: [
            FintechIcon(
              icon,
              color: actionColor ?? Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: IndoPaySpacing.md),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: actionColor,
                    ),
              ),
            ),
            if (meta != null) ...[
              Text(meta!, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(width: IndoPaySpacing.sm),
            ],
            FintechIcon(
              FintechIconGlyph.chevronRight,
              color: actionColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: IndoPayColors.textPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: IndoPayTypography.mono(size: 12),
      ),
    );
  }
}
