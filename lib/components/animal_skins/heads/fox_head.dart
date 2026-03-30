import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors, Path;
import 'head_painter.dart';

class FoxHead extends HeadPainter {
  static final FoxHead _i = FoxHead._();
  FoxHead._();
  factory FoxHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {
    final p = Paint()..color = dark;
    canvas.drawPath(Path()..moveTo(-r*.5,-r*.7)..lineTo(-r*.2,-r*1.1)..lineTo(0.1,-r*.7)..close(), p);
    canvas.drawPath(Path()..moveTo(r*.5,-r*.7)..lineTo(r*.2,-r*1.1)..lineTo(-0.1,-r*.7)..close(), p);
  }

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawPath(Path()..moveTo(0,-r*.8)..lineTo(-r*.8,r*.5)..lineTo(r*.8,r*.5)..close(), Paint()..color = body);
    for (final ey in [-r*.45, r*.45]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(r*.4,ey), width: r*.25, height: r*.18), Paint()..color = Colors.white);
      canvas.drawOval(Rect.fromCenter(center: Offset(r*.42,ey), width: r*.12, height: r*.14), Paint()..color = Colors.black);
    }
    canvas.drawOval(Rect.fromCenter(center: Offset(r*.7,0), width: r*.5, height: r*.3), Paint()..color = dark);
    canvas.drawCircle(Offset(r*.85,0), r*.08, Paint()..color = Colors.black);
  }
}
