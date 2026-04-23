import "package:flutter/material.dart";

import "../../../core/app_routes.dart";
import "../../../design_system/indo_pay_colors.dart";
import "../../../design_system/indo_pay_tokens.dart";
import "../../../design_system/widgets/fintech_icon.dart";
import "../../../design_system/widgets/fintech_tap_scale.dart";
import "../../../design_system/widgets/glass_card.dart";
import "../../../design_system/widgets/scan_hero_orb.dart";

class ScanQrScreen extends StatelessWidget {
  const ScanQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Scan QR")),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDark
              ? IndoPayColors.darkBackground
              : IndoPayColors.lightBackground,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            IndoPaySpacing.page,
            IndoPaySpacing.lg,
            IndoPaySpacing.page,
            IndoPaySpacing.page,
          ),
          children: [
            Center(
              child: Hero(
                tag: AppRoute.scan.heroTag,
                child: const ScanHeroOrb(diameter: 118),
              ),
            ),
            const SizedBox(height: IndoPaySpacing.xl),
            GlassCard(
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: _ScannerFramePainter(
                    color: isDark ? Colors.white : IndoPayColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: IndoPaySpacing.xl),
            Row(
              children: [
                Expanded(
                  child: _ScanAction(
                    label: "My QR",
                    icon: FintechIconGlyph.scan,
                    onTap: () => AppRoute.merchant.go(context),
                  ),
                ),
                const SizedBox(width: IndoPaySpacing.md),
                Expanded(
                  child: _ScanAction(
                    label: "Passbook",
                    icon: FintechIconGlyph.passbook,
                    onTap: () => AppRoute.passbook.go(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanAction extends StatelessWidget {
  const _ScanAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final FintechIconGlyph icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FintechTapScale(
      onTap: onTap,
      child: GlassCard(
        child: Column(
          children: [
            FintechIcon(icon),
            const SizedBox(height: IndoPaySpacing.sm),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  const _ScannerFramePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 4;

    final inset = size.width * 0.16;
    final corner = size.width * 0.18;

    canvas.drawLine(Offset(inset, inset + corner), Offset(inset, inset), paint);
    canvas.drawLine(Offset(inset, inset), Offset(inset + corner, inset), paint);

    canvas.drawLine(
      Offset(size.width - inset - corner, inset),
      Offset(size.width - inset, inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(size.width - inset, inset + corner),
      paint,
    );

    canvas.drawLine(
      Offset(inset, size.height - inset - corner),
      Offset(inset, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(inset, size.height - inset),
      Offset(inset + corner, size.height - inset),
      paint,
    );

    canvas.drawLine(
      Offset(size.width - inset - corner, size.height - inset),
      Offset(size.width - inset, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, size.height - inset - corner),
      Offset(size.width - inset, size.height - inset),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerFramePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
