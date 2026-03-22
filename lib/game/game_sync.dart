// game_sync.dart — stub (bluetooth desabilitado)
import 'snake_engine.dart';

class RemotePlayerState {
  final String id;
  final String playerId;
  final double x, y, dx, dy;
  final int score, length, kills, skinIndex;
  final bool alive, isBoosting;

  RemotePlayerState({
    this.id = '',
    this.playerId = '',
    this.x = 0, this.y = 0,
    this.dx = 1, this.dy = 0,
    this.score = 0, this.length = 0,
    this.kills = 0, this.skinIndex = 0,
    this.alive = true, this.isBoosting = false,
  });
}

class GameSync {
  final SnakeEngine engine;
  GameSync({required this.engine});
  void start() {}
  void stop() {}
  void notifyDeath() {}
  void sendFoodRemoved(dynamic food) {}
  void sendFoodSpawned(dynamic food) {}
  void cleanStaleStates() {}
}
