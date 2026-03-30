import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors;
import 'head_painter.dart';

class LionHead extends HeadPainter {
  static final LionHead _i = LionHead._();
  LionHead._();
  factory LionHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {
    final mane = Paint()..color = const Color(0xFFB85C1A);
    for (int i = 0; i < 12; i++) {
      final a = i * pi / 6;
      canvas.drawOval(Rect.fromCenter(center: Offset(cos(a)*r*1.1, sin(a)*r*1.0-r*.3), width: r*.35, height: r*.5), mane);
    }
  }

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r*2.0, height: r*1.8), Paint()..color = body);
    for (final ey in [-r*.45, r*.45]) {
      canvas.drawCircle(Offset(r*.35, ey), r*.2, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(r*.38, ey), r*.12, Paint()..color = Colors.black);
    }
    canvas.drawCircle(Offset(r*.6,0), r*.15, Paint()..color = const Color(0xFFAA5A2A));
  }
}
