import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors;
import 'head_painter.dart';

class ElephantHead extends HeadPainter {
  static final ElephantHead _i = ElephantHead._();
  ElephantHead._();
  factory ElephantHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {
    final p = Paint()..color = dark;
    canvas.drawOval(Rect.fromCenter(center: Offset(-r*.8,0), width: r*.5, height: r*1.1), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(r*.8,0), width: r*.5, height: r*1.1), p);
  }

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r*2.4, height: r*2.0), Paint()..color = body);
    for (final ey in [-r*.55, r*.55]) {
      canvas.drawCircle(Offset(r*.3, ey), r*.22, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(r*.32, ey), r*.1, Paint()..color = Colors.black);
    }
    canvas.drawOval(Rect.fromCenter(center: Offset(r*.85,0), width: r*.5, height: r*.8), Paint()..color = dark);
  }
}
