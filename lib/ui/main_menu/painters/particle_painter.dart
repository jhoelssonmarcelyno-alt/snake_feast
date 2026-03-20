import 'dart:math';
import 'package:flutter/material.dart';
import '../models/particle.dart';

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double t;
  ParticlePainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final double progress = (t * p.speed * 10 + p.phase) % 1.0;
      final double alpha = sin(progress * pi).clamp(0.0, 1.0);
      final double cy = (p.y - progress * p.speed * 2) % 1.0;
      canvas.drawCircle(
        Offset(p.x * size.width, cy * size.height),
        p.radius,
        Paint()..color = p.color.withOpacity(alpha * 0.55),
      );
    }
  }
  @override
  bool shouldRepaint(covariant ParticlePainter old) => old.t != t;
}
