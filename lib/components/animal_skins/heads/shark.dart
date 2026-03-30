// lib/components/animal_skins/heads/shark.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, RadialGradient, Alignment;
import '../utils.dart';

void sharkBack(Canvas canvas, double hr) {
  // Nadadeira dorsal no topo
  canvas.drawPath(
    Path()
      ..moveTo(-hr * 0.20, -hr * 0.82)
      ..lineTo( hr * 0.10, -hr * 1.70)
      ..lineTo( hr * 0.55, -hr * 0.82)
      ..close(),
    Paint()..color = const Color(0xFF546E7A),
  );
  // Borda mais clara na nadadeira
  canvas.drawPath(
    Path()
      ..moveTo(-hr * 0.14, -hr * 0.84)
      ..lineTo( hr * 0.08, -hr * 1.55)
      ..lineTo( hr * 0.26, -hr * 0.84)
      ..close(),
    Paint()..color = const Color(0xFF78909C).withValues(alpha: 0.55),
  );
}

void sharkFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  // ── Cabeça aerodinâmica ────────────────────────────────────────────────────
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.10, 0), width: hr * 2.20, height: hr * 1.75),
    Paint()..color = body,
  );
  // Barriga mais clara
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.24, hr * 0.22), width: hr * 1.55, height: hr * 0.80),
    Paint()..color = Colors.white.withValues(alpha: 0.70),
  );
  // Highlight 3D
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.10, 0), width: hr * 2.20, height: hr * 1.75),
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.40, -0.50),
        radius: 0.55,
        colors: [Colors.white.withValues(alpha: 0.32), Colors.white.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCenter(center: Offset(hr * 0.10, 0), width: hr * 2.20, height: hr * 1.75)),
  );

  // ── Linhas de guelra ──────────────────────────────────────────────────────
  final gillPaint = Paint()
    ..color       = dark.withValues(alpha: 0.35)
    ..strokeWidth = hr * 0.055
    ..strokeCap   = StrokeCap.round
    ..style       = PaintingStyle.stroke;
  for (int i = 0; i < 3; i++) {
    final x = -hr * 0.28 + i * hr * 0.24;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(x, hr * 0.10), width: hr * 0.36, height: hr * 0.72),
      -pi * 0.45, pi * 0.90,
      false, gillPaint,
    );
  }

  // ── Olho preto frio ───────────────────────────────────────────────────────
  for (final s in [-1.0, 1.0]) {
    // Fundo branco
    canvas.drawCircle(Offset(hr * 0.22, s * hr * 0.42), hr * 0.26, Paint()..color = Colors.white);
    // Íris preta
    canvas.drawCircle(Offset(hr * 0.22, s * hr * 0.42), hr * 0.20, Paint()..color = Colors.black);
    // Reflexo azulado
    canvas.drawCircle(
      Offset(hr * 0.14, s * (hr * 0.42 - hr * 0.08)), hr * 0.07,
      Paint()..color = Colors.white.withValues(alpha: 0.75),
    );
    // Borda
    canvas.drawCircle(
      Offset(hr * 0.22, s * hr * 0.42), hr * 0.26,
      Paint()
        ..color       = dark.withValues(alpha: 0.40)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = hr * 0.07,
    );
  }

  // ── Boca enorme com dentes ────────────────────────────────────────────────
  // Gengiva
  canvas.drawPath(
    Path()
      ..moveTo(hr * 0.10,  hr * 0.15)
      ..quadraticBezierTo(hr * 0.68,  hr * 0.18, hr * 1.12,  hr * 0.12)
      ..quadraticBezierTo(hr * 0.68,  hr * 0.60, hr * 0.10,  hr * 0.55)
      ..close(),
    Paint()..color = const Color(0xFFE57373),
  );

  // Dentes superiores (triângulos)
  final topTooth = Paint()..color = Colors.white;
  for (int i = 0; i < 5; i++) {
    final tx = hr * 0.22 + i * hr * 0.18;
    canvas.drawPath(
      Path()
        ..moveTo(tx,             hr * 0.16)
        ..lineTo(tx + hr * 0.07, hr * 0.34)
        ..lineTo(tx + hr * 0.14, hr * 0.16)
        ..close(),
      topTooth,
    );
  }
  // Dentes inferiores (menores, intercalados)
  for (int i = 0; i < 4; i++) {
    final tx = hr * 0.30 + i * hr * 0.18;
    canvas.drawPath(
      Path()
        ..moveTo(tx,             hr * 0.54)
        ..lineTo(tx + hr * 0.06, hr * 0.38)
        ..lineTo(tx + hr * 0.12, hr * 0.54)
        ..close(),
      topTooth,
    );
  }
  // Linha da boca
  canvas.drawLine(
    Offset(hr * 0.10, hr * 0.35),
    Offset(hr * 1.12, hr * 0.32),
    Paint()
      ..color       = dark.withValues(alpha: 0.40)
      ..strokeWidth = hr * 0.04,
  );
}
