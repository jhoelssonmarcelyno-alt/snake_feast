import 'dart:math';
import 'package:flutter/material.dart' show Color;

class Particle {
  final double x, y, speed, radius, phase;
  final Color color;

  Particle(Random rng)
      : x = rng.nextDouble(),
        y = rng.nextDouble(),
        speed = 0.04 + rng.nextDouble() * 0.08,
        radius = 1.5 + rng.nextDouble() * 3.0,
        phase = rng.nextDouble() * pi * 2,
        color = rng.nextBool()
            ? const Color(0xFF00E5FF)
            : const Color(0xFF69F0AE);
}
