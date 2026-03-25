// lib/components/animal_skins/tails/tails.dart
// Dispatcher de caudas — chama a implementação correta por skinId.
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors;
import '../utils.dart';

void renderAnimalTail(
    Canvas canvas, String skinId, Offset tailPos, double angle, double r) {
  canvas.save();
  canvas.translate(tailPos.dx, tailPos.dy);
  canvas.rotate(angle);
  switch (skinId) {
    case 'gato':          _tailCat(canvas, r);          break;
    case 'cachorro':      _tailDog(canvas, r);          break;
    case 'leao':          _tailLion(canvas, r);         break;
    case 'vaca':          _tailCow(canvas, r);          break;
    case 'coelho':        _tailRabbit(canvas, r);       break;
    case 'peixe':         _tailFish(canvas, r);         break;
    case 'dragao_animal': _tailDragonAnimal(canvas, r); break;
    case 'raposa':        _tailFox(canvas, r);          break;
    default:              _tailDefault(canvas, r);
  }
  canvas.restore();
}

void _tailCat(Canvas canvas, double r) {
  final p = Paint()
    ..color = const Color(0xFFFF9800)
    ..strokeWidth = r * 0.75
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..cubicTo(-r * 1.5, -r * 0.5, -r * 2.5, r * 0.8, -r * 1.2, r * 1.8)
        ..cubicTo(-r * 0.2, r * 2.6, r * 0.8, r * 2.2, r * 0.5, r * 1.4),
      p);
  canvas.drawCircle(Offset(r * 0.5, r * 1.4), r * 0.45,
      Paint()..color = const Color(0xFFFF9800));
  final stripe = Paint()
    ..color = const Color(0xFFE65100)
    ..strokeWidth = r * 0.18
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawLine(Offset(-r * 0.4, r * 0.5), Offset(-r * 0.8, r * 0.6), stripe);
  canvas.drawLine(Offset(-r * 0.8, r * 1.0), Offset(-r * 1.2, r * 1.1), stripe);
}

void _tailDog(Canvas canvas, double r) {
  final base = Paint()
    ..color = const Color(0xFFD4A35A)
    ..strokeWidth = r * 0.85
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..cubicTo(-r * 0.4, -r * 1.0, r * 0.6, -r * 2.0, r * 0.2, -r * 2.8),
      base);
  final fur = Paint()
    ..color = const Color(0xFFEFD5A0)
    ..strokeWidth = r * 0.28
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (int i = 0; i < 6; i++) {
    final a = -pi / 2 + (i - 2.5) * 0.28;
    canvas.drawLine(
        Offset(r * 0.2 + cos(a) * r * 0.2,  -r * 2.8 + sin(a) * r * 0.2),
        Offset(r * 0.2 + cos(a) * r * 0.80, -r * 2.8 + sin(a) * r * 0.80),
        fur);
  }
}

void _tailLion(Canvas canvas, double r) {
  final base = Paint()
    ..color = const Color(0xFFC8971F)
    ..strokeWidth = r * 0.65
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawLine(Offset.zero, Offset(-r * 2.2, r * 0.4), base);
  final pompom = Paint()..color = const Color(0xFF6D3E00);
  for (int i = 0; i < 10; i++) {
    final a = (i / 10) * pi * 2;
    canvas.drawCircle(
        Offset(-r * 2.2 + cos(a) * r * 0.60, r * 0.4 + sin(a) * r * 0.60),
        r * 0.40, pompom);
  }
  canvas.drawCircle(Offset(-r * 2.2, r * 0.4), r * 0.45, pompom);
}

void _tailCow(Canvas canvas, double r) {
  final base = Paint()
    ..color = const Color(0xFFEEEEEE)
    ..strokeWidth = r * 0.50
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..cubicTo(-r * 1.0, r * 0.3, -r * 1.8, -r * 0.5, -r * 2.2, r * 0.8),
      base);
  final tuftP = Paint()
    ..color = const Color(0xFF212121)
    ..strokeWidth = r * 0.24
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (int i = 0; i < 5; i++) {
    final a = pi + (i - 2) * 0.38;
    canvas.drawLine(
        Offset(-r * 2.2, r * 0.8),
        Offset(-r * 2.2 + cos(a) * r * 0.60, r * 0.8 + sin(a) * r * 0.60),
        tuftP);
  }
}

void _tailRabbit(Canvas canvas, double r) {
  canvas.drawCircle(Offset(-r * 0.5, 0), r * 0.80, Paint()..color = Colors.white);
  canvas.drawCircle(
      Offset(-r * 0.5, 0), r * 0.80,
      Paint()
        ..color = const Color(0xFFE0E0E0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.14);
}

void _tailFish(Canvas canvas, double r) {
  final p = Paint()..color = const Color(0xFF29B6F6);
  canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(-r * 2.0, -r * 1.3)
        ..lineTo(-r * 1.1, 0)
        ..close(),
      p);
  canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(-r * 2.0, r * 1.3)
        ..lineTo(-r * 1.1, 0)
        ..close(),
      p);
  final stripe = Paint()
    ..color = Colors.white.withValues(alpha: 0.45)
    ..strokeWidth = r * 0.13
    ..style = PaintingStyle.stroke;
  canvas.drawLine(Offset(-r * 0.5, -r * 0.5), Offset(-r * 1.6, -r * 1.1), stripe);
  canvas.drawLine(Offset(-r * 0.5,  r * 0.5), Offset(-r * 1.6,  r * 1.1), stripe);
}

void _tailDragonAnimal(Canvas canvas, double r) {
  final base = Paint()
    ..color = const Color(0xFFFF1744)
    ..strokeWidth = r * 0.75
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..cubicTo(-r * 1.2, -r * 0.3, -r * 2.2, r * 0.5, -r * 2.8, r * 0.2),
      base);
  final spine = Paint()..color = const Color(0xFFFFD700);
  for (int i = 0; i < 4; i++) {
    final t = (i + 1) / 5.0;
    final cx = -r * 2.8 * t;
    final cy = r * 0.2 * t - r * 0.35 * t;
    canvas.drawPath(
        Path()
          ..moveTo(cx, cy)
          ..lineTo(cx - r * 0.12, cy - r * 0.7)
          ..lineTo(cx + r * 0.12, cy)
          ..close(),
        spine);
  }
  canvas.drawPath(
      Path()
        ..moveTo(-r * 2.8,  r * 0.2)
        ..lineTo(-r * 3.5, -r * 0.2)
        ..lineTo(-r * 3.1,  r * 0.6)
        ..close(),
      Paint()..color = const Color(0xFFFF1744));
}

void _tailFox(Canvas canvas, double r) {
  final base = Paint()
    ..color = const Color(0xFFFF6D00)
    ..strokeWidth = r * 1.10
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..cubicTo(-r * 1.0, -r * 0.8, -r * 2.2, -r * 0.2, -r * 2.5, r * 0.8),
      base);
  canvas.drawCircle(Offset(-r * 2.5, r * 0.8), r * 0.70, Paint()..color = Colors.white);
  final fur = Paint()
    ..color = const Color(0xFFFF8F00)
    ..strokeWidth = r * 0.20
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawLine(Offset(0, 0),          Offset(-r * 1.2, -r * 0.5), fur);
  canvas.drawLine(Offset(-r * 0.5, -r * 0.3), Offset(-r * 1.8, -r * 0.1), fur);
}

void _tailDefault(Canvas canvas, double r) {
  canvas.drawPath(
      Path()
        ..moveTo(0, -r * 0.5)
        ..lineTo(-r * 1.6, 0)
        ..lineTo(0,  r * 0.5)
        ..close(),
      Paint()..color = const Color(0xFF00E5FF));
}
