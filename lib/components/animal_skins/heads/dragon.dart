// lib/components/animal_skins/heads/dragon.dart
import 'dart:math';
import 'dart:ui';
import '../utils.dart';

void dragonBack(Canvas canvas, double hr) {
  final hornP = Paint()
    ..color = const Color(0xFFFFD700)
    ..strokeWidth = hr * 0.32
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (final s in [-1.0, 1.0]) {
    canvas.drawPath(
        Path()
          ..moveTo( hr * 0.0,  s * hr * 1.05)
          ..cubicTo(hr * 0.22, s * hr * 1.65,
                   -hr * 0.50, s * hr * 2.20,
                   -hr * 0.28, s * hr * 2.75),
        hornP);
    canvas.drawCircle(Offset(-hr * 0.28, s * hr * 2.75), hr * 0.18,
        Paint()..color = const Color(0xFFFFE57F));
  }
  final crestP = Paint()..color = const Color(0xFFFF1744);
  for (int i = 0; i < 5; i++) {
    final x = -hr * 0.35 + i * hr * 0.175;
    final h = hr * (0.45 + (i == 2 ? 0.40 : (i == 1 || i == 3) ? 0.22 : 0.0));
    canvas.drawPath(
        Path()
          ..moveTo(x,             -hr * 1.05)
          ..lineTo(x - hr * 0.09, -hr * 1.05 - h)
          ..lineTo(x + hr * 0.09, -hr * 1.05)
          ..close(),
        crestP);
  }
}

void dragonFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  for (final s in [-1.0, 1.0]) {
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hr * 0.78, s * hr * 0.16),
            width: hr * 0.22, height: hr * 0.15),
        Paint()..color = const Color(0xFF000000).withValues(alpha: 0.85));
    drawEye(canvas, Offset(hr * 0.18, s * hr * 0.44), hr * 0.30,
        irisColor: const Color(0xFFFF6D00), slitPupil: true);
    canvas.drawLine(
        Offset(hr * 0.02, s * hr * 0.22),
        Offset(hr * 0.38, s * hr * 0.18),
        Paint()
          ..color = const Color(0xFFB71C1C)
          ..strokeWidth = hr * 0.18
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
  }
  final flame = sin(t * 7) * 0.42 + 0.58;
  canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hr * (0.88 + flame * 0.32), 0),
          width: hr * (0.60 * flame), height: hr * (0.38 * flame)),
      Paint()..color = const Color(0xFFFF6D00).withValues(alpha: 0.88));
  canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hr * (0.92 + flame * 0.32), 0),
          width: hr * (0.32 * flame), height: hr * (0.20 * flame)),
      Paint()..color = const Color(0xFFFFFF00).withValues(alpha: 0.82));
}
