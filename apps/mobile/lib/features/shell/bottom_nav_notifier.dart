import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/app_routes.dart";

final bottomNavProvider =
    StateNotifierProvider<BottomNavNotifier, AppShellTab?>((ref) {
  return BottomNavNotifier();
});

class BottomNavNotifier extends StateNotifier<AppShellTab?> {
  BottomNavNotifier() : super(null);

  void syncWithRoute(String location) {
    state = shellTabForLocation(location);
  }

  void select(AppShellTab? tab) {
    state = tab;
  }
}
