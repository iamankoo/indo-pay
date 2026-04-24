import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/app_routes.dart";
import "../../../design_system/indo_pay_colors.dart";
import "../../../design_system/indo_pay_tokens.dart";
import "../../version/data/update_repository.dart";
import "../../version/domain/app_update_info.dart";
import "../../version/presentation/update_dialog.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController = AnimationController(
    vsync: this,
    duration: IndoPayMotion.hero,
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 0.92,
    end: 1,
  ).animate(
    CurvedAnimation(
      parent: _scaleController,
      curve: IndoPayMotion.interactive,
    ),
  );
  late final Future<({AppUpdateInfo? info, bool shouldShow})>
      _updateDecisionFuture;

  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _updateDecisionFuture = _prepareUpdateDecision();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _visible = true);
      _scaleController.forward();
      _goHome();
    });
  }

  Future<void> _goHome() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) {
      return;
    }

    final decision = await _updateDecisionFuture;
    if (!mounted) {
      return;
    }

    if (decision.info != null && decision.shouldShow) {
      showDialog(
        context: context,
        barrierDismissible: !decision.info!.forceUpdate,
        builder: (_) => UpdateDialog(info: decision.info!),
      );
      return;
    }

    if (mounted) {
      AppRoute.home.go(context);
    }
  }

  Future<({AppUpdateInfo? info, bool shouldShow})> _prepareUpdateDecision() async {
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final updateRepo = container.read(updateRepositoryProvider);
      final info = await updateRepo
          .checkUpdate()
          .timeout(const Duration(milliseconds: 850), onTimeout: () => null);

      if (info == null) {
        return (info: null, shouldShow: false);
      }

      final shouldShow = await updateRepo.shouldShowUpdate(info);
      return (info: info, shouldShow: shouldShow);
    } catch (_) {
      return (info: null, shouldShow: false);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDark
              ? IndoPayColors.darkBackground
              : IndoPayColors.lightBackground,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: _GlowCircle(
                size: 260,
                color: IndoPayColors.accent.withValues(alpha: 0.16),
              ),
            ),
            Positioned(
              left: -60,
              bottom: -80,
              child: _GlowCircle(
                size: 220,
                color: IndoPayColors.primary.withValues(alpha: 0.14),
              ),
            ),
            Center(
              child: AnimatedOpacity(
                duration: IndoPayMotion.hero,
                curve: IndoPayMotion.interactive,
                opacity: _visible ? 1 : 0,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 296,
                        ),
                        child: Image.asset(
                          "assets/branding/indo-pay-splash-logo.png",
                          width: 296,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "Built with love",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: isDark
                                  ? Colors.white
                                  : IndoPayColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "by - Aniket Raj",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isDark
                                  ? Colors.white70
                                  : IndoPayColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
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

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
