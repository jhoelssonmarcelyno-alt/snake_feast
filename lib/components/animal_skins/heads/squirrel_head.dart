import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors, Path;
import 'head_painter.dart';

class SquirrelHead extends HeadPainter {
  static final SquirrelHead _i = SquirrelHead._();
  SquirrelHead._();
  factory SquirrelHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {
    final p = Paint()..color = dark;
    canvas.drawPath(Path()..moveTo(-r*.5,-r*.6)..lineTo(-r*.25,-r*1.0)..lineTo(0,-r*.6)..close(), p);
    canvas.drawPath(Path()..moveTo(r*.5,-r*.6)..lineTo(r*.25,-r*1.0)..lineTo(0,-r*.6)..close(), p);
  }

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r*1.7, height: r*1.6), Paint()..color = body);
    for (final ey in [-r*.42, r*.42]) {
      canvas.drawCircle(Offset(r*.35, ey), r*.2, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(r*.37, ey), r*.1, Paint()..color = Colors.black);
    }
    canvas.drawCircle(Offset(r*.55,0), r*.12, Paint()..color = const Color(0xFFD4A27A));
  }
}
