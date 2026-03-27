// lib/game/engine_camera.dart
import 'snake_engine.dart';
import 'package:flame/components.dart';

extension EngineCamera on SnakeEngine {
  void updateCamera() {
    if (!player.isAlive || player.segments.isEmpty) return;
    final Vector2 head = player.headPosition;
    final Vector2 center = size / 2;
    cameraOffset = Vector2(
      (head.x - center.x).clamp(0.0, worldSize.x - size.x),
      (head.y - center.y).clamp(0.0, worldSize.y - size.y),
    );
  }

  // ── Rect visível na tela (com margem) ────────────────────────
  bool isOnScreen(double wx, double wy, {double margin = 60}) {
    final sx = wx - cameraOffset.x;
    final sy = wy - cameraOffset.y;
    return sx >= -margin &&
        sx <= size.x + margin &&
        sy >= -margin &&
        sy <= size.y + margin;
  }

  bool isRectOnScreen(double wx, double wy, double w, double h,
      {double margin = 0}) {
    final sx = wx - cameraOffset.x;
    final sy = wy - cameraOffset.y;
    return sx + w >= -margin &&
        sx <= size.x + margin &&
        sy + h >= -margin &&
        sy <= size.y + margin;
  }
}
