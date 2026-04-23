import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "core/routing/app_router.dart";
import "design_system/indo_pay_theme.dart";

class IndoPayApp extends ConsumerWidget {
  const IndoPayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: "Indo Pay",
      debugShowCheckedModeBanner: false,
      theme: buildIndoPayTheme(Brightness.light),
      darkTheme: buildIndoPayTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
