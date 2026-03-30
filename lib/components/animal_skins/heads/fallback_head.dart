import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors;
import 'head_painter.dart';

/// Cabeca generica usada quando o headType ainda nao tem implementacao.
/// Nunca deixa a cobra invisivel - renderiza uma cabeca simples de cobra.
class FallbackHead extends HeadPainter {
  static final FallbackHead _instance = FallbackHead._();
  FallbackHead._();
  factory FallbackHead() => _instance;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {}

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 1.8, height: r * 1.5),
      Paint()..color = body,
    );
    for (final ey in [-r * 0.4, r * 0.4]) {
      canvas.drawCircle(
          Offset(r * 0.4, ey), r * 0.18, Paint()..color = Colors.white);
      canvas.drawCircle(
          Offset(r * 0.42, ey), r * 0.09, Paint()..color = Colors.black);
    }
    final tongue = Paint()
      ..color = const Color(0xFFE53935)
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(r * 0.82, 0), Offset(r * 1.05, -r * 0.12), tongue);
    canvas.drawLine(Offset(r * 0.82, 0), Offset(r * 1.05, r * 0.12), tongue);
  }
}
