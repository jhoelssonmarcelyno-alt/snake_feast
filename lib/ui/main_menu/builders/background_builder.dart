import 'package:flutter/material.dart';
import '../models/particle.dart';
import '../painters/particle_painter.dart';
import '../painters/grass_painter.dart';

Widget buildBackground(
  AnimationController particleCtrl,
  List<Particle> particles,
) {
  return Stack(
    fit: StackFit.expand,
    children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B3A1B), Color(0xFF2D5A2D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      CustomPaint(painter: GrassPainter()),
      AnimatedBuilder(
        animation: particleCtrl,
        builder: (_, __) => CustomPaint(
          painter: ParticlePainter(particles, particleCtrl.value),
        ),
      ),
    ],
  );
}
