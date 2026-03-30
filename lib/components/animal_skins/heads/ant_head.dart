import 'dart:ui';
import 'package:flutter/material.dart' show Color, Colors;
import 'head_painter.dart';

class AntHead extends HeadPainter {
  static final AntHead _i = AntHead._();
  AntHead._();
  factory AntHead() => _i;

  @override
  void paintBack(Canvas canvas, double r, Color body, Color dark) {}

  @override
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark) {
    canvas.drawCircle(Offset(r*.15,-r*.38), r*.38, Paint()..color = body);
    canvas.drawCircle(Offset(r*.15,r*.38), r*.38, Paint()..color = body);
    canvas.drawCircle(Offset(r*.28,-r*.38), r*.15, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(r*.28,r*.38), r*.15, Paint()..color = Colors.black);
    final ant = Paint()..color = dark..strokeWidth = r*.08..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(r*.1,-r*.6), Offset(r*.28,-r*.9), ant);
    canvas.drawLine(Offset(r*.1,r*.6), Offset(r*.28,r*.9), ant);
  }
}
