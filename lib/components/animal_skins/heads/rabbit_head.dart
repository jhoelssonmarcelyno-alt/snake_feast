import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors;
import 'head_painter.dart';

class RabbitHead extends HeadPainter {
  static final RabbitHead _i = RabbitHead._();
  RabbitHead._();
  factory RabbitHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {
    final p = Paint()..color = dark;
    canvas.drawOval(Rect.fromCenter(center: Offset(-r*.5,-r*1.0), width: r*.6, height: r*1.2), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(r*.5,-r*1.0), width: r*.6, height: r*1.2), p);
  }

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r*1.6, height: r*1.8), Paint()..color = body);
    for (final ey in [-r*.45, r*.45]) {
      canvas.drawCircle(Offset(r*.35, ey), r*.2, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(r*.38, ey), r*.12, Paint()..color = Colors.black);
    }
    canvas.drawCircle(Offset(r*.55,0), r*.1, Paint()..color = const Color(0xFFFFA0A0));
  }
}
