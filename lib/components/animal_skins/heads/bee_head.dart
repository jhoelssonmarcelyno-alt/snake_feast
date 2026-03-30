import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors;
import 'head_painter.dart';

class BeeHead extends HeadPainter {
  static final BeeHead _i = BeeHead._();
  BeeHead._();
  factory BeeHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {}

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawCircle(Offset.zero, r*.9, Paint()..color = body);
    for (int i = -1; i <= 1; i++) {
      canvas.drawRect(Rect.fromCenter(center: Offset(0, i*r*.28), width: r*1.8, height: r*.16), Paint()..color = Colors.black.withValues(alpha: 0.5));
    }
    canvas.drawCircle(Offset(r*.4,-r*.38), r*.25, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(r*.4,r*.38), r*.25, Paint()..color = Colors.black);
    final ant = Paint()..color = Colors.black..strokeWidth = r*.07..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(r*.1,-r*.7), Offset(-r*.1,-r*1.05), ant);
    canvas.drawLine(Offset(r*.1,r*.7), Offset(-r*.1,r*1.05), ant);
  }
}
