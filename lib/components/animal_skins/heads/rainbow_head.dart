import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors, HSVColor;
import 'head_painter.dart';

class RainbowHead extends HeadPainter {
  static final RainbowHead _i = RainbowHead._();
  RainbowHead._();
  factory RainbowHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {}

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    for (int i = 0; i < 12; i++) {
      final hue = ((i / 12) + t * 0.5) % 1.0;
      final c = HSVColor.fromAHSV(0.7, hue * 360, 1, 1).toColor();
      canvas.drawCircle(
        Offset(cos(i * pi / 6) * r * 1.15, sin(i * pi / 6) * r * 1.15),
        r * 0.15, Paint()..color = c,
      );
    }
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r*1.9, height: r*1.6), Paint()..color = body);
    for (final ey in [-r*.42, r*.42]) {
      final eyeHue = (t * 0.8 + ey.abs() * 0.01) % 1.0;
      canvas.drawCircle(Offset(r*.38, ey), r*.2, Paint()..color = HSVColor.fromAHSV(1, eyeHue*360, 0.8, 1).toColor());
      canvas.drawCircle(Offset(r*.4, ey), r*.1, Paint()..color = Colors.black);
    }
  }
}
