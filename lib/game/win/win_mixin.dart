// lib/game/win/win_mixin.dart
import 'package:flame/game.dart';
import '../snake_engine.dart';
import '../../services/score_service.dart';
import '../../utils/constants.dart';
import 'win_effects.dart';

mixin WinMixin on FlameGame {
  SnakeEngine get engine => this as SnakeEngine;

  // Contador de revives usado em outras partes do engine
  int revivesUsed = 0;

  void checkVictoryCondition() {
    if (!engine.battleActive || engine.battleEnded || !engine.player.isAlive) {
      return;
    }
    final int aliveBots = engine.bots.where((b) => b.isAlive).length;
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

    showBooyahText(engine);
    spawnVictoryFireworks(engine);

    if (!engine.overlays.isActive('WinOverlay')) {
      engine.overlays.add('WinOverlay');
    }
  }
}
