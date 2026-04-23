import "dart:math" as math;

import "package:flutter/material.dart";

enum FintechIconGlyph {
  scan,
  transfer,
  passbook,
  recharge,
  send,
  wallet,
  tickets,
  offers,
  search,
  bell,
  chevronRight,
  credit,
  debit,
  success,
  clock,
  settings,
  shield,
  support,
  logout,
}

class FintechIcon extends StatelessWidget {
  const FintechIcon(
    this.glyph, {
    super.key,
    this.size = 24,
    this.color = const Color(0xFF0F0F1A),
    this.strokeWidth = 1.9,
  });

  final FintechIconGlyph glyph;
  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _FintechIconPainter(
        glyph: glyph,
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _FintechIconPainter extends CustomPainter {
  const _FintechIconPainter({
    required this.glyph,
    required this.color,
    required this.strokeWidth,
  });

  final FintechIconGlyph glyph;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (glyph) {
      case FintechIconGlyph.scan:
        _paintScan(canvas, size, paint);
      case FintechIconGlyph.transfer:
        _paintTransfer(canvas, size, paint);
      case FintechIconGlyph.passbook:
        _paintPassbook(canvas, size, paint);
      case FintechIconGlyph.recharge:
        _paintRecharge(canvas, size, paint);
      case FintechIconGlyph.send:
        _paintSend(canvas, size, paint);
      case FintechIconGlyph.wallet:
        _paintWallet(canvas, size, paint);
      case FintechIconGlyph.tickets:
        _paintTickets(canvas, size, paint);
      case FintechIconGlyph.offers:
        _paintOffers(canvas, size, paint);
      case FintechIconGlyph.search:
        _paintSearch(canvas, size, paint);
      case FintechIconGlyph.bell:
        _paintBell(canvas, size, paint);
      case FintechIconGlyph.chevronRight:
        _paintChevronRight(canvas, size, paint);
      case FintechIconGlyph.credit:
        _paintCredit(canvas, size, paint);
      case FintechIconGlyph.debit:
        _paintDebit(canvas, size, paint);
      case FintechIconGlyph.success:
        _paintSuccess(canvas, size, paint);
      case FintechIconGlyph.clock:
        _paintClock(canvas, size, paint);
      case FintechIconGlyph.settings:
        _paintSettings(canvas, size, paint);
      case FintechIconGlyph.shield:
        _paintShield(canvas, size, paint);
      case FintechIconGlyph.support:
        _paintSupport(canvas, size, paint);
      case FintechIconGlyph.logout:
        _paintLogout(canvas, size, paint);
    }
  }

  void _paintScan(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    final corner = s * 0.24;
    final inset = s * 0.13;
    final inner = s * 0.2;

    canvas.drawLine(Offset(inset, inset + corner), Offset(inset, inset), paint);
    canvas.drawLine(Offset(inset, inset), Offset(inset + corner, inset), paint);

    canvas.drawLine(Offset(s - inset - corner, inset), Offset(s - inset, inset), paint);
    canvas.drawLine(Offset(s - inset, inset), Offset(s - inset, inset + corner), paint);

    canvas.drawLine(Offset(inset, s - inset - corner), Offset(inset, s - inset), paint);
    canvas.drawLine(Offset(inset, s - inset), Offset(inset + corner, s - inset), paint);

    canvas.drawLine(
      Offset(s - inset - corner, s - inset),
      Offset(s - inset, s - inset),
      paint,
    );
    canvas.drawLine(
      Offset(s - inset, s - inset - corner),
      Offset(s - inset, s - inset),
      paint,
    );

    final fill = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.34, s * 0.34, inner * 0.62, inner * 0.62),
        Radius.circular(s * 0.04),
      ),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.52, s * 0.34, inner * 0.46, inner * 0.46),
        Radius.circular(s * 0.04),
      ),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.44, s * 0.54, inner * 0.72, inner * 0.42),
        Radius.circular(s * 0.04),
      ),
      fill,
    );
  }

  void _paintTransfer(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    canvas.drawLine(Offset(s * 0.18, s * 0.34), Offset(s * 0.7, s * 0.34), paint);
    canvas.drawLine(Offset(s * 0.58, s * 0.22), Offset(s * 0.7, s * 0.34), paint);
    canvas.drawLine(Offset(s * 0.58, s * 0.46), Offset(s * 0.7, s * 0.34), paint);

    canvas.drawLine(Offset(s * 0.82, s * 0.66), Offset(s * 0.3, s * 0.66), paint);
    canvas.drawLine(Offset(s * 0.42, s * 0.54), Offset(s * 0.3, s * 0.66), paint);
    canvas.drawLine(Offset(s * 0.42, s * 0.78), Offset(s * 0.3, s * 0.66), paint);
  }

  void _paintPassbook(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.18, s * 0.16, s * 0.64, s * 0.68),
      Radius.circular(s * 0.12),
    );
    canvas.drawRRect(rect, paint);
    canvas.drawLine(Offset(s * 0.32, s * 0.16), Offset(s * 0.32, s * 0.84), paint);
    canvas.drawLine(Offset(s * 0.42, s * 0.36), Offset(s * 0.68, s * 0.36), paint);
    canvas.drawLine(Offset(s * 0.42, s * 0.5), Offset(s * 0.64, s * 0.5), paint);
    canvas.drawLine(Offset(s * 0.42, s * 0.64), Offset(s * 0.58, s * 0.64), paint);
  }

  void _paintRecharge(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.28, s * 0.12, s * 0.44, s * 0.76),
      Radius.circular(s * 0.12),
    );
    canvas.drawRRect(rect, paint);
    canvas.drawLine(Offset(s * 0.42, s * 0.2), Offset(s * 0.58, s * 0.2), paint);

    final bolt = Path()
      ..moveTo(s * 0.52, s * 0.34)
      ..lineTo(s * 0.42, s * 0.54)
      ..lineTo(s * 0.52, s * 0.54)
      ..lineTo(s * 0.46, s * 0.72)
      ..lineTo(s * 0.6, s * 0.48)
      ..lineTo(s * 0.5, s * 0.48)
      ..close();
    final fill = Paint()..color = color;
    canvas.drawPath(bolt, fill);
  }

  void _paintSend(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    final path = Path()
      ..moveTo(s * 0.16, s * 0.52)
      ..lineTo(s * 0.82, s * 0.18)
      ..lineTo(s * 0.62, s * 0.82)
      ..lineTo(s * 0.5, s * 0.58)
      ..lineTo(s * 0.16, s * 0.52)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawLine(Offset(s * 0.5, s * 0.58), Offset(s * 0.82, s * 0.18), paint);
  }

  void _paintWallet(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    final base = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.14, s * 0.26, s * 0.72, s * 0.5),
      Radius.circular(s * 0.14),
    );
    canvas.drawRRect(base, paint);
    canvas.drawLine(Offset(s * 0.24, s * 0.26), Offset(s * 0.36, s * 0.14), paint);
    canvas.drawLine(Offset(s * 0.36, s * 0.14), Offset(s * 0.72, s * 0.14), paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.54, s * 0.38, s * 0.22, s * 0.18),
        Radius.circular(s * 0.08),
      ),
      paint,
    );
    final fill = Paint()..color = color;
    canvas.drawCircle(Offset(s * 0.6, s * 0.47), s * 0.02, fill);
  }

  void _paintTickets(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    final path = Path()
      ..moveTo(s * 0.18, s * 0.28)
      ..lineTo(s * 0.36, s * 0.28)
      ..arcToPoint(Offset(s * 0.42, s * 0.38), radius: Radius.circular(s * 0.1))
      ..arcToPoint(Offset(s * 0.48, s * 0.28), radius: Radius.circular(s * 0.1))
      ..lineTo(s * 0.82, s * 0.28)
      ..lineTo(s * 0.82, s * 0.72)
      ..lineTo(s * 0.48, s * 0.72)
      ..arcToPoint(Offset(s * 0.42, s * 0.62), radius: Radius.circular(s * 0.1))
      ..arcToPoint(Offset(s * 0.36, s * 0.72), radius: Radius.circular(s * 0.1))
      ..lineTo(s * 0.18, s * 0.72)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawLine(Offset(s * 0.32, s * 0.38), Offset(s * 0.68, s * 0.38), paint);
    canvas.drawLine(Offset(s * 0.32, s * 0.62), Offset(s * 0.68, s * 0.62), paint);
  }

  void _paintOffers(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    final path = Path()
      ..moveTo(s * 0.26, s * 0.18)
      ..lineTo(s * 0.72, s * 0.18)
      ..lineTo(s * 0.84, s * 0.3)
      ..lineTo(s * 0.4, s * 0.74)
      ..lineTo(s * 0.18, s * 0.52)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(s * 0.38, s * 0.36), s * 0.045, paint);
    canvas.drawCircle(Offset(s * 0.64, s * 0.56), s * 0.045, paint);
    canvas.drawLine(Offset(s * 0.44, s * 0.58), Offset(s * 0.58, s * 0.34), paint);
  }

  void _paintSearch(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    canvas.drawCircle(Offset(s * 0.42, s * 0.42), s * 0.22, paint);
    canvas.drawLine(Offset(s * 0.58, s * 0.58), Offset(s * 0.78, s * 0.78), paint);
  }

  void _paintBell(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    final path = Path()
      ..moveTo(s * 0.3, s * 0.72)
      ..lineTo(s * 0.3, s * 0.46)
      ..quadraticBezierTo(s * 0.3, s * 0.24, s * 0.5, s * 0.24)
      ..quadraticBezierTo(s * 0.7, s * 0.24, s * 0.7, s * 0.46)
      ..lineTo(s * 0.7, s * 0.72);
    canvas.drawPath(path, paint);
    canvas.drawLine(Offset(s * 0.24, s * 0.72), Offset(s * 0.76, s * 0.72), paint);
    canvas.drawLine(Offset(s * 0.5, s * 0.18), Offset(s * 0.5, s * 0.24), paint);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(s * 0.5, s * 0.74), radius: s * 0.08),
      math.pi,
      math.pi,
      false,
      paint,
    );
  }

  void _paintChevronRight(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    canvas.drawLine(Offset(s * 0.34, s * 0.24), Offset(s * 0.62, s * 0.5), paint);
    canvas.drawLine(Offset(s * 0.62, s * 0.5), Offset(s * 0.34, s * 0.76), paint);
  }

  void _paintCredit(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    canvas.drawLine(Offset(s * 0.72, s * 0.28), Offset(s * 0.3, s * 0.7), paint);
    canvas.drawLine(Offset(s * 0.3, s * 0.7), Offset(s * 0.3, s * 0.48), paint);
    canvas.drawLine(Offset(s * 0.3, s * 0.7), Offset(s * 0.52, s * 0.7), paint);
  }

  void _paintDebit(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    canvas.drawLine(Offset(s * 0.28, s * 0.72), Offset(s * 0.7, s * 0.3), paint);
    canvas.drawLine(Offset(s * 0.7, s * 0.3), Offset(s * 0.48, s * 0.3), paint);
    canvas.drawLine(Offset(s * 0.7, s * 0.3), Offset(s * 0.7, s * 0.52), paint);
  }

  void _paintSuccess(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    canvas.drawCircle(Offset(s * 0.5, s * 0.5), s * 0.3, paint);
    canvas.drawLine(Offset(s * 0.36, s * 0.52), Offset(s * 0.47, s * 0.64), paint);
    canvas.drawLine(Offset(s * 0.47, s * 0.64), Offset(s * 0.67, s * 0.4), paint);
  }

  void _paintClock(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    canvas.drawCircle(Offset(s * 0.5, s * 0.52), s * 0.28, paint);
    canvas.drawLine(Offset(s * 0.5, s * 0.52), Offset(s * 0.5, s * 0.38), paint);
    canvas.drawLine(Offset(s * 0.5, s * 0.52), Offset(s * 0.62, s * 0.58), paint);
  }

  void _paintSettings(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    canvas.drawCircle(Offset(s * 0.5, s * 0.5), s * 0.1, paint);
    canvas.drawCircle(Offset(s * 0.5, s * 0.5), s * 0.26, paint);
    canvas.drawLine(Offset(s * 0.5, s * 0.12), Offset(s * 0.5, s * 0.24), paint);
    canvas.drawLine(Offset(s * 0.5, s * 0.76), Offset(s * 0.5, s * 0.88), paint);
    canvas.drawLine(Offset(s * 0.12, s * 0.5), Offset(s * 0.24, s * 0.5), paint);
    canvas.drawLine(Offset(s * 0.76, s * 0.5), Offset(s * 0.88, s * 0.5), paint);
    canvas.drawLine(Offset(s * 0.22, s * 0.22), Offset(s * 0.3, s * 0.3), paint);
    canvas.drawLine(Offset(s * 0.7, s * 0.7), Offset(s * 0.78, s * 0.78), paint);
    canvas.drawLine(Offset(s * 0.22, s * 0.78), Offset(s * 0.3, s * 0.7), paint);
    canvas.drawLine(Offset(s * 0.7, s * 0.3), Offset(s * 0.78, s * 0.22), paint);
  }

  void _paintShield(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    final path = Path()
      ..moveTo(s * 0.5, s * 0.14)
      ..lineTo(s * 0.78, s * 0.24)
      ..lineTo(s * 0.74, s * 0.58)
      ..quadraticBezierTo(s * 0.68, s * 0.78, s * 0.5, s * 0.86)
      ..quadraticBezierTo(s * 0.32, s * 0.78, s * 0.26, s * 0.58)
      ..lineTo(s * 0.22, s * 0.24)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawLine(Offset(s * 0.38, s * 0.5), Offset(s * 0.47, s * 0.6), paint);
    canvas.drawLine(Offset(s * 0.47, s * 0.6), Offset(s * 0.64, s * 0.4), paint);
  }

  void _paintSupport(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    canvas.drawCircle(Offset(s * 0.5, s * 0.42), s * 0.24, paint);
    canvas.drawLine(Offset(s * 0.5, s * 0.66), Offset(s * 0.5, s * 0.76), paint);
    canvas.drawCircle(
      Offset(s * 0.5, s * 0.84),
      s * 0.02,
      Paint()..color = color,
    );
    final question = Path()
      ..moveTo(s * 0.4, s * 0.34)
      ..quadraticBezierTo(s * 0.42, s * 0.24, s * 0.52, s * 0.24)
      ..quadraticBezierTo(s * 0.64, s * 0.24, s * 0.64, s * 0.36)
      ..quadraticBezierTo(s * 0.64, s * 0.45, s * 0.54, s * 0.49)
      ..quadraticBezierTo(s * 0.48, s * 0.52, s * 0.48, s * 0.58);
    canvas.drawPath(question, paint);
  }

  void _paintLogout(Canvas canvas, Size size, Paint paint) {
    final s = size.width;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.18, s * 0.22, s * 0.36, s * 0.56),
        Radius.circular(s * 0.12),
      ),
      paint,
    );
    canvas.drawLine(Offset(s * 0.5, s * 0.5), Offset(s * 0.82, s * 0.5), paint);
    canvas.drawLine(Offset(s * 0.68, s * 0.36), Offset(s * 0.82, s * 0.5), paint);
    canvas.drawLine(Offset(s * 0.68, s * 0.64), Offset(s * 0.82, s * 0.5), paint);
  }

  @override
  bool shouldRepaint(covariant _FintechIconPainter oldDelegate) {
    return oldDelegate.glyph != glyph ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
