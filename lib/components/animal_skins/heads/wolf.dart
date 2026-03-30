// lib/components/animal_skins/heads/wolf.dart
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, RadialGradient, Alignment;
import '../utils.dart';
import 'dart:math';

void wolfBack(Canvas canvas, double hr) {
  // Orelhas pontudas
  for (final s in [-1.0, 1.0]) {
    // Orelha externa triangular
    canvas.drawPath(
      Path()
        ..moveTo(s * hr * 0.24, -hr * 0.82)
        ..lineTo(s * hr * 0.55, -hr * 1.60)
        ..lineTo(s * hr * 0.86, -hr * 0.82)
        ..close(),
      Paint()..color = const Color(0xFF546E7A),
    );
    // Orelha interna rosada
    canvas.drawPath(
      Path()
        ..moveTo(s * hr * 0.34, -hr * 0.86)
        ..lineTo(s * hr * 0.55, -hr * 1.40)
        ..lineTo(s * hr * 0.76, -hr * 0.86)
        ..close(),
      Paint()..color = const Color(0xFFE8A0A0).withValues(alpha: 0.70),
    );
  }

  // Crina do pescoço — linhas de pelo ao redor da base
  final furPaint = Paint()
    ..color = const Color(0xFF37474F)
    ..strokeWidth = hr * 0.14
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (int i = 0; i < 8; i++) {
    final t = (i / 7.0);
    final ang = 3.14 * 0.15 + t * 3.14 * 0.70; // arco inferior
    final r0 = hr * 1.00;
    final r1 = hr * 1.30;
    canvas.drawLine(
      Offset(cos(ang) * r0, sin(ang) * r0),
      Offset(cos(ang) * r1, sin(ang) * r1),
      furPaint,
    );
  }
}

void wolfFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  // ── Cabeça ────────────────────────────────────────────────────────────────
  canvas.drawOval(
    Rect.fromCenter(
        center: Offset(hr * 0.06, 0), width: hr * 2.02, height: hr * 1.88),
    Paint()..color = body,
  );
  canvas.drawOval(
    Rect.fromCenter(
        center: Offset(hr * 0.06, 0), width: hr * 2.02, height: hr * 1.88),
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.45, -0.50),
        radius: 0.58,
        colors: [
          Colors.white.withValues(alpha: 0.38),
          Colors.white.withValues(alpha: 0.0)
        ],
      ).createShader(Rect.fromCenter(
          center: Offset(hr * 0.06, 0), width: hr * 2.02, height: hr * 1.88)),
  );

  // ── Focinho alongado ──────────────────────────────────────────────────────
  canvas.drawOval(
    Rect.fromCenter(
        center: Offset(hr * 0.70, hr * 0.08),
        width: hr * 1.20,
        height: hr * 0.72),
    Paint()..color = const Color(0xFFB0BEC5),
  );
  // Linha central
  canvas.drawLine(
    Offset(hr * 0.70, -hr * 0.10),
    Offset(hr * 0.70, hr * 0.18),
    Paint()
      ..color = dark.withValues(alpha: 0.22)
      ..strokeWidth = hr * 0.05
      ..strokeCap = StrokeCap.round,
  );

  // ── Nariz ─────────────────────────────────────────────────────────────────
  canvas.drawOval(
    Rect.fromCenter(
        center: Offset(hr * 0.92, -hr * 0.05),
        width: hr * 0.36,
        height: hr * 0.25),
    Paint()..color = Colors.black,
  );
  canvas.drawOval(
    Rect.fromCenter(
        center: Offset(hr * 0.82, -hr * 0.08),
        width: hr * 0.10,
        height: hr * 0.06),
    Paint()..color = Colors.white.withValues(alpha: 0.55),
  );

  // ── Olhos amarelos ameaçadores ────────────────────────────────────────────
  for (final s in [-1.0, 1.0]) {
    drawEye(canvas, Offset(hr * 0.06, s * hr * 0.50), hr * 0.28,
        irisColor: const Color(0xFFFFD600));
    // Sobrancelha diagonal — dá expressão feroz
    canvas.drawLine(
      Offset(-hr * 0.08, s * hr * 0.24),
      Offset(hr * 0.22, s * hr * 0.20),
      Paint()
        ..color = dark.withValues(alpha: 0.70)
        ..strokeWidth = hr * 0.12
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── Focinho: boca levemente aberta com dentes ─────────────────────────────
  canvas.drawArc(
    Rect.fromCenter(
        center: Offset(hr * 0.70, hr * 0.20),
        width: hr * 0.80,
        height: hr * 0.46),
    0,
    3.14,
    true,
    Paint()..color = const Color(0xFF8B1A1A),
  );
  // Dentes
  final toothPaint = Paint()..color = Colors.white;
  for (final tx in [hr * 0.46, hr * 0.70, hr * 0.94]) {
    canvas.drawPath(
      Path()
        ..moveTo(tx, hr * 0.20)
        ..lineTo(tx + hr * 0.06, hr * 0.38)
        ..lineTo(tx + hr * 0.12, hr * 0.20)
        ..close(),
      toothPaint,
    );
  }
  canvas.drawLine(
    Offset(hr * 0.30, hr * 0.20),
    Offset(hr * 1.10, hr * 0.20),
    Paint()
      ..color = dark.withValues(alpha: 0.40)
      ..strokeWidth = hr * 0.05,
  );
}
