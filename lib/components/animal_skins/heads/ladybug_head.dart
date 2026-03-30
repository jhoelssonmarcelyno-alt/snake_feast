import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors;
import 'head_painter.dart';

class LadybugHead extends HeadPainter {
  static final LadybugHead _i = LadybugHead._();
  LadybugHead._();
  factory LadybugHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {}

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawCircle(Offset.zero, r*.95, Paint()..color = body);
    for (final off in [Offset(r*.3,-r*.4), Offset(r*.3,r*.4), Offset(-r*.1,0)]) {
      canvas.drawCircle(off, r*.15, Paint()..color = Colors.black);
    }
    for (final ey in [-r*.45, r*.45]) {
      canvas.drawCircle(Offset(r*.55, ey), r*.15, Paint()..color = Colors.black);
    }
  }
}
