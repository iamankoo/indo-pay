import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/app_routes.dart";
import "../../../design_system/indo_pay_colors.dart";
import "../../../design_system/indo_pay_tokens.dart";
import "../../../design_system/widgets/fintech_icon.dart";
import "../../../design_system/widgets/fintech_tap_scale.dart";
import "../../../design_system/widgets/glass_card.dart";
import "../../../design_system/widgets/scan_hero_orb.dart";
import "../bottom_nav_notifier.dart";

class IndoPayShell extends ConsumerWidget {
  const IndoPayShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = shellTabForLocation(location);
    final selectedTab = ref.watch(bottomNavProvider);

    if (selectedTab != activeTab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(bottomNavProvider.notifier).syncWithRoute(location);
      });
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: IndoPaySpacing.navBottom),
              child: child,
            ),
          ),
          Positioned(
            left: IndoPaySpacing.page,
            right: IndoPaySpacing.page,
            bottom: IndoPaySpacing.lg,
            child: _FloatingBottomNavigation(activeTab: activeTab),
          ),
        ],
      ),
    );
  }
}

class _FloatingBottomNavigation extends ConsumerWidget {
  const _FloatingBottomNavigation({
    required this.activeTab,
  });

  final AppShellTab? activeTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 108,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          GlassCard(
            radius: IndoPayRadii.xxl,
            padding: const EdgeInsets.symmetric(
              horizontal: IndoPaySpacing.lg,
              vertical: IndoPaySpacing.md,
            ),
            blur: 22,
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    tab: AppShellTab.tickets,
                    glyph: FintechIconGlyph.tickets,
                    selected: activeTab == AppShellTab.tickets,
                  ),
                ),
                const SizedBox(width: 96),
                Expanded(
                  child: _NavItem(
                    tab: AppShellTab.offers,
                    glyph: FintechIconGlyph.offers,
                    selected: activeTab == AppShellTab.offers,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -28,
            child: FintechTapScale(
              onTap: () {
                ref.read(bottomNavProvider.notifier).select(AppShellTab.scan);
                AppRoute.scan.go(context);
              },
              scale: 0.96,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  const ScanHeroOrb(diameter: 96),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? IndoPayColors.cardDark.withValues(alpha: 0.92)
                            : Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: IndoPayColors.shellBorder.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        "Scan",
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: isDark
                                  ? Colors.white
                                  : IndoPayColors.textPrimary,
                            ),
                      ),
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

class _NavItem extends ConsumerWidget {
  const _NavItem({
    required this.tab,
    required this.glyph,
    required this.selected,
  });

  final AppShellTab tab;
  final FintechIconGlyph glyph;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? IndoPayColors.accent
        : (isDark ? Colors.white70 : IndoPayColors.textSecondary);

    return FintechTapScale(
      onTap: () {
        ref.read(bottomNavProvider.notifier).select(tab);
        tab.route.go(context);
      },
      child: SizedBox(
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FintechIcon(glyph, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              tab.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
