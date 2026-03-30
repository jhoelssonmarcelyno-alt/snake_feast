// lib/components/animal_skins/heads/parrot.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, RadialGradient, Alignment;
import '../utils.dart';

void parrotBack(Canvas canvas, double hr) {
  // Crista colorida — penas curtas em arco
  const crestColors = [
    Color(0xFFFF1744), // vermelho
    Color(0xFFFF6D00), // laranja
    Color(0xFFFFD600), // amarelo
  ];
  final paint = Paint()
    ..strokeCap   = StrokeCap.round
    ..style       = PaintingStyle.stroke;

  for (int ring = 0; ring < 3; ring++) {
    paint.color       = crestColors[ring];
    paint.strokeWidth = hr * (0.22 - ring * 0.04);
    final count = 7 - ring;
    for (int i = 0; i < count; i++) {
      final a    = pi * 1.05 + (i / (count - 1)) * pi * 0.90 + ring * 0.06;
      final base = hr * (0.88 + ring * 0.15);
      final len  = hr * (0.50 - ring * 0.08);
      canvas.drawLine(
        Offset(cos(a) * base * 0.68, sin(a) * base * 0.68),
        Offset(cos(a) * (base + len), sin(a) * (base + len)),
        paint,
      );
    }
  }
}

void parrotFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  // ── Cabeça ────────────────────────────────────────────────────────────────
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.06, 0), width: hr * 2.0, height: hr * 1.90),
    Paint()..color = body,
  );
  // Highlight
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.06, 0), width: hr * 2.0, height: hr * 1.90),
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.45, -0.50),
        radius: 0.60,
        colors: [Colors.white.withValues(alpha: 0.48), Colors.white.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCenter(center: Offset(hr * 0.06, 0), width: hr * 2.0, height: hr * 1.90)),
  );

  // Mancha branca na bochecha
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.55, hr * 0.28), width: hr * 0.70, height: hr * 0.52),
    Paint()..color = Colors.white.withValues(alpha: 0.80),
  );
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.55, -hr * 0.28), width: hr * 0.70, height: hr * 0.52),
    Paint()..color = Colors.white.withValues(alpha: 0.80),
  );

  // ── Olhos redondos vivos ───────────────────────────────────────────────────
  for (final s in [-1.0, 1.0]) {
    drawEye(canvas, Offset(hr * 0.08, s * hr * 0.50), hr * 0.27,
        irisColor: const Color(0xFF000000));
    // Aro amarelo ao redor do olho
    canvas.drawCircle(
      Offset(hr * 0.08, s * hr * 0.50), hr * 0.32,
      Paint()
        ..color       = const Color(0xFFFFD600)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = hr * 0.08,
    );
  }

  // ── Bico curvo cinza ──────────────────────────────────────────────────────
  // Maxilar superior (grande e curvo para baixo)
  canvas.drawPath(
    Path()
      ..moveTo(hr * 0.30, -hr * 0.18)
      ..quadraticBezierTo(hr * 1.05, -hr * 0.10, hr * 1.10,  hr * 0.12)
      ..quadraticBezierTo(hr * 0.95,  hr * 0.30, hr * 0.65,  hr * 0.18)
      ..quadraticBezierTo(hr * 0.44,  hr * 0.05, hr * 0.30, -hr * 0.18)
      ..close(),
    Paint()..color = const Color(0xFF607D8B),
  );
  // Maxilar inferior (menor)
  canvas.drawPath(
    Path()
      ..moveTo(hr * 0.48,  hr * 0.06)
      ..quadraticBezierTo(hr * 0.80,  hr * 0.16, hr * 0.82,  hr * 0.32)
      ..quadraticBezierTo(hr * 0.65,  hr * 0.38, hr * 0.48,  hr * 0.24)
      ..close(),
    Paint()..color = const Color(0xFF455A64),
  );
  // Brilho
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.62, -hr * 0.08), width: hr * 0.13, height: hr * 0.07),
    Paint()..color = Colors.white.withValues(alpha: 0.50),
  );
}
