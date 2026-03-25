// lib/game/engine_render.dart
import 'dart:math';
import 'dart:ui';
import 'snake_engine.dart';
import 'engine_minimap.dart'; // Essencial para o renderMinimap() funcionar
import 'engine_leaderboard.dart'; // Se renderLeaderboard estiver em outro arquivo, importe aqui
import '../components/food.dart' show FoodType;
import '../utils/constants.dart';
import 'package:flame/components.dart';

extension EngineRender on SnakeEngine {
  // ─── Renderização Principal ─────────────────────────────────────
  void renderWorld(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), bgPaint);
    renderGrassTiles(canvas);
    renderGrid(canvas);
    renderFoods(canvas);
    renderWorldBorder(canvas);
  }

  void renderHud(Canvas canvas) {
    // Esses métodos precisam estar visíveis (via import ou definidos aqui)
    renderMinimap(canvas);
    renderLeaderboard(canvas);
  }

  // ─── Fundo e Grid ──────────────────────────────────────────────
  static final Map<int, String> _grassLetters = {};
  static final List<String> _alphabet = ['J', 'S', 'K', 'B', 'H', 'I', 'G'];
  static final Random _grassRng = Random(42);

  void renderGrassTiles(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), grassLightPaint);
    _renderGrassLetters(canvas);
  }

  void _renderGrassLetters(Canvas canvas) {
    const double spacing = kGridSpacing;
    final double camX = cameraOffset.x;
    final double camY = cameraOffset.y;

    final int startCellX = (camX / spacing).floor() - 1;
    final int startCellY = (camY / spacing).floor() - 1;
    final int endCellX = ((camX + size.x) / spacing).ceil() + 1;
    final int endCellY = ((camY + size.y) / spacing).ceil() + 1;

    for (int cx = startCellX; cx <= endCellX; cx++) {
      for (int cy = startCellY; cy <= endCellY; cy++) {
        final int key = cx * 100003 + cy;
        _grassLetters.putIfAbsent(
            key,
            () => _grassRng.nextDouble() < 0.25
                ? _alphabet[_grassRng.nextInt(_alphabet.length)]
                : '');

        final String letter = _grassLetters[key]!;
        if (letter.isEmpty) continue;

        final double sx = cx * spacing - camX + spacing * 0.5;
        final double sy = cy * spacing - camY + spacing * 0.5;

        final pb = ParagraphBuilder(
            ParagraphStyle(fontSize: 48, fontWeight: FontWeight.w700))
          ..pushStyle(TextStyle(color: const Color(0x26FFFFFF), fontSize: 48))
          ..addText(letter);
        final para = pb.build()..layout(const ParagraphConstraints(width: 60));
        canvas.drawParagraph(para,
            Offset(sx - para.maxIntrinsicWidth / 2, sy - para.height / 2));
      }
    }
  }

  void renderGrid(Canvas canvas) {
    final double startX = -(cameraOffset.x % kGridSpacing);
    final double startY = -(cameraOffset.y % kGridSpacing);
    for (double x = startX; x <= size.x; x += kGridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridPaint);
    }
    for (double y = startY; y <= size.y; y += kGridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), gridPaint);
    }
  }

  void renderFoods(Canvas canvas) {
    for (final food in foods) {
      final double sx = food.position.x - cameraOffset.x;
      final double sy = food.position.y - cameraOffset.y;
      final double r = food.radius + food.glowRadius;
      if (sx < -r || sx > size.x + r || sy < -r || sy > size.y + r) continue;
      food.render(canvas, cameraOffset.x, cameraOffset.y);
    }
  }

  // ─── Muro (Corrigindo o erro de Undefined drawBrickedWall) ──────
  void renderWorldBorder(Canvas canvas) {
    final double tlx = -cameraOffset.x;
    final double tly = -cameraOffset.y;
    final double brx = worldSize.x - cameraOffset.x;
    final double bry = worldSize.y - cameraOffset.y;

    canvas.drawRect(
        Rect.fromLTRB(tlx, tly, brx, bry),
        wallShadow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8);

    // CHAMA O MÉTODO DEFINIDO LOGO ABAIXO
    drawBrickedWall(canvas, tlx, tly, brx, tly + kWallThickness, true);
    drawBrickedWall(canvas, tlx, bry - kWallThickness, brx, bry, true);
    drawBrickedWall(canvas, tlx, tly, tlx + kWallThickness, bry, false);
    drawBrickedWall(canvas, brx - kWallThickness, tly, brx, bry, false);
  }

  void drawBrickedWall(Canvas canvas, double x1, double y1, double x2,
      double y2, bool horizontal) {
    canvas.drawRect(Rect.fromLTRB(x1, y1, x2, y2), wallBase);
    if (horizontal) {
      for (double ty = y1; ty < y2; ty += kWallBrickH) {
        double offset =
            ((ty - y1) / kWallBrickH).floor() % 2 == 0 ? 0 : kWallBrickW * 0.5;
        for (double tx = x1 - offset; tx < x2; tx += kWallBrickW) {
          final rect = Rect.fromLTRB(
              tx.clamp(x1, x2),
              ty,
              (tx + kWallBrickW - 2).clamp(x1, x2),
              (ty + kWallBrickH - 2).clamp(y1, y2));
          if (rect.width > 0 && rect.height > 0) {
            canvas.drawRect(rect, wallBrick);
            canvas.drawRect(rect, wallHighlight);
          }
        }
      }
    } else {
      for (double tx = x1; tx < x2; tx += kWallBrickH) {
        double offset =
            ((tx - x1) / kWallBrickH).floor() % 2 == 0 ? 0 : kWallBrickW * 0.5;
        for (double ty = y1 - offset; ty < y2; ty += kWallBrickW) {
          final rect = Rect.fromLTRB(
              tx,
              ty.clamp(y1, y2),
              (tx + kWallBrickH - 2).clamp(x1, x2),
              (ty + kWallBrickW - 2).clamp(y1, y2));
          if (rect.width > 0 && rect.height > 0) {
            canvas.drawRect(rect, wallBrick);
            canvas.drawRect(rect, wallHighlight);
          }
        }
      }
    }
  }

  // Adicione o renderLeaderboard aqui se ele não estiver em engine_leaderboard.dart
  void renderLeaderboard(Canvas canvas) {
    if (lbEntryPainters.isEmpty) return;
    const double lbW = 130.0;
    const double lbMg = 12.0;
    final double lbH = 20.0 + lbEntryPainters.length * 16.0 + 4;

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
