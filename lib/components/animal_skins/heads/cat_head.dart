import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors, Path;
import 'head_painter.dart';

class CatHead extends HeadPainter {
  static final CatHead _i = CatHead._();
  CatHead._();
  factory CatHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {
    final p = Paint()..color = dark;
    canvas.drawPath(Path()..moveTo(-r*.6,-r*.7)..lineTo(-r*.3,-r*1.0)..lineTo(0,-r*.7)..close(), p);
    canvas.drawPath(Path()..moveTo(r*.6,-r*.7)..lineTo(r*.3,-r*1.0)..lineTo(0,-r*.7)..close(), p);
  }

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r*1.8, height: r*1.6), Paint()..color = body);
    for (final ey in [-r*.45, r*.45]) {
      canvas.drawCircle(Offset(r*.35, ey), r*.22, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(r*.38, ey), r*.12, Paint()..color = Colors.black);
    }
    canvas.drawCircle(Offset(r*.55, 0), r*.12, Paint()..color = const Color(0xFFFFA0A0));
  }
}
