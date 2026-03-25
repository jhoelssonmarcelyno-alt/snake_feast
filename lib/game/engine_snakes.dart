// lib/game/engine_snakes.dart
//
// Mixin responsável por:
//   • Contadores de cobras (vivas / mortas / total inicial)
//   • Fila de respawn de bots
//   • Revives do jogador
//
import 'package:flame/game.dart';
import '../components/snake_bot.dart';
import 'snake_engine.dart';
import '../utils/constants.dart';

mixin SnakesMixin on FlameGame {
  // Cast seguro para o engine completo
  SnakeEngine get _e => this as SnakeEngine;

  // ─── Sistema de reviver ───────────────────────────────────────
  int revivesUsed = 0;
  static const int kMaxRevives = 3;

  // ─── Contadores de cobras ─────────────────────────────────────
  //
  // [totalSnakesAtStart] = número de cobras que começaram a partida
  //   (player + bots + jogadores remotos no multiplayer)
  //   Definido uma única vez em initSnakeCounters() e não muda mais.
  //
  // [aliveSnakes]  = cobras ainda vivas  (atualizado a cada frame)
  // [deadSnakes]   = cobras que morreram (atualizado a cada frame)
  //
  // Exemplo de display: "25 / 50"
  //   onde 25 = aliveSnakes  e  50 = totalSnakesAtStart
  //
  int totalSnakesAtStart = 0;
  int aliveSnakes = 0;
  int deadSnakes = 0;

  /// Deve ser chamado logo após criar todos os bots e o player,
  /// tanto em onLoad() quanto em restartGame().
  void initSnakeCounters() {
    // +1 pelo jogador local
    // bots.length pelos bots
    // remotePlayers.length pelos jogadores Bluetooth (0 em single-player)
    totalSnakesAtStart = 1 + _e.bots.length + _e.remotePlayers.length;
    _refreshAliveCounts();
  }

  /// Recalcula aliveSnakes e deadSnakes com base no estado atual.
  /// Chamado internamente; pode ser chamado pelo HUD se necessário.
  void refreshSnakeCounts() => _refreshAliveCounts();

  void _refreshAliveCounts() {
    int alive = 0;

    // Jogador local
    if (_e.player.isAlive) alive++;

    // Bots
    for (final b in _e.bots) {
      if (b.isAlive) alive++;
    }

    // Jogadores remotos (multiplayer)
    for (final r in _e.remotePlayers.values) {
      if (r.isAlive) alive++;
    }

    aliveSnakes = alive;
    // mortas = total inicial menos as que ainda estão vivas
    // (bots respawnados contam como "vivos" de novo, igual ao jogo original)
    deadSnakes = totalSnakesAtStart - aliveSnakes;
  }

  /// Texto formatado pronto para exibir no HUD.
  /// Ex.: "25 / 50"  onde  25 = vivas,  50 = total inicial
  String get snakeCounterText {
    _refreshAliveCounts();
    return '$aliveSnakes / $totalSnakesAtStart';
  }

  // ─── Fila de respawn ──────────────────────────────────────────
  void processRespawnQueue(double dt) {
    for (final task in List<RespawnTask>.from(_e.respawnQueue)) {
      task.timeRemaining -= dt;
      if (task.timeRemaining <= 0) {
        // task.bot.respawn(); // descomente quando implementar respawn
        _e.respawnQueue.remove(task);
        // Após respawn, recalcula contadores
        _refreshAliveCounts();
      }
    }
  }
}
