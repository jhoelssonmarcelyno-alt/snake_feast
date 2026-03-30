import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors;
import 'head_painter.dart';

class TigerHead extends HeadPainter {
  static final TigerHead _i = TigerHead._();
  TigerHead._();
  factory TigerHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {}

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r*2.0, height: r*1.7), Paint()..color = body);
    for (final ey in [-r*.45, r*.45]) {
      canvas.drawCircle(Offset(r*.35, ey), r*.22, Paint()..color = Colors.white);
      canvas.drawOval(Rect.fromCenter(center: Offset(r*.4,ey), width: r*.14, height: r*.22), Paint()..color = Colors.black);
    }
    final stripe = Paint()..color = Colors.black.withValues(alpha: 0.6)..strokeWidth = r*.1;
    for (int i = -2; i <= 2; i++) {
      canvas.drawLine(Offset(r*.5, i*r*.18), Offset(r*.85, i*r*.15), stripe);
    }
    canvas.drawOval(Rect.fromCenter(center: Offset(r*.65,0), width: r*.55, height: r*.4), Paint()..color = dark);
    canvas.drawCircle(Offset(r*.82,-r*.1), r*.1, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(r*.82,r*.1), r*.1, Paint()..color = Colors.black);
  }
}
