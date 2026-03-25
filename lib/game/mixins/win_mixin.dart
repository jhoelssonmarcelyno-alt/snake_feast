import 'package:flame/game.dart';
import '../snake_engine.dart';
import '../../services/score_service.dart';
import '../effects/victory_effects.dart';

mixin WinMixin on FlameGame {
  SnakeEngine get engine => this as SnakeEngine;

  void checkVictoryCondition() {
    if (!engine.battleActive || engine.battleEnded || !engine.player.isAlive) {
      return;
    }

    final aliveBots = engine.bots.where((b) => b.isAlive).length;

    if (aliveBots == 0) triggerVictory();
  }

  void triggerVictory() {
    engine.battleEnded = true;
    engine.battleWinner = engine.player.name;

    ScoreService.instance.submitFullReward(
      score: engine.player.score,
      kills: engine.player.kills,
      level: engine.player.level,
      secondsAlive: engine.sessionTime,
      isVictory: true,
    );

    VictoryEffects.showBooyah(engine);
    VictoryEffects.spawnFireworks(engine);

    if (!engine.overlays.isActive('WinOverlay')) {
      engine.overlays.add('WinOverlay');
    }
  }
}
