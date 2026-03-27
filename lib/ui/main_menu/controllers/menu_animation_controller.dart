import 'package:flutter/material.dart';

class MenuAnimationController {
  late final AnimationController entryCtrl;
  late final AnimationController snakeCtrl;
  late final AnimationController particleCtrl;
  late final AnimationController borderCtrl;
  late final AnimationController glowCtrl;

  late final Animation<double> titleFade;
  late final Animation<double> cardFade;
  late final Animation<double> btnFade;

  late final Animation<Offset> titleSlide;
  late final Animation<Offset> cardSlide;

  void init(TickerProvider vsync) {
    entryCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1200),
    );

    titleFade = CurvedAnimation(
      parent: entryCtrl,
      curve: const Interval(0.0, 0.5),
    );

    cardFade = CurvedAnimation(
      parent: entryCtrl,
      curve: const Interval(0.4, 0.8),
    );

    btnFade = CurvedAnimation(
      parent: entryCtrl,
      curve: const Interval(0.6, 1.0),
    );

    titleSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(entryCtrl);

    cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(entryCtrl);

    snakeCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 3),
    )..repeat();

    particleCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 6),
    )..repeat();

    borderCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 3),
    )..repeat();

    glowCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    entryCtrl.forward();
  }

  void dispose() {
    entryCtrl.dispose();
    snakeCtrl.dispose();
    particleCtrl.dispose();
    borderCtrl.dispose();
    glowCtrl.dispose();
  }
}
