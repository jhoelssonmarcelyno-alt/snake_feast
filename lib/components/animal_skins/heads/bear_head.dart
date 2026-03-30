import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors;
import 'head_painter.dart';

class BearHead extends HeadPainter {
  static final BearHead _i = BearHead._();
  BearHead._();
  factory BearHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {
    final p = Paint()..color = dark;
    canvas.drawCircle(Offset(-r*.65,-r*.7), r*.32, p);
    canvas.drawCircle(Offset(r*.65,-r*.7), r*.32, p);
  }

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r*2.2, height: r*1.9), Paint()..color = body);
    for (final ey in [-r*.5, r*.5]) {
      canvas.drawCircle(Offset(r*.4, ey), r*.24, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(r*.44, ey), r*.12, Paint()..color = Colors.black);
    }
    canvas.drawOval(Rect.fromCenter(center: Offset(r*.7,0), width: r*.65, height: r*.45), Paint()..color = dark);
    canvas.drawCircle(Offset(r*.88,-r*.12), r*.12, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(r*.88,r*.12), r*.12, Paint()..color = Colors.black);
  }
}
