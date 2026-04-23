import "dart:ui";

import "package:flutter/material.dart";

import "../../../core/app_routes.dart";
import "../../../design_system/indo_pay_colors.dart";
import "../../../design_system/indo_pay_tokens.dart";

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

  bool _visible = false;

  @override
  void initState() {
    super.initState();
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
    await Future<void>.delayed(IndoPayMotion.splash);
    if (mounted) {
      AppRoute.home.go(context);
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        width: 220,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 28,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36),
                          color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.6),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 110,
                              width: 110,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    IndoPayColors.accent.withValues(alpha: 0.18),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: IndoPayColors.glowRing,
                                    width: 1.6,
                                  ),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    "assets/branding/indo_pay_logo.png",
                                    width: 62,
                                    height: 62,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Built with love",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isDark
                                        ? Colors.white
                                        : IndoPayColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "by - Aniket Raj",
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: isDark
                                        ? Colors.white70
                                        : IndoPayColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
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
