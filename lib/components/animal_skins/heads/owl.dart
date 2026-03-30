// lib/components/animal_skins/heads/owl.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, RadialGradient, Alignment;
import '../utils.dart';

void owlBack(Canvas canvas, double hr) {
  // Tufos auriculares — dois triângulos pontudos no topo
  final tuftPaint = Paint()..color = const Color(0xFF4E3000);
  for (final s in [-1.0, 1.0]) {
    canvas.drawPath(
      Path()
        ..moveTo(s * hr * 0.30, -hr * 0.85)
        ..lineTo(s * hr * 0.52, -hr * 1.55)
        ..lineTo(s * hr * 0.74, -hr * 0.85)
        ..close(),
      tuftPaint,
    );
    // Listras internas do tufo
    canvas.drawPath(
      Path()
        ..moveTo(s * hr * 0.38, -hr * 0.88)
        ..lineTo(s * hr * 0.52, -hr * 1.40)
        ..lineTo(s * hr * 0.66, -hr * 0.88)
        ..close(),
      Paint()..color = const Color(0xFFAA7722),
    );
  }
}

void owlFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  // ── Disco facial (oval branco-creme) ─────────────────────────────────────
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.05, 0), width: hr * 2.10, height: hr * 1.95),
    Paint()..color = body,
  );
  // Disco interno creme
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.08, 0), width: hr * 1.70, height: hr * 1.60),
    Paint()..color = const Color(0xFFFFF8E1),
  );
  // Borda do disco (arco marrom)
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.05, 0), width: hr * 2.10, height: hr * 1.95),
    Paint()
      ..color       = dark.withValues(alpha: 0.40)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = hr * 0.10,
  );

  // Highlight 3D
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.05, 0), width: hr * 2.10, height: hr * 1.95),
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.45, -0.50),
        radius: 0.55,
        colors: [Colors.white.withValues(alpha: 0.40), Colors.white.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCenter(center: Offset(hr * 0.05, 0), width: hr * 2.10, height: hr * 1.95)),
  );

  // ── Olhos enormes e redondos ───────────────────────────────────────────────
  for (final s in [-1.0, 1.0]) {
    // Aro externo escuro
    canvas.drawCircle(
      Offset(hr * 0.06, s * hr * 0.47), hr * 0.42,
      Paint()..color = dark.withValues(alpha: 0.50),
    );
    // Círculo branco do olho
    canvas.drawCircle(
      Offset(hr * 0.06, s * hr * 0.47), hr * 0.38,
      Paint()..color = Colors.white,
    );
    // Íris laranja/amarela
    canvas.drawCircle(
      Offset(hr * 0.06, s * hr * 0.47), hr * 0.28,
      Paint()..color = const Color(0xFFFFA000),
    );
    // Pupila
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hr * 0.06, s * hr * 0.47),
          width: hr * 0.14, height: hr * 0.26),
      Paint()..color = Colors.black,
    );
    // Reflexo
    canvas.drawCircle(
      Offset(hr * 0.06 - hr * 0.10, s * (hr * 0.47 - hr * 0.10)), hr * 0.08,
      Paint()..color = Colors.white.withValues(alpha: 0.90),
    );
  }

  // ── Bico pequeno e curvado ────────────────────────────────────────────────
  canvas.drawPath(
    Path()
      ..moveTo(hr * 0.56, -hr * 0.10)
      ..lineTo(hr * 0.82,  hr * 0.04)
      ..lineTo(hr * 0.56,  hr * 0.14)
      ..close(),
    Paint()..color = const Color(0xFFFF8F00),
  );
  // Brilho no bico
  canvas.drawOval(
    Rect.fromCenter(center: Offset(hr * 0.62, -hr * 0.03), width: hr * 0.10, height: hr * 0.06),
    Paint()..color = Colors.white.withValues(alpha: 0.45),
  );
}
