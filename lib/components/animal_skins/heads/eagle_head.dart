import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors, Path;
import 'head_painter.dart';

class EagleHead extends HeadPainter {
  static final EagleHead _i = EagleHead._();
  EagleHead._();
  factory EagleHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {}

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r*1.8, height: r*1.5), Paint()..color = body);
    final brow = Paint()..color = Colors.black..strokeWidth = r*.12..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCenter(center: Offset(r*.2,-r*.35), width: r*.7, height: r*.6), 0.2, 2.8, false, brow);
    canvas.drawArc(Rect.fromCenter(center: Offset(r*.2,r*.35), width: r*.7, height: r*.6), 0.2, 2.8, false, brow);
    for (final ey in [-r*.42, r*.42]) {
      canvas.drawCircle(Offset(r*.32, ey), r*.18, Paint()..color = Colors.yellow);
      canvas.drawCircle(Offset(r*.35, ey), r*.08, Paint()..color = Colors.black);
    }
    canvas.drawPath(Path()..moveTo(r*.7,-r*.08)..lineTo(r*.88,0)..lineTo(r*.7,r*.08)..close(), Paint()..color = const Color(0xFFE65100));
  }
}
