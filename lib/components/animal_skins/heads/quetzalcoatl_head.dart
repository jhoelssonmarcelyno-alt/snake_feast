import 'dart:ui';
import 'package:flutter/material.dart' show Color;
import 'head_painter.dart';
import 'fallback_head.dart';

/// Cabeca de quetzalcoatl - usa FallbackHead ate ter arte propria.
/// Para dar arte exclusiva, substitua paintFront abaixo.
class QuetzalcoatlHead extends HeadPainter {
  static final QuetzalcoatlHead _i = QuetzalcoatlHead._();
  QuetzalcoatlHead._();
  factory QuetzalcoatlHead() => _i;

  final _fb = FallbackHead();

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) =>
      _fb.paintBack(canvas, r, body, dark);

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) =>
      _fb.paintFront(canvas, r, t, body, dark);
}
