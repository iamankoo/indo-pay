import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../features/bank_transfer/presentation/bank_transfer_screen.dart";
import "../../features/home/presentation/home_screen.dart";
import "../../features/merchant/presentation/merchant_screen.dart";
import "../../features/offers/presentation/offers_screen.dart";
import "../../features/passbook/presentation/passbook_screen.dart";
import "../../features/payments/presentation/payments_screen.dart";
import "../../features/scan/presentation/scan_qr_screen.dart";
import "../../features/search/presentation/search_screen.dart";
import "../../features/security/presentation/security_screen.dart";
import "../../features/shell/presentation/indo_pay_shell.dart";
import "../../features/splash/presentation/splash_screen.dart";
import "../../features/settings/presentation/settings_screen.dart";
import "../../features/support/presentation/support_screen.dart";
import "../../features/tickets/presentation/tickets_screen.dart";
import "../../features/wallet/presentation/wallet_screen.dart";
import "../app_routes.dart";

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.splash.path,
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.routeName,
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const SplashScreen(),
          duration: const Duration(milliseconds: 350),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => IndoPayShell(
          location: state.uri.path,
          child: child,
        ),
        routes: [
          _route(AppRoute.home, const HomeScreen()),
          _route(AppRoute.tickets, const TicketsScreen()),
          _route(
            AppRoute.scan,
            const ScanQrScreen(),
            duration: const Duration(milliseconds: 350),
          ),
          _route(AppRoute.offers, const OffersScreen()),
          _route(AppRoute.search, const SearchScreen()),
          _route(AppRoute.wallet, const WalletScreen()),
          _route(AppRoute.passbook, const PassbookScreen()),
          _route(AppRoute.payments, const PaymentsScreen()),
          _route(AppRoute.transfer, const BankTransferScreen()),
          _route(AppRoute.merchant, const MerchantScreen()),
          _route(AppRoute.settings, const SettingsScreen()),
          _route(AppRoute.security, const SecurityScreen()),
          _route(AppRoute.support, const SupportScreen()),
        ],
      ),
    ],
  );
});

GoRoute _route(
  AppRoute route,
  Widget child, {
  Duration duration = const Duration(milliseconds: 220),
}) {
  return GoRoute(
    path: route.path,
    name: route.routeName,
    pageBuilder: (context, state) => _buildPage(
      state: state,
      child: child,
      duration: duration,
    ),
  );
}

CustomTransitionPage<void> _buildPage({
  required GoRouterState state,
  required Widget child,
  required Duration duration,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutExpo,
        ),
      );

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: child,
        ),
      );
    },
  );
}
