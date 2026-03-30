// lib/ui/main_menu/painters/snake_preview_painter.dart
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../game/skins/snake_skin.dart';
import '../../../components/animal_skins/heads/head_registry.dart';

class SnakePreviewPainter extends CustomPainter {
  final SnakeSkin skin;
  final double t;

  SnakePreviewPainter({required this.skin, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    try {
      if (!skin.isUnlocked) {
        _drawLockedPreview(canvas, size);
        return;
      }
      
      _drawSnakePreview(canvas, size);
    } catch (e) {
      print('Erro ao renderizar skin ${skin.id}: $e');
      _drawLockedPreview(canvas, size);
    }
  }

  void _drawLockedPreview(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = Colors.grey.shade800);
    
    final center = Offset(size.width / 2, size.height / 2);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size.width * 0.35, height: size.height * 0.28),
        Radius.circular(4),
      ),
      Paint()..color = Colors.white70,
    );
    
    canvas.drawArc(
      Rect.fromCenter(center: Offset(center.dx, center.dy - size.height * 0.12), 
                      width: size.width * 0.28, height: size.height * 0.22),
      0, pi, false,
      Paint()..color = Colors.white70..style = PaintingStyle.stroke..strokeWidth = 3,
    );
    
    final textSpan = TextSpan(
      text: '🔒',
      style: TextStyle(color: Colors.white70, fontSize: size.width * 0.35),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - size.height * 0.05));
  }

  void _drawSnakePreview(Canvas canvas, Size size) {
    final double H = size.height;
    final double W = size.width;
    const int N = 22;
    const double SP = 8.5;
    const double amp = 14;
    final double bodyR = 6.5;
    final double headR = 11;
    final double startX = 10;
    
    final bool isAnimal = skin.animalType != 'snake' && 
                          skin.animalType != 'default' &&
                          skin.animalType.isNotEmpty;

    final List<Offset> segs = [];
    for (int i = 0; i < N; i++) {
      final double phase = t - (N - 1 - i) * 0.32;
      segs.add(Offset(startX + i * SP, H / 2 + sin(phase) * amp));
    }

    final Offset tailPos = segs.first;
    final Offset tailDir = segs.length > 1 ? (segs.first - segs[1]) : const Offset(-1, 0);
    final double tailAngle = atan2(tailDir.dy, tailDir.dx);

    _drawSnakeTailPreview(canvas, tailPos, tailAngle, bodyR, skin.bodyColor, skin.bodyColorDark);

    for (int i = 0; i < N - 1; i++) {
      final double progress = i / N;
      final double taper = 1.0 - progress * 0.18;
      final double r = (bodyR * taper).clamp(bodyR * 0.70, bodyR);
      final double mix = i / N;
      final Color base = Color.lerp(skin.bodyColorDark, skin.bodyColor, mix)!;
      final Color ventral = _lighten(base, 0.35);

      canvas.drawCircle(segs[i] + Offset(r * 0.15, r * 0.20), r * 0.90,
          Paint()..color = Colors.black.withValues(alpha: 0.24));

      final vPaint = Paint()
        ..shader = ui.Gradient.radial(
          segs[i] + Offset(-r * 0.30, -r * 0.42),
          r * 2.2,
          [ventral, base, skin.bodyColorDark],
          [0.0, 0.52, 1.0],
        );
      canvas.drawCircle(segs[i], r, vPaint);

      _drawScalePattern(canvas, segs[i], r, mix, skin.bodyColorDark);

      canvas.drawCircle(
          segs[i],
          r * 0.91,
          Paint()
            ..color = skin.bodyColorDark.withValues(alpha: 0.38)
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.14);

      final sPaint = Paint()
        ..shader = ui.Gradient.radial(
          segs[i] + Offset(-r * 0.42, -r * 0.42),
          r * 0.75,
          [Colors.white.withValues(alpha: 0.52 * (1 - progress)), Colors.white.withValues(alpha: 0.0)],
        );
      canvas.drawCircle(segs[i], r, sPaint);
    }

    final Offset h = segs.last;
    final Offset hDir = segs.length >= 2 ? (segs.last - segs[segs.length - 2]) : const Offset(1, 0);
    final double headAngle = atan2(hDir.dy, hDir.dx);

    canvas.save();
    canvas.translate(h.dx, h.dy);
    canvas.rotate(headAngle);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(2, 2.5), width: headR * 2.4, height: headR * 2.0),
      Paint()..color = Colors.black.withValues(alpha: 0.28),
    );

    final glowR = ui.Gradient.radial(const Offset(0, 0), headR * 2.4,
        [skin.bodyColor.withValues(alpha: 0.22), skin.bodyColor.withValues(alpha: 0)]);
    canvas.drawCircle(Offset.zero, headR * 2.4, Paint()..shader = glowR);

    final double hw = headR * 2.2;
    final double hh = headR * 1.9;

    final headGrad = Paint()
      ..shader = ui.Gradient.radial(
        Offset(-headR * 0.30, -headR * 0.40),
        hw * 0.9,
        [_lighten(skin.bodyColor, 0.40), skin.bodyColor, skin.bodyColorDark],
        [0.0, 0.50, 1.0],
      );
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: hw, height: hh), headGrad);

    try {
      final headPainter = HeadRegistry.get(skin.animalType);
      headPainter.paintBack(canvas, headR, skin.bodyColor, skin.bodyColorDark);
      headPainter.paintFront(canvas, headR, t, skin.bodyColor, skin.bodyColorDark);
    } catch (e) {
      _drawDefaultSnakeHead(canvas, headR);
    }

    final shimmer = Paint()
      ..shader = ui.Gradient.radial(
        Offset(-headR * 0.40, -headR * 0.50),
        hw * 0.62,
        [Colors.white.withValues(alpha: 0.52), Colors.white.withValues(alpha: 0.0)],
      );
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: hw, height: hh), shimmer);

    canvas.restore();
  }

  void _drawDefaultSnakeHead(Canvas canvas, double r) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(r * 0.36, 0), width: r * 0.44, height: r * 0.44),
      Paint()..color = _darken(skin.bodyColor, 0.14),
    );
    final nost = Paint()..color = skin.bodyColorDark.withValues(alpha: 0.80);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(r * 0.44, -r * 0.13), width: r * 0.14, height: r * 0.09), nost);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(r * 0.44, r * 0.13), width: r * 0.14, height: r * 0.09), nost);
    _defaultEyes(canvas, r);
  }

  void _drawSnakeTailPreview(Canvas canvas, Offset pos, double angle, double r,
      Color bodyColor, Color bodyColorDark) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    final tailLen = r * 2.5;
    final path = Path()
      ..moveTo(0, -r * 0.80)
      ..cubicTo(r * 0.25, -r * 0.5, tailLen * 0.6, -r * 0.22, tailLen, 0)
      ..cubicTo(tailLen * 0.6, r * 0.22, r * 0.25, r * 0.5, 0, r * 0.80)
      ..close();

    final tailPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(tailLen, 0),
        [bodyColor, bodyColorDark, bodyColorDark.withValues(alpha: 0.0)],
        [0.0, 0.60, 1.0],
      );
    canvas.drawPath(path, tailPaint);

    final sc = Paint()
      ..color = bodyColorDark.withValues(alpha: 0.30)
      ..strokeWidth = r * 0.10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (int i = 1; i <= 3; i++) {
      final tx = tailLen * (i / 4.0);
      final tr = r * (1.0 - i * 0.20);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(tx, 0), radius: tr * 0.68),
        pi * 0.20,
        pi * 0.60,
        false,
        sc,
      );
    }
    canvas.restore();
  }

  void _drawScalePattern(Canvas canvas, Offset pos, double r, double mix, Color dark) {
    final sc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    sc.color = dark.withValues(alpha: 0.30);
    sc.strokeWidth = r * 0.12;
    canvas.drawArc(
      Rect.fromCircle(center: pos + Offset(0, r * 0.10), radius: r * 0.72),
      pi * 0.18,
      pi * 0.64,
      false,
      sc,
    );
    sc.color = dark.withValues(alpha: 0.16);
    sc.strokeWidth = r * 0.08;
    canvas.drawArc(
      Rect.fromCircle(center: pos + Offset(0, r * 0.04), radius: r * 0.44),
      pi * 0.22,
      pi * 0.56,
      false,
      sc,
    );
  }

  void _defaultEyes(Canvas canvas, double r) {
    for (final ey in [-r * 0.42, r * 0.42]) {
      canvas.drawCircle(Offset(r * 0.28, ey), r * 0.27, Paint()..color = Colors.white);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(r * 0.32, ey), width: r * 0.12, height: r * 0.24),
        Paint()..color = Colors.black,
      );
      canvas.drawCircle(Offset(r * 0.22, ey - r * 0.10), r * 0.08,
          Paint()..color = Colors.white.withValues(alpha: 0.80));
    }
  }

  Color _lighten(Color c, double amount) {
    final hsv = HSVColor.fromColor(c);
    return hsv.withValue((hsv.value + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darken(Color c, double amount) {
    final hsv = HSVColor.fromColor(c);
    return hsv.withValue((hsv.value - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant SnakePreviewPainter old) {
    if (old.skin.id != skin.id) return true;
    final tDiff = (old.t - t).abs();
    return tDiff > 0.01;
  }
}
