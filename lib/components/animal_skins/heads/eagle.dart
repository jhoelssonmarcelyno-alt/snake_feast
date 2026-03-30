// lib/components/animal_skins/heads/eagle.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, RadialGradient, Alignment;
import '../utils.dart';

void eagleBack(Canvas canvas, double hr) {
  // Penas da crista — leque no topo da cabeça
  final featherPaint = Paint()
    ..strokeCap   = StrokeCap.round
    ..style       = PaintingStyle.stroke;

  const colors = [Color(0xFF4E2800), Color(0xFF7B4100), Color(0xFFA0522D)];
  const widths = [0.18, 0.15, 0.12];
  const count  = 9;
  for (int ring = 0; ring < 3; ring++) {
    featherPaint.color       = colors[ring];
    featherPaint.strokeWidth = hr * widths[ring];
    for (int i = 0; i < count; i++) {
      // Concentradas no arco superior (pi*0.8 a pi*2.2)
      final a    = pi * 0.9 + (i / (count - 1)) * pi * 1.2 - ring * 0.08;
      final dist = hr * (0.95 + ring * 0.18);
      final len  = hr * (0.55 - ring * 0.10);
      canvas.drawLine(
        Offset(cos(a) * dist * 0.7, sin(a) * dist * 0.7),
        Offset(cos(a) * (dist + len), sin(a) * (dist + len)),
        featherPaint,
      );
    }
  }
}

void eagleFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  // ── Cabeça branca (águia careca) ─────────────────────────────────────────
  final hlShader = RadialGradient(
    center: const Alignment(-0.4, -0.45),
    radius: 0.65,
    colors: [Colors.white.withValues(alpha: 0.55), Colors.white.withValues(alpha: 0.0)],
  ).createShader(Rect.fromCenter(center: Offset.zero, width: hr * 2.0, height: hr * 1.85));

  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.08, 0), width: hr * 2.0, height: hr * 1.85),
    Paint()..color = Colors.white,
  );
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.08, 0), width: hr * 2.0, height: hr * 1.85),
    Paint()..shader = hlShader,
  );

  // Mancha marrom no topo da cabeça
  canvas.drawOval(
    Rect.fromCenter(center: Offset(-hr * 0.15, -hr * 0.45), width: hr * 1.1, height: hr * 0.65),
    Paint()..color = body.withValues(alpha: 0.75),
  );

  // ── Olhos ferozes ─────────────────────────────────────────────────────────
  for (final s in [-1.0, 1.0]) {
    drawEye(canvas, Offset(hr * 0.08, s * hr * 0.50), hr * 0.28,
        irisColor: const Color(0xFFFFD600));
    // Sobrancelha proeminente — traço grosso diagonal
    canvas.drawLine(
      Offset(-hr * 0.10, s * hr * 0.26),
      Offset( hr * 0.28, s * hr * 0.20),
      Paint()
        ..color       = dark.withValues(alpha: 0.80)
        ..strokeWidth = hr * 0.13
        ..strokeCap   = StrokeCap.round,
    );
  }

  // ── Bico curvado (amarelo) ────────────────────────────────────────────────
  // Maxilar superior
  canvas.drawPath(
    Path()
      ..moveTo(hr * 0.40, -hr * 0.14)
      ..quadraticBezierTo(hr * 1.10, -hr * 0.05, hr * 1.18, hr * 0.20)
      ..quadraticBezierTo(hr * 1.05,  hr * 0.28, hr * 0.85, hr * 0.22)
      ..quadraticBezierTo(hr * 0.60,  hr * 0.10, hr * 0.40, -hr * 0.14)
      ..close(),
    Paint()..color = const Color(0xFFFFB300),
  );
  // Narina
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.56, -hr * 0.04), width: hr * 0.14, height: hr * 0.09),
    Paint()..color = const Color(0xFF7B5800).withValues(alpha: 0.55),
  );
  // Linha da boca
  canvas.drawLine(
    Offset(hr * 0.42,  hr * 0.04),
    Offset(hr * 0.98,  hr * 0.14),
    Paint()
      ..color       = const Color(0xFF7B5800)
      ..strokeWidth = hr * 0.06
      ..strokeCap   = StrokeCap.round,
  );
  // Brilho no bico
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.68, -hr * 0.06), width: hr * 0.12, height: hr * 0.07),
    Paint()..color = Colors.white.withValues(alpha: 0.55),
  );
}
