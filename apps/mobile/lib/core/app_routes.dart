import "package:flutter/widgets.dart";
import "package:go_router/go_router.dart";

enum AppRoute {
  splash("/splash", "splash"),
  home("/", "home"),
  tickets("/tickets", "tickets"),
  scan("/scan", "scan"),
  offers("/offers", "offers"),
  search("/search", "search"),
  wallet("/wallet", "wallet"),
  passbook("/passbook", "passbook"),
  payments("/payments", "payments"),
  transfer("/transfer", "transfer"),
  merchant("/merchant", "merchant"),
  settings("/settings", "settings"),
  security("/security", "security"),
  support("/support", "support");

  const AppRoute(this.path, this.routeName);

  final String path;
  final String routeName;

  String get heroTag => switch (this) {
        AppRoute.scan => "scan-to-pay-hero",
        _ => routeName,
      };

  bool matches(String location) {
    final normalized = Uri.parse(location).path;
    if (path == "/") {
      return normalized == "/";
    }

    return normalized == path || normalized.startsWith("$path/");
  }
}

extension AppRouteNavigation on AppRoute {
  String location({
    Map<String, String> queryParameters = const <String, String>{},
  }) {
    if (queryParameters.isEmpty) {
      return path;
    }

    return Uri(path: path, queryParameters: queryParameters).toString();
  }

  void go(
    BuildContext context, {
    Map<String, String> queryParameters = const <String, String>{},
  }) {
    GoRouter.of(context).go(location(queryParameters: queryParameters));
  }

  Future<T?> push<T>(
    BuildContext context, {
    Map<String, String> queryParameters = const <String, String>{},
  }) {
    return GoRouter.of(context).push<T>(
      location(queryParameters: queryParameters),
    );
  }
}

enum AppShellTab {
  tickets,
  scan,
  offers,
}

extension AppShellTabX on AppShellTab {
  AppRoute get route => switch (this) {
        AppShellTab.tickets => AppRoute.tickets,
        AppShellTab.scan => AppRoute.scan,
        AppShellTab.offers => AppRoute.offers,
      };

  String get label => switch (this) {
        AppShellTab.tickets => "Tickets",
        AppShellTab.scan => "Scan",
        AppShellTab.offers => "Offers",
      };
}

AppShellTab? shellTabForLocation(String location) {
  final normalized = Uri.parse(location).path;

  if (AppRoute.tickets.matches(normalized)) {
    return AppShellTab.tickets;
  }

  if (AppRoute.scan.matches(normalized)) {
    return AppShellTab.scan;
  }

  if (AppRoute.offers.matches(normalized)) {
    return AppShellTab.offers;
  }

  return null;
}
