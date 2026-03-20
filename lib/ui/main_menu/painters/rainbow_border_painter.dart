import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class RainbowBorderPainter extends CustomPainter {
  final double t;
  RainbowBorderPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    const double r = 34.0;
    final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(r));
    final List<Color> colors = [
      const Color(0xFF00E5FF), const Color(0xFF69F0AE),
      const Color(0xFFFFD600), const Color(0xFFFF5252),
      const Color(0xFFE040FB), const Color(0xFF00E5FF),
    ];
    final gradient = ui.Gradient.sweep(
      Offset(size.width / 2, size.height / 2), colors,
      List.generate(colors.length, (i) => i / (colors.length - 1)),
      ui.TileMode.clamp, t * pi * 2, t * pi * 2 + pi * 2,
    );
    canvas.drawRRect(rect, Paint()
      ..shader = gradient ..strokeWidth = 2.5 ..style = PaintingStyle.stroke);
  }
  @override
  bool shouldRepaint(covariant RainbowBorderPainter old) => old.t != t;
}
