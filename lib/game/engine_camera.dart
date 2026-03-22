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
}
