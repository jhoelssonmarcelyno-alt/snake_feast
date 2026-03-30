// lib/components/animal_skins/heads/bear.dart
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, RadialGradient, Alignment;
import '../utils.dart';

void bearBack(Canvas canvas, double hr) {
  // Duas orelhas arredondadas no topo
  for (final s in [-1.0, 1.0]) {
    // Orelha externa
    canvas.drawCircle(
      Offset(s * hr * 0.60, -hr * 0.88), hr * 0.36,
      Paint()..color = const Color(0xFF5D3A1A),
    );
    // Orelha interna (rosada)
    canvas.drawCircle(
      Offset(s * hr * 0.60, -hr * 0.88), hr * 0.22,
      Paint()..color = const Color(0xFFD2906A),
    );
  }
}

void bearFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  // ── Cabeça ────────────────────────────────────────────────────────────────
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.08, 0), width: hr * 2.05, height: hr * 1.92),
    Paint()..color = body,
  );
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.08, 0), width: hr * 2.05, height: hr * 1.92),
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.45, -0.50),
        radius: 0.60,
        colors: [Colors.white.withValues(alpha: 0.42), Colors.white.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCenter(center: Offset(hr * 0.08, 0), width: hr * 2.05, height: hr * 1.92)),
  );

  // ── Focinho redondo ───────────────────────────────────────────────────────
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.66, hr * 0.14), width: hr * 1.05, height: hr * 0.82),
    Paint()..color = const Color(0xFFD2906A),
  );

  // Linha divisória do focinho
  canvas.drawLine(
    Offset(hr * 0.66, -hr * 0.06),
    Offset(hr * 0.66,  hr * 0.18),
    Paint()
      ..color       = dark.withValues(alpha: 0.25)
      ..strokeWidth = hr * 0.05
      ..strokeCap   = StrokeCap.round,
  );

  // ── Nariz largo ───────────────────────────────────────────────────────────
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.76, -hr * 0.04), width: hr * 0.38, height: hr * 0.27),
    Paint()..color = Colors.black,
  );
  // Brilho nariz
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.67, -hr * 0.08), width: hr * 0.11, height: hr * 0.07),
    Paint()..color = Colors.white.withValues(alpha: 0.60),
  );

  // ── Olhos pequenos e amigáveis ────────────────────────────────────────────
  for (final s in [-1.0, 1.0]) {
    drawEye(canvas, Offset(hr * 0.08, s * hr * 0.50), hr * 0.26,
        irisColor: const Color(0xFF4E2800));
  }

  // ── Boca curvada para cima ────────────────────────────────────────────────
  canvas.drawArc(
    Rect.fromCenter(center: Offset(hr * 0.66, hr * 0.20), width: hr * 0.50, height: hr * 0.28),
    0.22, 2.70,
    false,
    Paint()
      ..color       = dark.withValues(alpha: 0.55)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = hr * 0.07
      ..strokeCap   = StrokeCap.round,
  );
}
