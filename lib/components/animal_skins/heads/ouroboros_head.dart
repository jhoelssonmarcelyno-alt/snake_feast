import 'dart:ui';
import 'package:flutter/material.dart' show Color;
import 'head_painter.dart';
import 'fallback_head.dart';

/// Cabeca de ouroboros - usa FallbackHead ate ter arte propria.
/// Para dar arte exclusiva, substitua paintFront abaixo.
class OuroborosHead extends HeadPainter {
  static final OuroborosHead _i = OuroborosHead._();
  OuroborosHead._();
  factory OuroborosHead() => _i;

  final _fb = FallbackHead();

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) =>
      _fb.paintBack(canvas, r, body, dark);

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) =>
      _fb.paintFront(canvas, r, t, body, dark);
}
