import 'package:flutter/material.dart';
import 'dart:ui';

// ========== FUNÇÕES ADICIONAIS PARA ANIMAIS ==========

void drawWolfHead(Canvas canvas, double r, double t, Color bodyColor, Color darkColor) {
  canvas.drawOval(
    Rect.fromCenter(center: Offset.zero, width: r * 2.0, height: r * 1.7),
    Paint()..color = bodyColor,
  );
  
  for (final ey in [-r * 0.45, r * 0.45]) {
    canvas.drawCircle(Offset(r * 0.35, ey), r * 0.22, Paint()..color = Colors.white);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(r * 0.4, ey), width: r * 0.14, height: r * 0.22),
      Paint()..color = Colors.black,
    );
  }
  
  final earPaint = Paint()..color = darkColor;
  final leftEar = Path()
    ..moveTo(-r * 0.55, -r * 0.65)
    ..lineTo(-r * 0.3, -r * 1.05)
    ..lineTo(-r * 0.05, -r * 0.65)
    ..close();
  final rightEar = Path()
    ..moveTo(r * 0.55, -r * 0.65)
    ..lineTo(r * 0.3, -r * 1.05)
    ..lineTo(r * 0.05, -r * 0.65)
    ..close();
  canvas.drawPath(leftEar, earPaint);
  canvas.drawPath(rightEar, earPaint);
  
  canvas.drawOval(
    Rect.fromCenter(center: Offset(r * 0.65, 0), width: r * 0.55, height: r * 0.4),
    Paint()..color = darkColor,
  );
  canvas.drawCircle(Offset(r * 0.82, -r * 0.1), r * 0.1, Paint()..color = Colors.black);
  canvas.drawCircle(Offset(r * 0.82, r * 0.1), r * 0.1, Paint()..color = Colors.black);
}

void drawTigerHead(Canvas canvas, double r, double t, Color bodyColor, Color darkColor) {
  canvas.drawOval(
    Rect.fromCenter(center: Offset.zero, width: r * 2.0, height: r * 1.7),
    Paint()..color = bodyColor,
  );
  
  for (final ey in [-r * 0.45, r * 0.45]) {
    canvas.drawCircle(Offset(r * 0.35, ey), r * 0.22, Paint()..color = Colors.white);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(r * 0.4, ey), width: r * 0.14, height: r * 0.22),
      Paint()..color = Colors.black,
    );
  }
  
  final stripe = Paint()..color = Colors.black.withValues(alpha: 0.6);
  for (int i = -2; i <= 2; i++) {
    canvas.drawLine(
      Offset(r * 0.5, i * r * 0.18),
      Offset(r * 0.85, i * r * 0.15),
      stripe..strokeWidth = r * 0.1,
    );
  }
  
  canvas.drawOval(
    Rect.fromCenter(center: Offset(r * 0.65, 0), width: r * 0.55, height: r * 0.4),
    Paint()..color = darkColor,
  );
  canvas.drawCircle(Offset(r * 0.82, -r * 0.1), r * 0.1, Paint()..color = Colors.black);
  canvas.drawCircle(Offset(r * 0.82, r * 0.1), r * 0.1, Paint()..color = Colors.black);
}

void drawBearHead(Canvas canvas, double r, double t, Color bodyColor, Color darkColor) {
  canvas.drawOval(
    Rect.fromCenter(center: Offset.zero, width: r * 2.2, height: r * 1.9),
    Paint()..color = bodyColor,
  );
  
  for (final ey in [-r * 0.5, r * 0.5]) {
    canvas.drawCircle(Offset(r * 0.4, ey), r * 0.24, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(r * 0.44, ey), r * 0.12, Paint()..color = Colors.black);
  }
  
  final earPaint = Paint()..color = darkColor;
  canvas.drawCircle(Offset(-r * 0.65, -r * 0.7), r * 0.32, earPaint);
  canvas.drawCircle(Offset(r * 0.65, -r * 0.7), r * 0.32, earPaint);
  
  canvas.drawOval(
    Rect.fromCenter(center: Offset(r * 0.7, 0), width: r * 0.65, height: r * 0.45),
    Paint()..color = darkColor,
  );
  canvas.drawCircle(Offset(r * 0.88, -r * 0.12), r * 0.12, Paint()..color = Colors.black);
  canvas.drawCircle(Offset(r * 0.88, r * 0.12), r * 0.12, Paint()..color = Colors.black);
}

void drawEagleHead(Canvas canvas, double r, double t, Color bodyColor, Color darkColor) {
  canvas.drawOval(
    Rect.fromCenter(center: Offset.zero, width: r * 1.8, height: r * 1.5),
    Paint()..color = bodyColor,
  );
  
  final brow = Paint()..color = Colors.black..strokeWidth = r * 0.12;
  canvas.drawArc(
    Rect.fromCenter(center: Offset(r * 0.2, -r * 0.35), width: r * 0.7, height: r * 0.6),
    0.2, 2.8, false, brow);
  canvas.drawArc(
    Rect.fromCenter(center: Offset(r * 0.2, r * 0.35), width: r * 0.7, height: r * 0.6),
    0.2, 2.8, false, brow);
  
  for (final ey in [-r * 0.42, r * 0.42]) {
    canvas.drawCircle(Offset(r * 0.32, ey), r * 0.18, Paint()..color = Colors.yellow);
    canvas.drawCircle(Offset(r * 0.35, ey), r * 0.08, Paint()..color = Colors.black);
  }
  
  final beak = Paint()..color = Colors.orange.shade700;
  final beakPath = Path()
    ..moveTo(r * 0.7, -r * 0.08)
    ..lineTo(r * 0.88, 0)
    ..lineTo(r * 0.7, r * 0.08)
    ..close();
  canvas.drawPath(beakPath, beak);
}

void drawInsectHead(Canvas canvas, double r, double t, Color bodyColor, Color darkColor) {
  canvas.drawCircle(Offset(r * 0.3, -r * 0.4), r * 0.25, Paint()..color = bodyColor);
  canvas.drawCircle(Offset(r * 0.3, r * 0.4), r * 0.25, Paint()..color = bodyColor);
  
  canvas.drawCircle(Offset(r * 0.28, -r * 0.4), r * 0.16, Paint()..color = Colors.white);
  canvas.drawCircle(Offset(r * 0.28, r * 0.4), r * 0.16, Paint()..color = Colors.white);
  canvas.drawCircle(Offset(r * 0.28, -r * 0.4), r * 0.1, Paint()..color = Colors.black);
  canvas.drawCircle(Offset(r * 0.28, r * 0.4), r * 0.1, Paint()..color = Colors.black);
  
  final ant = Paint()..color = darkColor..strokeWidth = r * 0.08;
  canvas.drawLine(Offset(r * 0.15, -r * 0.6), Offset(r * 0.28, -r * 0.78), ant);
  canvas.drawLine(Offset(r * 0.45, -r * 0.6), Offset(r * 0.32, -r * 0.78), ant);
}
