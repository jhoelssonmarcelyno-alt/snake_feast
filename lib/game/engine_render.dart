// lib/game/engine_render.dart
import 'dart:math';
import 'dart:ui';
import 'snake_engine.dart';
import 'engine_minimap.dart';
import 'engine_leaderboard.dart';
import '../components/food.dart' show FoodType;
import '../utils/constants.dart';
import 'package:flame/components.dart';

extension EngineRender on SnakeEngine {
  // ── Viewport com margem para culling ────────────────────────
  static const double _cullMargin = 80.0;

  bool _inView(double wx, double wy, double radius) {
    final sx = wx - cameraOffset.x;
    final sy = wy - cameraOffset.y;
    final r = radius + _cullMargin;
    return sx > -r && sx < size.x + r && sy > -r && sy < size.y + r;
  }

  // ── Renderização Principal ──────────────────────────────────
  void renderWorld(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), bgPaint);
    renderGrassTiles(canvas);
    renderGrid(canvas);
    renderFoods(canvas);
    renderWorldBorder(canvas);
  }

  void renderHud(Canvas canvas) {
    renderMinimap(canvas);
    renderLeaderboard(canvas);
  }

  // ── Fundo e Grid ────────────────────────────────────────────
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

  // ── Foods: só renderiza o que está na tela ──────────────────
  void renderFoods(Canvas canvas) {
    for (final food in foods) {
      if (!_inView(
          food.position.x, food.position.y, food.radius + food.glowRadius))
        continue;
      food.render(canvas, cameraOffset.x, cameraOffset.y);
    }
  }

  // ── Muro: só desenha as partes visíveis ─────────────────────
  void renderWorldBorder(Canvas canvas) {
    final double tlx = -cameraOffset.x;
    final double tly = -cameraOffset.y;
    final double brx = worldSize.x - cameraOffset.x;
    final double bry = worldSize.y - cameraOffset.y;

    // Só renderiza paredes que estão na tela
    if (tly < size.y && tly + kWallThickness > 0) {
      drawBrickedWall(canvas, tlx, tly, brx, tly + kWallThickness, true);
    }
    if (bry > 0 && bry - kWallThickness < size.y) {
      drawBrickedWall(canvas, tlx, bry - kWallThickness, brx, bry, true);
    }
    if (tlx < size.x && tlx + kWallThickness > 0) {
      drawBrickedWall(canvas, tlx, tly, tlx + kWallThickness, bry, false);
    }
    if (brx > 0 && brx - kWallThickness < size.x) {
      drawBrickedWall(canvas, brx - kWallThickness, tly, brx, bry, false);
    }

    canvas.drawRect(
        Rect.fromLTRB(tlx, tly, brx, bry),
        wallShadow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8);
  }

  void drawBrickedWall(Canvas canvas, double x1, double y1, double x2,
      double y2, bool horizontal) {
    // Clipa ao viewport para não desenhar tijolos fora da tela
    final double vx1 = x1.clamp(-_cullMargin, size.x + _cullMargin);
    final double vy1 = y1.clamp(-_cullMargin, size.y + _cullMargin);
    final double vx2 = x2.clamp(-_cullMargin, size.x + _cullMargin);
    final double vy2 = y2.clamp(-_cullMargin, size.y + _cullMargin);
    if (vx2 <= vx1 || vy2 <= vy1) return;

    canvas.drawRect(Rect.fromLTRB(x1, y1, x2, y2), wallBase);

    if (horizontal) {
      for (double ty = vy1; ty < vy2; ty += kWallBrickH) {
        double offset =
            ((ty - y1) / kWallBrickH).floor() % 2 == 0 ? 0 : kWallBrickW * 0.5;
        for (double tx = vx1 - offset; tx < vx2; tx += kWallBrickW) {
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
      for (double tx = vx1; tx < vx2; tx += kWallBrickH) {
        double offset =
            ((tx - x1) / kWallBrickH).floor() % 2 == 0 ? 0 : kWallBrickW * 0.5;
        for (double ty = vy1 - offset; ty < vy2; ty += kWallBrickW) {
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
