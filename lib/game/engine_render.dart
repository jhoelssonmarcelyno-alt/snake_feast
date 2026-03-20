// lib/game/engine_render.dart
import 'dart:ui';
import 'package:flame/components.dart';
import '../utils/constants.dart';
import 'snake_engine.dart';

extension EngineRender on SnakeEngine {
  void renderWorld(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), bgPaint);
    renderGrassTiles(canvas);
    renderGrid(canvas);
    renderFoods(canvas); // ← comida renderizada aqui, direto no canvas
    renderWorldBorder(canvas);
  }

  void renderHud(Canvas canvas) {
    renderMinimap(canvas);
    renderLeaderboard(canvas);
  }

  // ─── Fundo simples ────────────────────────────────────────────
  void renderGrassTiles(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), grassLightPaint);
  }

  void renderGrassBlades(Canvas canvas) {
    // Removido para performance
  }

  // ─── Grid ─────────────────────────────────────────────────────
  void renderGrid(Canvas canvas) {
    final double startX = -(cameraOffset.x % kGridSpacing);
    final double startY = -(cameraOffset.y % kGridSpacing);
    for (double x = startX; x <= size.x; x += kGridSpacing)
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridPaint);
    for (double y = startY; y <= size.y; y += kGridSpacing)
      canvas.drawLine(Offset(0, y), Offset(size.x, y), gridPaint);
  }

  // ─── Comida — render direto, sem loop de componentes ─────────
  void renderFoods(Canvas canvas) {
    final double camX = cameraOffset.x;
    final double camY = cameraOffset.y;
    final double sw = size.x;
    final double sh = size.y;

    for (final food in foods) {
      final double sx = food.position.x - camX;
      final double sy = food.position.y - camY;
      final double r = food.radius + food.glowRadius;
      // Culling — só renderiza o que está na tela
      if (sx < -r || sx > sw + r || sy < -r || sy > sh + r) continue;
      food.render(canvas, camX, camY);
    }
  }

  // ─── Muro de tijolos ─────────────────────────────────────────
  void renderWorldBorder(Canvas canvas) {
    final double tlx = -cameraOffset.x;
    final double tly = -cameraOffset.y;
    final double brx = worldSize.x - cameraOffset.x;
    final double bry = worldSize.y - cameraOffset.y;
    if (brx <= 0 || bry <= 0 || tlx >= size.x || tly >= size.y) return;

    const double t = kWallThickness;
    canvas.drawRect(
        Rect.fromLTRB(tlx, tly, brx, bry),
        wallShadow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8);

    drawBrickedWall(canvas, tlx, tly, brx, tly + t, true);
    drawBrickedWall(canvas, tlx, bry - t, brx, bry, true);
    drawBrickedWall(canvas, tlx, tly, tlx + t, bry, false);
    drawBrickedWall(canvas, brx - t, tly, brx, bry, false);
  }

  void drawBrickedWall(Canvas canvas, double x1, double y1, double x2,
      double y2, bool horizontal) {
    canvas.drawRect(Rect.fromLTRB(x1, y1, x2, y2), wallBase);
    if (horizontal) {
      final int rows = ((y2 - y1) / kWallBrickH).ceil();
      for (int row = 0; row < rows; row++) {
        final double ty = y1 + row * kWallBrickH;
        final double offset = (row % 2 == 0) ? 0 : kWallBrickW * 0.5;
        for (double tx = x1 - offset; tx < x2; tx += kWallBrickW) {
          final double bx1 = tx.clamp(x1, x2);
          final double bx2 = (tx + kWallBrickW - 2).clamp(x1, x2);
          final double by2 = (ty + kWallBrickH - 2).clamp(y1, y2);
          if (bx2 <= bx1 || by2 <= ty) continue;
          canvas.drawRect(Rect.fromLTRB(bx1, ty, bx2, by2), wallBrick);
          canvas.drawRect(Rect.fromLTRB(bx1, ty, bx2, by2), wallHighlight);
        }
      }
    } else {
      final int cols = ((x2 - x1) / kWallBrickH).ceil();
      for (int col = 0; col < cols; col++) {
        final double tx = x1 + col * kWallBrickH;
        final double offset = (col % 2 == 0) ? 0 : kWallBrickW * 0.5;
        for (double ty = y1 - offset; ty < y2; ty += kWallBrickW) {
          final double bx2 = (tx + kWallBrickH - 2).clamp(x1, x2);
          final double by1 = ty.clamp(y1, y2);
          final double by2 = (ty + kWallBrickW - 2).clamp(y1, y2);
          if (bx2 <= tx || by2 <= by1) continue;
          canvas.drawRect(Rect.fromLTRB(tx, by1, bx2, by2), wallBrick);
          canvas.drawRect(Rect.fromLTRB(tx, by1, bx2, by2), wallHighlight);
        }
      }
    }
  }

  // ─── Minimap ─────────────────────────────────────────────────
  void renderMinimap(Canvas canvas) {
    const double ms = kMinimapSize;
    const double mg = kMinimapMargin;
    final double mx = size.x - ms - mg;
    final double my = size.y - ms - kMinimapBottomOffset;

    // fundo transparente — só borda sutil
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(mx, my, ms, ms), const Radius.circular(8)),
        minimapBorder);

    Vector2 toMm(Vector2 wp) => Vector2(
          mx + (wp.x / worldSize.x) * ms,
          my + (wp.y / worldSize.y) * ms,
        );

    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(mx, my, ms, ms), const Radius.circular(8)));

    for (final food in foods) {
      final Vector2 p = toMm(food.position);
      canvas.drawCircle(Offset(p.x, p.y), 1.0, minimapFood);
    }
    for (final bot in bots) {
      if (!bot.isAlive || bot.segments.isEmpty) continue;
      minimapBot.color = bot.bodyColor;
      final Vector2 p = toMm(bot.segments.first);
      canvas.drawCircle(Offset(p.x, p.y), 2.5, minimapBot);
    }
    if (player.isAlive && player.segments.isNotEmpty) {
      minimapPlayer.color = player.skin.accentColor;
      final Vector2 p = toMm(player.segments.first);
      canvas.drawCircle(Offset(p.x, p.y), 3.5, minimapPlayer);
    }
    final Vector2 vtl = toMm(cameraOffset);
    final Vector2 vbr = toMm(cameraOffset + size);
    canvas.drawRect(Rect.fromLTRB(vtl.x, vtl.y, vbr.x, vbr.y), minimapViewport);
    canvas.restore();
  }

  // ─── Leaderboard ─────────────────────────────────────────────
  void renderLeaderboard(Canvas canvas) {
    if (lbEntryPainters.isEmpty) return;
    const double lbW = 130.0;
    const double lbMg = 12.0;
    final double lbH = 20.0 + lbEntryPainters.length * 16.0 + 4;

    // fundo transparente — só borda sutil
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(lbMg, lbMg, lbW, lbH), const Radius.circular(8)),
        lbBorder);
    lbTitlePainter.paint(canvas, Offset(lbMg + 8, lbMg + 5));
    for (int i = 0; i < lbEntryPainters.length; i++) {
      lbEntryPainters[i].paint(canvas, Offset(lbMg + 8, lbMg + 20 + i * 16.0));
    }
  }
}
