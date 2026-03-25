// lib/game/engine_minimap.dart

import 'dart:ui';
import 'package:flame/components.dart';
import 'snake_engine.dart';

// ✅ CORREÇÃO AQUI: Diga ao Dart para esconder a constante que está conflitando
import 'engine_zone.dart' hide kBattleTotalTime;

// Mantenha o import das constantes normalmente
import '../utils/constants.dart';

extension EngineMinimap on SnakeEngine {
  // ... resto do seu código de renderização do minimapa
  void renderMinimap(Canvas canvas) {
    const double ms = kMinimapSize;
    const double mg = kMinimapMargin;

    final double mx = size.x - ms - mg;
    final double my = size.y - ms - kMinimapBottomOffset;

    // 1. Desenha o fundo e a borda do Minimapa
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(mx, my, ms, ms), const Radius.circular(8)),
        minimapBorder);

    // Função auxiliar mundo -> minimapa
    Offset toMm(Vector2 wp) => Offset(
          mx + (wp.x / worldSize.x) * ms,
          my + (wp.y / worldSize.y) * ms,
        );

    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(mx, my, ms, ms), const Radius.circular(8)));

    // 2. Renderiza a ZONA (Crucial para o Battle Royale)
    if (battleActive) {
      final Offset zCenter = toMm(zoneCenter);
      final double zRadius = (zoneRadius / worldSize.x) * ms;

      final double danger = 1.0 - (battleTimer / kBattleTotalTime);
      final Color mZoneColor = Color.lerp(
        const Color(0xFF00AAFF),
        const Color(0xFFFF2200),
        danger,
      )!
          .withAlpha(160);

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
        Paint()..color = mZoneColor.withAlpha(15),
      );
    }

    // --- REMOVIDO: Loop de renderFoods (pontos brancos e amarelos) ---

    // 3. Renderiza os BOTS (Inimigos)
    for (final bot in bots) {
      if (!bot.isAlive || bot.segments.isEmpty) continue;
      minimapBot.color = bot.bodyColor;
      final Offset p = toMm(bot.segments.first);
      canvas.drawCircle(p, 2.2, minimapBot);
    }

    // 4. Renderiza o JOGADOR (Destaque)
    if (player.isAlive && player.segments.isNotEmpty) {
      minimapPlayer.color = player.skin.accentColor;
      final Offset p = toMm(player.segments.first);

      // Círculo interno
      canvas.drawCircle(p, 3.2, minimapPlayer);
      // Brilho/Borda externa para não perder de vista
      canvas.drawCircle(
          p,
          4.5,
          Paint()
            ..color = minimapPlayer.color.withAlpha(120)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0);
    }

    // 5. Retângulo da Câmera
    final Offset vtl = toMm(cameraOffset);
    final Offset vbr = toMm(cameraOffset + size);
    canvas.drawRect(
        Rect.fromLTRB(vtl.dx, vtl.dy, vbr.dx, vbr.dy), minimapViewport);

    canvas.restore();
  }
}
