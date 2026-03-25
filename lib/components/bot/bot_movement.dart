import 'package:flame/components.dart';
import '../../utils/constants.dart';

mixin BotMovement {
  final List<Vector2> segments = [];

  void moveSegments(
      double dt, Vector2 direction, bool boosting, Vector2 worldSize) {
    final double speed = boosting ? kBotBoostSpeed : kBotBaseSpeed;
    final Vector2 newHead = segments.first + direction * (speed * dt);

    // Lógica de atravessar paredes (Wrap)
    newHead.x = newHead.x % worldSize.x;
    newHead.y = newHead.y % worldSize.y;
    if (newHead.x < 0) newHead.x += worldSize.x;
    if (newHead.y < 0) newHead.y += worldSize.y;

    // Move o corpo
    for (int i = segments.length - 1; i > 0; i--) {
      segments[i] = segments[i - 1].clone();
    }
    segments[0] = newHead;
  }
}
