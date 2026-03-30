import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors, Path;
import 'head_painter.dart';

class WolfHead extends HeadPainter {
  static final WolfHead _i = WolfHead._();
  WolfHead._();
  factory WolfHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {
    final p = Paint()..color = dark;
    canvas.drawPath(Path()..moveTo(-r*.55,-r*.65)..lineTo(-r*.3,-r*1.05)..lineTo(-r*.05,-r*.65)..close(), p);
    canvas.drawPath(Path()..moveTo(r*.55,-r*.65)..lineTo(r*.3,-r*1.05)..lineTo(r*.05,-r*.65)..close(), p);
  }

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r*2.0, height: r*1.7), Paint()..color = body);
    for (final ey in [-r*.45, r*.45]) {
      canvas.drawCircle(Offset(r*.35, ey), r*.22, Paint()..color = Colors.white);
      canvas.drawOval(Rect.fromCenter(center: Offset(r*.4,ey), width: r*.14, height: r*.22), Paint()..color = Colors.black);
    }
    canvas.drawOval(Rect.fromCenter(center: Offset(r*.65,0), width: r*.55, height: r*.4), Paint()..color = dark);
    canvas.drawCircle(Offset(r*.82,-r*.1), r*.1, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(r*.82,r*.1), r*.1, Paint()..color = Colors.black);
  }
}
