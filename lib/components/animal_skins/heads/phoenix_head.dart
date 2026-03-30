import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors, Path;
import 'head_painter.dart';

class PhoenixHead extends HeadPainter {
  static final PhoenixHead _i = PhoenixHead._();
  PhoenixHead._();
  factory PhoenixHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {
    final flame = Paint()..color = const Color(0xFFFF6B00);
    for (int i = -1; i <= 1; i++) {
      canvas.drawPath(Path()..moveTo(i*r*.3,-r*.7)..lineTo(i*r*.15,-r*1.15)..lineTo(i*r*.45,-r*.7)..close(), flame);
    }
  }

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r*1.9, height: r*1.6), Paint()..color = body);
    for (final ey in [-r*.42, r*.42]) {
      canvas.drawCircle(Offset(r*.35, ey), r*.2, Paint()..color = Colors.yellow);
      canvas.drawCircle(Offset(r*.37, ey), r*.1, Paint()..color = Colors.black);
    }
    canvas.drawPath(Path()..moveTo(r*.7,-r*.08)..lineTo(r*.88,0)..lineTo(r*.7,r*.08)..close(), Paint()..color = const Color(0xFFE65100));
  }
}
