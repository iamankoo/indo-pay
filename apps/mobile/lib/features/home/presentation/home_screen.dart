import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "../../../core/app_routes.dart";
import "../../../design_system/indo_pay_colors.dart";
import "../../../design_system/indo_pay_tokens.dart";
import "../../../design_system/indo_pay_typography.dart";
import "../../../design_system/widgets/fintech_action_card.dart";
import "../../../design_system/widgets/fintech_icon.dart";
import "../../../design_system/widgets/fintech_shimmer.dart";
import "../../../design_system/widgets/fintech_tap_scale.dart";
import "../../../design_system/widgets/glass_card.dart";
import "../../../design_system/widgets/indo_pay_backdrop.dart";
import "../../../design_system/widgets/notification_dot.dart";
import "../../../design_system/widgets/scan_hero_orb.dart";
import "../../../design_system/widgets/wallet_balance_chip.dart";
import "../data/home_repository.dart";
import "../domain/home_dashboard.dart";
import "widgets/profile_drawer.dart";

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: IndoPayMotion.pulse,
  )..repeat(reverse: true);
  late final Animation<double> _pulseAnimation = Tween<double>(
    begin: 1,
    end: 1.04,
  ).animate(
    CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ),
  );

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(homeDashboardProvider);
    final identity = ref.watch(homeIdentityProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final bankLinkEnabled = ref.watch(bankLinkFeatureFlagProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      endDrawer: ProfileDrawer(identity: identity),
      body: IndoPayBackdrop(
        child: Stack(
          children: [
            SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(homeDashboardProvider);
                  await ref.read(homeDashboardProvider.future);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    IndoPaySpacing.page,
                    IndoPaySpacing.page,
                    IndoPaySpacing.page,
                    148,
                  ),
                  children: [
                    _HomeTopBar(
                      identity: identity,
                      unreadCount: unreadCount,
                      onProfileTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                      onSearchTap: () => AppRoute.search.go(context),
                    ),
                    const SizedBox(height: 124),
                    const _SectionLabel("Payments"),
                    const SizedBox(height: IndoPaySpacing.md),
                    SizedBox(
                      height: 300,
                      child: GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: IndoPaySpacing.md,
                        mainAxisSpacing: IndoPaySpacing.md,
                        childAspectRatio: 1.06,
                        children: [
                          FintechActionCard(
                            label: "Scan QR",
                            icon: FintechIconGlyph.scan,
                            onTap: () => AppRoute.scan.go(context),
                          ),
                          FintechActionCard(
                            label: "Bank Transfer",
                            icon: FintechIconGlyph.transfer,
                            onTap: () => AppRoute.transfer.go(context),
                          ),
                          FintechActionCard(
                            label: "Passbook",
                            icon: FintechIconGlyph.passbook,
                            onTap: () => AppRoute.passbook.go(context),
                          ),
                          FintechActionCard(
                            label: "Mobile Recharge",
                            icon: FintechIconGlyph.recharge,
                            onTap: () => AppRoute.payments.go(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: IndoPaySpacing.xl),
                    const _SectionLabel("Money"),
                    const SizedBox(height: IndoPaySpacing.md),
                    dashboard.when(
                      data: (data) => Column(
                        children: [
                          _MoneyTile(
                            title: "Send by Number / UPI ID",
                            icon: FintechIconGlyph.send,
                            onTap: () => AppRoute.payments.go(context),
                            trailing: const FintechIcon(FintechIconGlyph.chevronRight),
                          ),
                          const SizedBox(height: IndoPaySpacing.md),
                          _WalletTile(
                            data: data,
                            bankLinkEnabled: bankLinkEnabled,
                            onTap: () => AppRoute.wallet.go(context),
                          ),
                        ],
                      ),
                      loading: () => const Column(
                        children: [
                          FintechShimmer(height: 112, radius: 28),
                          SizedBox(height: IndoPaySpacing.md),
                          FintechShimmer(height: 138, radius: 28),
                        ],
                      ),
                      error: (error, _) => _RetryBanner(
                        message: "Refresh required",
                        onTap: () => ref.invalidate(homeDashboardProvider),
                      ),
                    ),
                    const SizedBox(height: IndoPaySpacing.xl),
                    const _SectionLabel("Recent"),
                    const SizedBox(height: IndoPaySpacing.md),
                    dashboard.when(
                      data: (data) => _RecentActivity(items: data.passbookPreview),
                      loading: () => const FintechShimmer(height: 210, radius: 28),
                      error: (error, _) => _RetryBanner(
                        message: "Recent unavailable",
                        onTap: () => ref.invalidate(homeDashboardProvider),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 88,
              left: 0,
              right: 0,
              child: Center(
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: FintechTapScale(
                    onTap: () => AppRoute.scan.go(context),
                    scale: 0.96,
                    child: Hero(
                      tag: AppRoute.scan.heroTag,
                      child: const ScanHeroOrb(diameter: 132),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({
    required this.identity,
    required this.unreadCount,
    required this.onProfileTap,
    required this.onSearchTap,
  });

  final HomeIdentity identity;
  final int unreadCount;
  final VoidCallback onProfileTap;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FintechTapScale(
            onTap: onProfileTap,
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _Avatar(imageUrl: identity.avatarUrl),
                    Positioned(
                      right: -6,
                      top: -4,
                      child: NotificationDot(count: unreadCount),
                    ),
                  ],
                ),
                const SizedBox(width: IndoPaySpacing.md),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_greeting()}, ${identity.firstName}",
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        identity.upiId,
                        overflow: TextOverflow.ellipsis,
                        style: IndoPayTypography.mono(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: IndoPaySpacing.md),
        FintechTapScale(
          onTap: onSearchTap,
          child: GlassCard(
            radius: IndoPayRadii.lg,
            padding: const EdgeInsets.all(14),
            child: const FintechIcon(FintechIconGlyph.search),
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning";
    }
    if (hour < 17) {
      return "Good afternoon";
    }
    return "Good evening";
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        height: 54,
        width: 54,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              return child;
            }
            return const FintechShimmer(
              height: 54,
              width: 54,
              radius: 999,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: IndoPayColors.primary.withValues(alpha: 0.12),
              alignment: Alignment.center,
              child: Text(
                "A",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _MoneyTile extends StatelessWidget {
  const _MoneyTile({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.trailing,
  });

  final String title;
  final FintechIconGlyph icon;
  final VoidCallback onTap;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return FintechTapScale(
      onTap: onTap,
      child: GlassCard(
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: IndoPayColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(IndoPayRadii.md),
              ),
              child: Center(
                child: FintechIcon(icon),
              ),
            ),
            const SizedBox(width: IndoPaySpacing.md),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _WalletTile extends StatelessWidget {
  const _WalletTile({
    required this.data,
    required this.bankLinkEnabled,
    required this.onTap,
  });

  final HomeDashboard data;
  final bool bankLinkEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FintechTapScale(
      onTap: onTap,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: IndoPayColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(IndoPayRadii.md),
                  ),
                  child: const Center(
                    child: FintechIcon(FintechIconGlyph.wallet),
                  ),
                ),
                const SizedBox(width: IndoPaySpacing.md),
                Expanded(
                  child: Text(
                    "Indo Pay Wallet",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                WalletBalanceChip(amount: data.walletBalance),
              ],
            ),
            const SizedBox(height: IndoPaySpacing.md),
            Wrap(
              spacing: IndoPaySpacing.sm,
              runSpacing: IndoPaySpacing.sm,
              children: [
                _MonoChip(
                  label: "Cashback",
                  value: data.cashbackEarnedThisMonth,
                ),
                _MonoChip(
                  label: "Expiring",
                  value: data.expiringRewards,
                ),
                if (bankLinkEnabled)
                  const _TextChip(label: "Bank link"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.items});

  final List<HomeFeedItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return GlassCard(
        child: Text("No activity", style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    final formatter = DateFormat("dd MMM, hh:mm a");

    return GlassCard(
      child: Column(
        children: [
          for (int index = 0; index < items.length; index++) ...[
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: IndoPayColors.textPrimary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(IndoPayRadii.sm),
                  ),
                  child: Center(
                    child: FintechIcon(_iconFor(items[index].type)),
                  ),
                ),
                const SizedBox(width: IndoPaySpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _labelFor(items[index].type),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatter.format(items[index].createdAt),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Text(
                  "INR ${items[index].amount}",
                  style: IndoPayTypography.mono(
                    size: 13,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (index != items.length - 1) ...[
              const SizedBox(height: IndoPaySpacing.md),
              Divider(
                height: 1,
                color: IndoPayColors.shellBorder.withValues(alpha: 0.45),
              ),
              const SizedBox(height: IndoPaySpacing.md),
            ],
          ],
        ],
      ),
    );
  }

  FintechIconGlyph _iconFor(String type) {
    if (type.contains("RECHARGE")) {
      return FintechIconGlyph.recharge;
    }
    if (type.contains("TRANSFER")) {
      return FintechIconGlyph.transfer;
    }
    return FintechIconGlyph.scan;
  }

  String _labelFor(String type) {
    return type.replaceAll("_", " ");
  }
}

class _RetryBanner extends StatelessWidget {
  const _RetryBanner({
    required this.message,
    required this.onTap,
  });

  final String message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FintechTapScale(
      onTap: onTap,
      child: GlassCard(
        child: Row(
          children: [
            Expanded(
              child: Text(message, style: Theme.of(context).textTheme.titleMedium),
            ),
            const FintechIcon(FintechIconGlyph.chevronRight),
          ],
        ),
      ),
    );
  }
}

class _MonoChip extends StatelessWidget {
  const _MonoChip({
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

class _TextChip extends StatelessWidget {
  const _TextChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: IndoPayColors.textPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(IndoPayRadii.pill),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
