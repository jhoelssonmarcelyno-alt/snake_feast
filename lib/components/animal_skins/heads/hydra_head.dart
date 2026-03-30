import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors, Path;
import 'head_painter.dart';

class HydraHead extends HeadPainter {
  static final HydraHead _i = HydraHead._();
  HydraHead._();
  factory HydraHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {
    final p = Paint()..color = dark;
    for (final dx in [-r*.5, 0.0, r*.5]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(dx,-r*.9), width: r*.35, height: r*.6), p);
    }
  }

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r*2.0, height: r*1.7), Paint()..color = body);
    for (final ey in [-r*.45, r*.45]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(r*.38,ey), width: r*.22, height: r*.28), Paint()..color = Colors.yellow);
      canvas.drawOval(Rect.fromCenter(center: Offset(r*.4,ey), width: r*.1, height: r*.2), Paint()..color = Colors.black);
    }
    canvas.drawOval(Rect.fromCenter(center: Offset(r*.7,0), width: r*.65, height: r*.4), Paint()..color = dark);
  }
}
