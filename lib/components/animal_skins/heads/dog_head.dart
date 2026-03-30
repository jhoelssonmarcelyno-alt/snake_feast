import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors;
import 'head_painter.dart';

class DogHead extends HeadPainter {
  static final DogHead _i = DogHead._();
  DogHead._();
  factory DogHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {
    final p = Paint()..color = dark;
    canvas.drawOval(Rect.fromCenter(center: Offset(-r*.55,-r*.55), width: r*.7, height: r*.9), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(r*.55,-r*.55), width: r*.7, height: r*.9), p);
  }

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r*1.9, height: r*1.7), Paint()..color = body);
    for (final ey in [-r*.45, r*.45]) {
      canvas.drawCircle(Offset(r*.35, ey), r*.2, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(r*.38, ey), r*.1, Paint()..color = Colors.black);
    }
    canvas.drawOval(Rect.fromCenter(center: Offset(r*.65,0), width: r*.5, height: r*.35), Paint()..color = dark);
    canvas.drawCircle(Offset(r*.8,-r*.08), r*.08, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(r*.8,r*.08), r*.08, Paint()..color = Colors.black);
  }
}
