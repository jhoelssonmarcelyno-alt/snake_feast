// lib/components/animal_skins/heads/lion.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart'
    show Colors, HSVColor, RadialGradient, Alignment;
import '../utils.dart';

// ── Paleta ────────────────────────────────────────────────────────────────────
const _kMane0 = Color(0xFF3D1F00); // anel externo — quase preto
const _kMane1 = Color(0xFF6B3800); // anel médio
const _kMane2 = Color(0xFF9B5A0A); // anel interno
const _kFace = Color(0xFFE8C070); // rosto principal
const _kFaceLight = Color(0xFFF5DFA0); // highlight frontal
const _kNose = Color(0xFFCC7044); // focinho
const _kNoseTip = Color(0xFFAA3322); // ponta do nariz
const _kGum = Color(0xFF8B1A1A); // gengiva
const _kWhisker = Color(0xFFFFFDE0); // bigodes
const _kIris = Color(0xFFE8A000); // íris

// ─────────────────────────────────────────────────────────────────────────────
// CAMADA TRASEIRA — juba
// ─────────────────────────────────────────────────────────────────────────────
void lionBack(Canvas canvas, double hr) {
  // 3 anéis de mechões, do externo para o interno
  // Cada mechão = 1 drawLine (barato) — no total ~72 linhas
  const List<Color> colors = [_kMane0, _kMane1, _kMane2];
  const List<double> distMul = [1.82, 1.52, 1.24];
  const List<double> lenMul = [0.70, 0.52, 0.36];
  const List<double> widMul = [0.24, 0.20, 0.16];
  const List<int> counts = [20, 16, 14];

  final paint = Paint()
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  for (int ring = 0; ring < 3; ring++) {
    paint.color = colors[ring];
    paint.strokeWidth = hr * widMul[ring];
    final dist = hr * distMul[ring];
    final len = hr * lenMul[ring];
    final count = counts[ring];
    // Offset de fase para os anéis intercalarem
    final phase = ring * (pi / count);
    for (int i = 0; i < count; i++) {
      final a = phase + (i / count) * pi * 2;
      final ca = cos(a), sa = sin(a);
      canvas.drawLine(
        Offset(ca * dist * 0.72, sa * dist * 0.72),
        Offset(ca * (dist + len), sa * (dist + len)),
        paint,
      );
    }
  }

  // Anel de base da juba (círculo sólido por baixo dos mechões)
  canvas.drawCircle(
    Offset.zero,
    hr * 1.18,
    Paint()..color = _kMane1.withValues(alpha: 0.55),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// CAMADA FRONTAL — rosto
// ─────────────────────────────────────────────────────────────────────────────
void lionFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  // ── Cabeça base — oval levemente deslocado para a frente ──────────────────
  canvas.drawOval(
    Rect.fromCenter(
        center: Offset(hr * 0.10, 0), width: hr * 2.05, height: hr * 1.90),
    Paint()..color = _kFace,
  );

  // Highlight 3D no topo-esquerda
  final hlPaint = Paint()
    ..shader = RadialGradient(
      center: const Alignment(-0.55, -0.55),
      radius: 0.6,
      colors: [
        _kFaceLight.withValues(alpha: 0.65),
        _kFaceLight.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCenter(
        center: Offset(hr * 0.10, 0), width: hr * 2.05, height: hr * 1.90));
  canvas.drawOval(
    Rect.fromCenter(
        center: Offset(hr * 0.10, 0), width: hr * 2.05, height: hr * 1.90),
    hlPaint,
  );

  // ── Região do focinho (muzzle) — dois círculos sobrepostos ────────────────
  canvas.drawOval(
    Rect.fromCenter(
        center: Offset(hr * 0.68, hr * 0.14),
        width: hr * 1.10,
        height: hr * 0.90),
    Paint()..color = _kNose,
  );
  // Linha divisória central do focinho
  canvas.drawLine(
    Offset(hr * 0.68, -hr * 0.10),
    Offset(hr * 0.68, hr * 0.22),
    Paint()
      ..color = dark.withValues(alpha: 0.30)
      ..strokeWidth = hr * 0.06
      ..strokeCap = StrokeCap.round,
  );

  // ── Nariz ─────────────────────────────────────────────────────────────────
  final nosePath = Path()
    ..moveTo(hr * 0.52, -hr * 0.08)
    ..quadraticBezierTo(hr * 0.68, -hr * 0.22, hr * 0.84, -hr * 0.08)
    ..quadraticBezierTo(hr * 0.80, hr * 0.06, hr * 0.68, hr * 0.07)
    ..quadraticBezierTo(hr * 0.56, hr * 0.06, hr * 0.52, -hr * 0.08)
    ..close();
  canvas.drawPath(nosePath, Paint()..color = _kNoseTip);
  // Brilho no nariz
  canvas.drawOval(
    Rect.fromCenter(
        center: Offset(hr * 0.60, -hr * 0.10),
        width: hr * 0.13,
        height: hr * 0.08),
    Paint()..color = Colors.white.withValues(alpha: 0.60),
  );

  // ── Olhos ─────────────────────────────────────────────────────────────────
  for (final s in [-1.0, 1.0]) {
    drawEye(canvas, Offset(hr * 0.06, s * hr * 0.52), hr * 0.30,
        irisColor: _kIris);
    // Sobrancelha (arco espesso acima do olho)
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(hr * 0.06, s * hr * 0.52),
          width: hr * 0.80,
          height: hr * 0.50),
      s < 0 ? -pi * 0.85 : -pi * 0.15,
      s < 0 ? -pi * 0.30 : pi * 0.30,
      false,
      Paint()
        ..color = dark.withValues(alpha: 0.55)
        ..strokeWidth = hr * 0.10
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  // ── Boca ──────────────────────────────────────────────────────────────────
  // Gengiva
  canvas.drawArc(
    Rect.fromCenter(
        center: Offset(hr * 0.68, hr * 0.24),
        width: hr * 0.88,
        height: hr * 0.58),
    0,
    pi,
    true,
    Paint()..color = _kGum,
  );
  // Dentes (triângulos brancos)
  final toothPaint = Paint()..color = Colors.white;
  for (final tx in [hr * 0.40, hr * 0.76]) {
    canvas.drawPath(
      Path()
        ..moveTo(tx, hr * 0.24)
        ..lineTo(tx + hr * 0.07, hr * 0.46)
        ..lineTo(tx + hr * 0.14, hr * 0.24)
        ..close(),
      toothPaint,
    );
  }
  // Linha central da boca
  canvas.drawLine(
    Offset(hr * 0.30, hr * 0.24),
    Offset(hr * 1.06, hr * 0.24),
    Paint()
      ..color = dark.withValues(alpha: 0.50)
      ..strokeWidth = hr * 0.05,
  );

  // ── Bigodes ───────────────────────────────────────────────────────────────
  final wPaint = Paint()
    ..color = _kWhisker.withValues(alpha: 0.90)
    ..strokeWidth = hr * 0.055
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  // 3 bigodes por lado (curvas suaves com quadraticBezierTo)
  const whiskerData = [
    // [ctrlX, ctrlY, endX, endY, side]
    // Lado de cima
    [0.50, -0.10, 1.52, -0.06, 1.0],
    [0.50, -0.10, 1.52, -0.28, -1.0],
    // Lado do meio
    [0.50, 0.05, 1.50, 0.08, 1.0],
    [0.50, 0.05, 1.50, -0.12, -1.0],
    // Lado de baixo
    [0.50, 0.20, 1.48, 0.22, 1.0],
    [0.50, 0.20, 1.48, 0.04, -1.0],
  ];

  const double originX = 0.50;
  const double originY = 0.08;

  for (final w in whiskerData) {
    final side = w[4];
    final path = Path()
      ..moveTo(hr * originX, hr * originY * side)
      ..quadraticBezierTo(
        hr * w[0],
        hr * w[1] * side,
        hr * w[2],
        hr * w[3] * side,
      );
    canvas.drawPath(path, wPaint);
  }

  // ── Pintas características do leão (manchas subtis no focinho) ───────────
  final dotPaint = Paint()..color = dark.withValues(alpha: 0.22);
  for (final s in [-1.0, 1.0]) {
    for (int d = 0; d < 3; d++) {
      canvas.drawCircle(
        Offset(hr * (0.46 + d * 0.09), s * hr * 0.08),
        hr * 0.04,
        dotPaint,
      );
    }
  }
}
