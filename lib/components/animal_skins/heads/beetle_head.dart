import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors;
import 'head_painter.dart';

class BeetleHead extends HeadPainter {
  static final BeetleHead _i = BeetleHead._();
  BeetleHead._();
  factory BeetleHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {}

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r*1.9, height: r*1.5), Paint()..color = body);
    canvas.drawLine(Offset.zero, Offset(r*.9,0), Paint()..color = dark..strokeWidth = r*.08);
    for (final ey in [-r*.42, r*.42]) {
      canvas.drawCircle(Offset(r*.3, ey), r*.18, Paint()..color = Colors.black);
    }
    canvas.drawLine(Offset(r*.7,0), Offset(r*1.05,0), Paint()..color = dark..strokeWidth = r*.1..strokeCap = StrokeCap.round);
  }
}
