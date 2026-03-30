import 'dart:ui';
import 'package:flame/components.dart';
import 'engine_zone.dart' hide kBattleTotalTime, kZoneGraceTime;
import 'snake_engine.dart';
import '../utils/constants.dart';

// Extensão para o minimapa
extension EngineMinimap on SnakeEngine {
  void renderMinimap(Canvas canvas) {
    const double ms = kMinimapSize;
    const double mg = kMinimapMargin;

    final double mx = size.x - ms - mg;
    final double my = size.y - ms - kMinimapBottomOffset;

    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(mx, my, ms, ms), const Radius.circular(8)),
        minimapBorder);

    Offset toMm(Vector2 wp) => Offset(
          mx + (wp.x / worldSize.x) * ms,
          my + (wp.y / worldSize.y) * ms,
        );

    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(mx, my, ms, ms), const Radius.circular(8)));

    if (battleActive) {
      final Offset zCenter = toMm(zoneCenter);
      final double zRadius = (zoneRadius / worldSize.x) * ms;

      final double shrinkDuration = kBattleTotalTime - kZoneGraceTime;
      final double elapsed = (kBattleTotalTime - battleTimer - kZoneGraceTime)
          .clamp(0.0, shrinkDuration);
      final double danger = (elapsed / shrinkDuration).clamp(0.0, 1.0);

      final Color mZoneColor = Color.lerp(
        const Color(0xFF00AAFF),
        const Color(0xFFFF2200),
        danger,
      )!
          .withAlpha(180);

      canvas.drawCircle(
        zCenter,
        zRadius,
        Paint()
          ..color = mZoneColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      canvas.drawCircle(
        zCenter,
        zRadius,
        Paint()..color = mZoneColor.withAlpha(20),
      );
    }

    // Bots
    for (final bot in bots) {
      if (!bot.isAlive || bot.segments.isEmpty) continue;
      minimapBot.color = bot.bodyColor;
      canvas.drawCircle(toMm(bot.segments.first), 2.2, minimapBot);
    }

    // Jogador
    if (player.isAlive && player.segments.isNotEmpty) {
      minimapPlayer.color = player.skin.accentColor;
      final Offset p = toMm(player.segments.first);
      canvas.drawCircle(p, 3.2, minimapPlayer);
      canvas.drawCircle(
          p,
          4.5,
          Paint()
            ..color = minimapPlayer.color.withAlpha(120)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0);
    }

    // Viewport da câmera
    final Offset vtl = toMm(cameraOffset);
    final Offset vbr = toMm(cameraOffset + size);
    canvas.drawRect(
        Rect.fromLTRB(vtl.dx, vtl.dy, vbr.dx, vbr.dy), minimapViewport);

    canvas.restore();
  }
}
