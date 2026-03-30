import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors, Path;
import 'head_painter.dart';

class DragonHead extends HeadPainter {
  static final DragonHead _i = DragonHead._();
  DragonHead._();
  factory DragonHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {
    final p = Paint()..color = dark;
    canvas.drawPath(Path()..moveTo(-r*.6,-r*.7)..lineTo(-r*.3,-r*1.2)..lineTo(0,-r*.7)..close(), p);
    canvas.drawPath(Path()..moveTo(r*.6,-r*.7)..lineTo(r*.3,-r*1.2)..lineTo(0,-r*.7)..close(), p);
  }

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r*2.2, height: r*1.8), Paint()..color = body);
    for (final ey in [-r*.45, r*.45]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(r*.38,ey), width: r*.22, height: r*.28), Paint()..color = Colors.yellow);
      canvas.drawOval(Rect.fromCenter(center: Offset(r*.4,ey), width: r*.1, height: r*.2), Paint()..color = Colors.black);
    }
    canvas.drawOval(Rect.fromCenter(center: Offset(r*.7,0), width: r*.7, height: r*.45), Paint()..color = dark);
  }
}
