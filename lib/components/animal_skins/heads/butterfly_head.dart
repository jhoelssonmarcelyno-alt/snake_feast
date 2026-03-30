import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors;
import 'head_painter.dart';

class ButterflyHead extends HeadPainter {
  static final ButterflyHead _i = ButterflyHead._();
  ButterflyHead._();
  factory ButterflyHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {}

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawCircle(Offset.zero, r*.75, Paint()..color = body);
    for (final ey in [-r*.35, r*.35]) {
      canvas.drawCircle(Offset(r*.4, ey), r*.18, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(r*.42, ey), r*.09, Paint()..color = Colors.black);
    }
    final ant = Paint()..color = dark..strokeWidth = r*.07..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-r*.1,-r*.6), Offset(-r*.3,-r*.95), ant);
    canvas.drawLine(Offset(-r*.1,r*.6), Offset(-r*.3,r*.95), ant);
  }
}
