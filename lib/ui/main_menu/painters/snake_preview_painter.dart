import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../utils/constants.dart';

class SnakePreviewPainter extends CustomPainter {
  final SnakeSkin skin;
  final double t;

  SnakePreviewPainter({required this.skin, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final double H = size.height;
    const int N = 20;
    const double SP = 8.5;
    const double amp = 16;
    const double bodyR = 6;
    const double headR = 10;
    const double startX = 8;

    final List<Offset> segs = [];
    for (int i = 0; i < N; i++) {
      final double phase = t - (N - 1 - i) * 0.35;
      segs.add(Offset(startX + i * SP, H / 2 + sin(phase) * amp));
    }
    for (int i = 0; i < N - 1; i++) {
      final double mix = i / N;
      final Color col = Color.lerp(skin.bodyColorDark, skin.bodyColor, mix)!;
      canvas.drawCircle(segs[i], bodyR, Paint()..color = col);
    }
    final Offset h = segs.last;
    canvas.drawCircle(h + const Offset(1.5, 2), headR,
        Paint()..color = const Color(0x40000000));
    final radial = ui.Gradient.radial(h, headR * 2.2,
        [skin.bodyColor.withOpacity(0.2), skin.bodyColor.withOpacity(0)]);
    canvas.drawCircle(h, headR * 2.2, Paint()..shader = radial);
    final headGrad = ui.Gradient.radial(
      h - Offset(headR * 0.3, headR * 0.3), 0,
      [skin.bodyColor, skin.bodyColorDark],
      null, ui.TileMode.clamp, null, null, headR,
    );
    canvas.drawCircle(h, headR, Paint()..shader = headGrad);
    canvas.drawCircle(h + Offset(-headR * 0.28, -headR * 0.28), headR * 0.3,
        Paint()..color = const Color(0x55FFFFFF));
    _drawExpression(canvas, h, headR, t);
  }

  void _drawExpression(Canvas canvas, Offset h, double r, double t) {
    switch (skin.id) {
      case 'classic':  _exprClassic(canvas, h, r, t);  break;
      case 'hot':      _exprHot(canvas, h, r, t);      break;
      case 'sorriso':  _exprSorriso(canvas, h, r, t);  break;
      case 'veneno':   _exprVeneno(canvas, h, r, t);   break;
      case 'fantasma': _exprFantasma(canvas, h, r, t); break;
      case 'piranha':  _exprPiranha(canvas, h, r, t);  break;
      case 'lava':     _exprLava(canvas, h, r, t);     break;
      case 'alien':    _exprAlien(canvas, h, r, t);    break;
      case 'lili':     _exprLili(canvas, h, r, t);     break;
      case 'robo':     _exprRobo(canvas, h, r, t);     break;
      case 'serpente':  _exprSerpente(canvas, h, r, t);  break;
      default:         _defaultEyes(canvas, h, r);      break;
    }
  }

  void _exprSerpente(Canvas canvas, Offset h, double r, double t) {
    final brow = Paint()..color=const Color(0xFF1A3300)..strokeWidth=r*0.22
      ..strokeCap=StrokeCap.round..style=PaintingStyle.stroke;
    canvas.drawPath(Path()
      ..moveTo(h.dx-r*0.35,h.dy-r*0.55)
      ..quadraticBezierTo(h.dx+r*0.05,h.dy-r*0.72,h.dx+r*0.42,h.dy-r*0.50), brow);
    canvas.drawPath(Path()
      ..moveTo(h.dx-r*0.35,h.dy+r*0.55)
      ..quadraticBezierTo(h.dx+r*0.05,h.dy+r*0.72,h.dx+r*0.42,h.dy+r*0.50), brow);
    for (final ey in [h.dy-r*0.35, h.dy+r*0.35]) {
      canvas.drawOval(Rect.fromCenter(center:Offset(h.dx+r*0.12,ey),
          width:r*0.55,height:r*0.38), Paint()..color=const Color(0xFFFFEEEE));
      canvas.drawCircle(Offset(h.dx+r*0.18,ey),r*0.22,Paint()..color=const Color(0xFFCC0000));
      canvas.drawOval(Rect.fromCenter(center:Offset(h.dx+r*0.20,ey),
          width:r*0.08,height:r*0.20),Paint()..color=Colors.black);
      canvas.drawCircle(Offset(h.dx+r*0.13,ey-r*0.08),r*0.07,
          Paint()..color=Colors.white.withOpacity(0.8));
    }
    canvas.drawCircle(Offset(h.dx+r*0.72,h.dy-r*0.1),r*0.07,Paint()..color=const Color(0xFF1A3300));
    canvas.drawCircle(Offset(h.dx+r*0.72,h.dy+r*0.1),r*0.07,Paint()..color=const Color(0xFF1A3300));
    canvas.drawPath(Path()
      ..moveTo(h.dx+r*0.2,h.dy-r*0.15)
      ..quadraticBezierTo(h.dx+r*1.1,h.dy,h.dx+r*0.2,h.dy+r*0.15)
      ..close(),Paint()..color=const Color(0xFF8B0000));
    final tw=Paint()..color=Colors.white;
    for (int i=0;i<4;i++){
      final tx=h.dx+r*(0.3+i*0.18);
      canvas.drawPath(Path()..moveTo(tx,h.dy-r*0.14)..lineTo(tx+r*0.08,h.dy-r*0.38)
          ..lineTo(tx+r*0.16,h.dy-r*0.14)..close(),tw);
    }
    for (int i=0;i<3;i++){
      final tx=h.dx+r*(0.38+i*0.18);
      canvas.drawPath(Path()..moveTo(tx,h.dy+r*0.14)..lineTo(tx+r*0.08,h.dy+r*0.32)
          ..lineTo(tx+r*0.16,h.dy+r*0.14)..close(),Paint()..color=const Color(0xFFDDDDCC));
    }
    final ext=sin(t*4)*0.3+0.7;
    final tg=Paint()..color=const Color(0xFFFF1744)..strokeWidth=r*0.14
      ..strokeCap=StrokeCap.round..style=PaintingStyle.stroke;
    canvas.drawLine(Offset(h.dx+r*0.9,h.dy),Offset(h.dx+r*(0.9+0.5*ext),h.dy),tg);
    final tip=Offset(h.dx+r*(0.9+0.5*ext),h.dy);
    canvas.drawLine(tip,Offset(tip.dx+r*0.22*ext,tip.dy-r*0.18*ext),tg);
    canvas.drawLine(tip,Offset(tip.dx+r*0.22*ext,tip.dy+r*0.18*ext),tg);
  }

  void _defaultEyes(Canvas canvas, Offset h, double r) {
    for (final ey in [h.dy - r * 0.4, h.dy + r * 0.4]) {
      canvas.drawCircle(Offset(h.dx + r * 0.28, ey), r * 0.27, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(h.dx + r * 0.32, ey), r * 0.15, Paint()..color = Colors.black);
      canvas.drawCircle(Offset(h.dx + r * 0.25, ey - r * 0.1), r * 0.07,
          Paint()..color = Colors.white.withOpacity(0.7));
    }
  }

  void _exprClassic(Canvas canvas, Offset h, double r, double t) {
    _defaultEyes(canvas, h, r);
    final double ext = (sin(t * 2) * 0.5 + 0.5);
    final Paint tongue = Paint()
      ..color = const Color(0xFFFF1744) ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke;
    final double len = r * (0.7 + ext * 0.5);
    canvas.drawLine(Offset(h.dx + r, h.dy), Offset(h.dx + r + len, h.dy), tongue);
    canvas.drawLine(Offset(h.dx + r + len * 0.6, h.dy),
        Offset(h.dx + r + len, h.dy - r * 0.35), tongue);
    canvas.drawLine(Offset(h.dx + r + len * 0.6, h.dy),
        Offset(h.dx + r + len, h.dy + r * 0.35), tongue);
  }

  void _exprHot(Canvas canvas, Offset h, double r, double t) {
    final Paint brow = Paint()
      ..color = const Color(0xFF1A0000) ..strokeWidth = r * 0.2
      ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(h.dx + r * 0.05, h.dy - r * 0.62),
        Offset(h.dx + r * 0.52, h.dy - r * 0.38), brow);
    canvas.drawLine(Offset(h.dx + r * 0.05, h.dy + r * 0.62),
        Offset(h.dx + r * 0.52, h.dy + r * 0.38), brow);
    for (final ey in [h.dy - r * 0.38, h.dy + r * 0.38]) {
      canvas.drawCircle(Offset(h.dx + r * 0.22, ey), r * 0.26, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(h.dx + r * 0.27, ey), r * 0.17,
          Paint()..color = const Color(0xFFFF1744));
      canvas.drawLine(Offset(h.dx + r * 0.05, ey - r * 0.13),
          Offset(h.dx + r * 0.42, ey - r * 0.05),
          Paint()..color = const Color(0xFF1A0000)
            ..strokeWidth = r * 0.15 ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke);
    }
    canvas.drawLine(Offset(h.dx + r * 0.05, h.dy + r * 0.55),
        Offset(h.dx + r * 0.55, h.dy + r * 0.55), brow);
  }

  void _exprSorriso(Canvas canvas, Offset h, double r, double t) {
    final Paint eye = Paint()
      ..color = const Color(0xFF3E2000) ..strokeWidth = r * 0.17
      ..style = PaintingStyle.stroke ..strokeCap = StrokeCap.round;
    for (final ey in [h.dy - r * 0.44, h.dy + r * 0.44]) {
      canvas.drawArc(Rect.fromCenter(center: Offset(h.dx + r * 0.22, ey),
          width: r * 0.5, height: r * 0.5), pi, pi, false, eye);
    }
    canvas.drawArc(Rect.fromCenter(center: Offset(h.dx + r * 0.18, h.dy + r * 0.05),
        width: r * 1.3, height: r * 1.1), 0.0, pi, true,
        Paint()..color = const Color(0xFF1A0E00));
    final tp = Paint()..color = Colors.white;
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(Rect.fromLTWH(h.dx - r * 0.22 + i * r * 0.28,
          h.dy + r * 0.04, r * 0.22, r * 0.28), tp);
    }
    for (final cy in [h.dy + r * 0.55, h.dy - r * 0.55]) {
      canvas.drawCircle(Offset(h.dx + r * 0.55, cy), r * 0.2,
          Paint()..color = const Color(0x40FF5080));
    }
  }

  void _exprVeneno(Canvas canvas, Offset h, double r, double t) {
    final Paint x = Paint()
      ..color = const Color(0xFF00E676) ..strokeWidth = r * 0.2
      ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke;
    for (final ey in [h.dy - r * 0.4, h.dy + r * 0.4]) {
      canvas.drawCircle(Offset(h.dx + r * 0.25, ey), r * 0.27,
          Paint()..color = const Color(0xFF1F1F1F));
      canvas.drawLine(Offset(h.dx + r * 0.1, ey - r * 0.16),
          Offset(h.dx + r * 0.4, ey + r * 0.16), x);
      canvas.drawLine(Offset(h.dx + r * 0.4, ey - r * 0.16),
          Offset(h.dx + r * 0.1, ey + r * 0.16), x);
    }
    canvas.drawArc(Rect.fromCenter(center: Offset(h.dx + r * 0.22, h.dy + r * 0.62),
        width: r * 0.7, height: r * 0.5), 0, pi, false,
        Paint()..color = const Color(0xFF00E676)
          ..strokeWidth = r * 0.15 ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(h.dx + r * 0.22, h.dy + r * 0.5),
        Offset(h.dx + r * 0.22, h.dy + r * 0.9),
        Paint()..color = const Color(0xFF00E676)
          ..strokeWidth = r * 0.18 ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
  }

  void _exprFantasma(Canvas canvas, Offset h, double r, double t) {
    for (final ey in [h.dy - r * 0.4, h.dy + r * 0.4]) {
      canvas.drawCircle(Offset(h.dx + r * 0.22, ey), r * 0.32,
          Paint()..color = const Color(0xFF111111));
      canvas.drawCircle(Offset(h.dx + r * 0.14, ey - r * 0.12), r * 0.12,
          Paint()..color = const Color(0x99C8E6FF));
      canvas.drawCircle(Offset(h.dx + r * 0.3, ey + r * 0.08), r * 0.07,
          Paint()..color = const Color(0x66C8E6FF));
    }
    canvas.drawCircle(Offset(h.dx + r * 0.32, h.dy + r * 0.45), r * 0.26,
        Paint()..color = const Color(0xFF111111));
    canvas.drawCircle(Offset(h.dx + r * 0.32, h.dy + r * 0.45), r * 0.26,
        Paint()..color = const Color(0x44FFFFFF)
          ..style = PaintingStyle.stroke ..strokeWidth = 1.0);
  }

  void _exprPiranha(Canvas canvas, Offset h, double r, double t) {
    for (final ey in [h.dy - r * 0.46, h.dy + r * 0.46]) {
      canvas.drawCircle(Offset(h.dx + r * 0.2, ey), r * 0.26, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(h.dx + r * 0.24, ey), r * 0.17,
          Paint()..color = const Color(0xFF1B5E20));
      canvas.drawCircle(Offset(h.dx + r * 0.24, ey), r * 0.09, Paint()..color = Colors.black);
    }
    final Paint brow = Paint()
      ..color = const Color(0xFF0D1A08) ..strokeWidth = r * 0.16
      ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(h.dx + r * 0.02, h.dy - r * 0.65),
        Offset(h.dx + r * 0.48, h.dy - r * 0.38), brow);
    canvas.drawLine(Offset(h.dx + r * 0.02, h.dy + r * 0.65),
        Offset(h.dx + r * 0.48, h.dy + r * 0.38), brow);
    canvas.drawArc(Rect.fromCenter(center: Offset(h.dx + r * 0.1, h.dy),
        width: r * 1.6, height: r * 1.6), -0.3, pi + 0.6, true,
        Paint()..color = const Color(0xFF0D1A08));
    final t1 = Paint()..color = Colors.white;
    final t2 = Paint()..color = const Color(0xFFCCFF80);
    for (int i = 0; i < 4; i++) {
      final tx = h.dx - r * 0.38 + i * r * 0.26;
      canvas.drawPath(Path()..moveTo(tx, h.dy)
        ..lineTo(tx + r * 0.13, h.dy - r * 0.3)
        ..lineTo(tx + r * 0.26, h.dy)..close(), t1);
    }
    for (int i = 0; i < 3; i++) {
      final tx = h.dx - r * 0.25 + i * r * 0.26;
      canvas.drawPath(Path()..moveTo(tx, h.dy)
        ..lineTo(tx + r * 0.13, h.dy + r * 0.26)
        ..lineTo(tx + r * 0.26, h.dy)..close(), t2);
    }
  }

  void _exprLava(Canvas canvas, Offset h, double r, double t) {
    final scar = Paint()..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = r * 0.13 ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(h.dx - r * 0.05, h.dy - r * 0.72),
        Offset(h.dx + r * 0.05, h.dy + r * 0.72), scar);
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(Offset(h.dx - r * 0.22, h.dy + i * r * 0.26),
          Offset(h.dx + r * 0.22, h.dy + i * r * 0.26), scar);
    }
    canvas.drawCircle(Offset(h.dx + r * 0.28, h.dy), r * 0.34, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(h.dx + r * 0.3, h.dy), r * 0.22,
        Paint()..color = const Color(0xFFFF3D00));
    canvas.drawCircle(Offset(h.dx + r * 0.3, h.dy), r * 0.1, Paint()..color = Colors.black);
    canvas.drawLine(Offset(h.dx + r * 0.06, h.dy - r * 0.3),
        Offset(h.dx + r * 0.52, h.dy - r * 0.3),
        Paint()..color = skin.bodyColorDark ..strokeWidth = r * 0.2
          ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke);
    canvas.drawLine(Offset(h.dx - r * 0.05, h.dy - r * 0.48),
        Offset(h.dx + r * 0.55, h.dy - r * 0.34),
        Paint()..color = const Color(0xFF2A0800) ..strokeWidth = r * 0.16
          ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke);
    canvas.drawArc(Rect.fromCenter(center: Offset(h.dx + r * 0.22, h.dy + r * 0.7),
        width: r * 0.7, height: r * 0.4), 0, pi, false,
        Paint()..color = const Color(0xFF2A0800) ..strokeWidth = r * 0.15
          ..style = PaintingStyle.stroke ..strokeCap = StrokeCap.round);
  }

  void _exprAlien(Canvas canvas, Offset h, double r, double t) {
    final lens = Paint()..color = const Color(0xE0000000);
    final ring = Paint()..color = skin.accentColor.withOpacity(0.9)
      ..strokeWidth = r * 0.14 ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(h.dx + r * 0.2, h.dy - r * 0.38), r * 0.34, lens);
    canvas.drawCircle(Offset(h.dx + r * 0.2, h.dy - r * 0.38), r * 0.34, ring);
    canvas.drawCircle(Offset(h.dx + r * 0.22, h.dy + r * 0.38), r * 0.2, lens);
    canvas.drawCircle(Offset(h.dx + r * 0.22, h.dy + r * 0.38), r * 0.2, ring);
    final double wobble = sin(t * 3) * r * 0.12;
    final Paint ant = Paint()..color = skin.accentColor ..strokeWidth = r * 0.1
      ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(h.dx, h.dy - r), Offset(h.dx + wobble, h.dy - r * 1.6), ant);
    canvas.drawCircle(Offset(h.dx + wobble, h.dy - r * 1.65), r * 0.14,
        Paint()..color = skin.accentColor);
    canvas.drawArc(Rect.fromCenter(center: Offset(h.dx + r * 0.3, h.dy + r * 0.22),
        width: r * 0.65, height: r * 0.5), pi * 0.1, pi * 0.8, false,
        Paint()..color = const Color(0xFF1A2A00) ..strokeWidth = r * 0.15
          ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke);
  }

  void _exprLili(Canvas canvas, Offset h, double r, double t) {
    final bool piscando = (t % (pi * 2)) > pi * 1.8;
    for (final ey in [h.dy - r * 0.42, h.dy + r * 0.42]) {
      if (piscando) {
        canvas.drawLine(Offset(h.dx + r * 0.08, ey), Offset(h.dx + r * 0.38, ey),
            Paint()..color = skin.bodyColorDark ..strokeWidth = r * 0.22
              ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke);
      } else {
        canvas.drawCircle(Offset(h.dx + r * 0.2, ey), r * 0.3, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(h.dx + r * 0.24, ey), r * 0.2, Paint()..color = Colors.black);
        canvas.drawCircle(Offset(h.dx + r * 0.16, ey - r * 0.1), r * 0.1,
            Paint()..color = Colors.white);
      }
    }
    for (final cy in [h.dy - r * 0.62, h.dy + r * 0.62]) {
      canvas.drawCircle(Offset(h.dx + r * 0.55, cy), r * 0.22,
          Paint()..color = const Color(0x55FF5080));
    }
    canvas.drawArc(Rect.fromCenter(center: Offset(h.dx + r * 0.28, h.dy + r * 0.18),
        width: r * 0.6, height: r * 0.5), 0.1, pi - 0.2, false,
        Paint()..color = const Color(0xFF880E4F) ..strokeWidth = r * 0.14
          ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke);
  }

  void _exprRobo(Canvas canvas, Offset h, double r, double t) {
    final dark = Paint()..color = const Color(0xFF1A1A1A);
    final led0 = Paint()..color = const Color(0xFF00E5FF);
    final led1 = Paint()..color = const Color(0xFFF44336);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(h.dx - r * 0.05, h.dy - r * 0.65, r * 0.75, r * 1.2),
        const Radius.circular(4)), dark);
    final bool blink = (t % (pi * 2)) > pi * 1.85;
    for (int i = 0; i < 2; i++) {
      final ey = i == 0 ? h.dy - r * 0.38 : h.dy + r * 0.38;
      if (blink) {
        canvas.drawRect(Rect.fromLTWH(h.dx + r * 0.08, ey - r * 0.04, r * 0.34, r * 0.08),
            i == 0 ? led0 : led1);
      } else {
        canvas.drawRect(Rect.fromLTWH(h.dx + r * 0.06, ey - r * 0.2, r * 0.38, r * 0.38),
            i == 0 ? led0 : led1);
      }
    }
    final mouthLeds = [1, 0, 0, 0, 1];
    final mouthBot  = [0, 1, 1, 1, 0];
    for (int i = 0; i < 5; i++) {
      if (mouthLeds[i] == 1) canvas.drawRect(Rect.fromLTWH(
          h.dx + r * 0.02 + i * r * 0.13, h.dy + r * 0.32, r * 0.1, r * 0.12), led0);
      if (mouthBot[i]  == 1) canvas.drawRect(Rect.fromLTWH(
          h.dx + r * 0.02 + i * r * 0.13, h.dy + r * 0.45, r * 0.1, r * 0.12), led0);
    }
    canvas.drawLine(Offset(h.dx, h.dy - r), Offset(h.dx, h.dy - r * 1.55),
        Paint()..color = const Color(0xFF78909C) ..strokeWidth = r * 0.1
          ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke);
    canvas.drawCircle(Offset(h.dx, h.dy - r * 1.6), r * 0.12, led1);
  }

  @override
  bool shouldRepaint(covariant SnakePreviewPainter old) =>
      old.t != t || old.skin.id != skin.id;
}
