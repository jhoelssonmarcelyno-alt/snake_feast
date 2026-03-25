// lib/game/engine_multiplayer.dart
//
// Mixin responsável por toda a lógica multiplayer via Bluetooth:
//   • RemoteSnake — representação de outro jogador
//   • Métodos de start/stop, spawn de comida remota
//   • Render das cobras remotas
//   • Colisão da cobra local com cobras remotas
//
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart'
    show
        Color,
        Colors,
        TextPainter,
        TextSpan,
        TextStyle,
        TextDirection,
        FontWeight,
        Shadow;
import '../components/food.dart';
import '../services/audio_service.dart';
import '../services/bluetooth_service.dart';
import 'game_sync.dart';
import 'snake_engine.dart';
import '../utils/constants.dart';

// ─── Cobra remota (outro jogador via Bluetooth) ───────────────
class RemoteSnake {
  final String playerId;
  String name;
  int skinIndex;
  Vector2 headPos;
  Vector2 direction;
  int length;
  int score;
  bool isBoosting;
  bool isAlive;
  Color color;

  final List<Vector2> segments = [];

  RemoteSnake({
    required this.playerId,
    required this.name,
    required this.skinIndex,
    required this.headPos,
    required this.direction,
    required this.length,
    required this.score,
    this.isBoosting = false,
    this.isAlive = true,
    this.color = const Color(0xFF00E5FF),
  }) {
    _rebuildSegments();
  }

  void _rebuildSegments() {
    segments.clear();
    segments.add(headPos.clone());
    for (int i = 1; i < length.clamp(4, 50); i++) {
      segments
          .add(headPos - direction.normalized() * (kPlayerSegmentSpacing * i));
    }
  }

  void update(RemotePlayerState state) {
    headPos = Vector2(state.x, state.y);
    direction = Vector2(state.dx, state.dy);
    length = state.length;
    score = state.score;
    isBoosting = state.isBoosting;
    skinIndex = state.skinIndex;
    _rebuildSegments();
  }
}

// ─────────────────────────────────────────────────────────────
mixin MultiplayerMixin on FlameGame {
  SnakeEngine get _e => this as SnakeEngine;

  // ─── Estado multiplayer ───────────────────────────────────────
  bool isMultiplayer = false;
  GameSync? gameSync;
  final Map<String, RemoteSnake> remotePlayers = {};
  final Map<String, Food> remoteFoods = {};

  // ─── 1. Inicia partida multiplayer ───────────────────────────
  void startMultiplayerGame(List<Map<String, dynamic>> players) {
    isMultiplayer = true;
    remotePlayers.clear();
    remoteFoods.clear();

    final bt = BluetoothGameService.instance;
    for (final p in players) {
      final id = p['id'] as String;
      if (id == bt.localId) continue;

      final skinIdx = (p['skinIndex'] as int?) ?? 0;
      final skin = kPlayerSkins[skinIdx.clamp(0, kPlayerSkins.length - 1)];

      remotePlayers[id] = RemoteSnake(
        playerId: id,
        name: p['name'] as String? ?? 'Jogador',
        skinIndex: skinIdx,
        headPos: _e.worldSize / 2 +
            Vector2(
              _e.rng.nextDouble() * 400 - 200,
              _e.rng.nextDouble() * 400 - 200,
            ),
        direction: Vector2(1, 0),
        length: kPlayerInitialSegments,
        score: 0,
        color: skin.bodyColor,
      );
    }

    // Reduz bots para dar espaço ao multiplayer
    final botsToRemove = _e.bots.length - (kBotCount ~/ 2);
    if (botsToRemove > 0) {
      for (int i = 0; i < botsToRemove; i++) {
        final bot = _e.bots.removeLast();
        _e.remove(bot);
      }
    }

    gameSync = GameSync(engine: _e);
    gameSync!.start();

    // Recalcula contadores incluindo remotos
    _e.initSnakeCounters();

    _e.startGame();
  }

  // ─── 2. Atualiza jogador remoto ───────────────────────────────
  void updateRemotePlayer(RemotePlayerState state) {
    final remote = remotePlayers[state.id];
    if (remote == null) {
      final skinIdx = state.skinIndex.clamp(0, kPlayerSkins.length - 1);
      final skin = kPlayerSkins[skinIdx];
      remotePlayers[state.id] = RemoteSnake(
        playerId: state.id,
        name: state.id,
        skinIndex: skinIdx,
        headPos: Vector2(state.x, state.y),
        direction: Vector2(state.dx, state.dy),
        length: state.length,
        score: state.score,
        isBoosting: state.isBoosting,
        color: skin.bodyColor,
      );
    } else {
      remote.update(state);
    }
  }

  // ─── 3. Remove jogador remoto ─────────────────────────────────
  void removeRemotePlayer(String playerId) {
    remotePlayers.remove(playerId);
  }

  // ─── 4a. Spawna comida remota ─────────────────────────────────
  void spawnRemoteFood(String foodId, double x, double y, int foodType) {
    final pos = Vector2(x, y);
    Food food;
    switch (foodType) {
      case 1:
        food = Food.star(position: pos);
        break;
      case 2:
        food = Food.botMass(
          position: pos,
          segmentColor: const Color(0xFFFFAB40),
        );
        break;
      default:
        food = Food.common(position: pos);
    }
    remoteFoods[foodId] = food;
    _e.foods.add(food);
  }

  // ─── 4b. Remove comida remota ─────────────────────────────────
  void removeRemoteFood(String foodId) {
    final food = remoteFoods.remove(foodId);
    if (food != null) _e.foods.remove(food);
  }

  // ─── 5. Fim de partida multiplayer ───────────────────────────
  void handleMultiplayerGameOver(Map<String, dynamic> data) {
    stopMultiplayer();
    _e.overlays.remove(kOverlayHud);
    _e.overlays.add(kOverlayGameOver);
    AudioService.instance.playMenuMusic();
  }

  // ─── Para o modo multiplayer ──────────────────────────────────
  void stopMultiplayer() {
    gameSync?.stop();
    gameSync = null;
    isMultiplayer = false;
    remotePlayers.clear();
    remoteFoods.clear();
  }

  /// Delega notificação de morte ao GameSync
  void notifyDeathBluetooth() => gameSync?.notifyDeath();

  // ─── Colisão com cobras remotas ───────────────────────────────
  void checkRemoteCollisions() {
    if (!_e.player.isAlive) return;
    final head = _e.player.headPosition;

    for (final remote in remotePlayers.values) {
      if (!remote.isAlive || remote.segments.isEmpty) continue;

      for (int i = 2; i < remote.segments.length; i += 2) {
        if (head.distanceTo(remote.segments[i]) <
            kPlayerHeadRadius * kCollisionBodyRatio) {
          _e.handlePlayerDeath();
          return;
        }
      }

      if (head.distanceTo(remote.headPos) < kPlayerHeadRadius * 1.5) {
        if (_e.player.length <= remote.length) {
          _e.handlePlayerDeath();
          return;
        }
      }
    }
  }

  // ─── Render das cobras remotas ────────────────────────────────
  void renderRemotePlayers(Canvas canvas) {
    if (!isMultiplayer || remotePlayers.isEmpty) return;

    final double camX = _e.cameraOffset.x;
    final double camY = _e.cameraOffset.y;
    final double sw = _e.size.x;
    final double sh = _e.size.y;

    for (final remote in remotePlayers.values) {
      if (!remote.isAlive || remote.segments.isEmpty) continue;

      final skinIdx = remote.skinIndex.clamp(0, kPlayerSkins.length - 1);
      final skin = kPlayerSkins[skinIdx];

      final hx = remote.headPos.x - camX;
      final hy = remote.headPos.y - camY;
      if (hx < -200 || hx > sw + 200 || hy < -200 || hy > sh + 200) continue;

      final hr = kPlayerHeadRadius.toDouble();

      // Segmentos
      for (int i = remote.segments.length - 1; i >= 1; i--) {
        final sx = remote.segments[i].x - camX;
        final sy = remote.segments[i].y - camY;
        if (sx < -30 || sx > sw + 30 || sy < -30 || sy > sh + 30) continue;

        final t = 1.0 - (i / remote.segments.length);
        final r = (hr * (1.0 - i / remote.segments.length * 0.18))
            .clamp(hr * 0.70, hr);
        final Color bodyColor =
            Color.lerp(skin.bodyColorDark, skin.bodyColor, t)!;

        canvas.drawCircle(
          Offset(sx + r * 0.15, sy + r * 0.20),
          r * 0.90,
          Paint()..color = Colors.black.withValues(alpha: 0.24),
        );
        canvas.drawCircle(Offset(sx, sy), r, Paint()..color = bodyColor);
        canvas.drawCircle(
          Offset(sx - r * 0.28, sy - r * 0.28),
          r * 0.32,
          Paint()..color = Colors.white.withValues(alpha: 0.28 * t),
        );

        if (remote.isBoosting && i % 3 == 0) {
          canvas.drawCircle(
            Offset(sx, sy),
            r + 3,
            Paint()..color = skin.accentColor.withValues(alpha: 0.25),
          );
        }
      }

      // Cabeça
      final headSx = remote.headPos.x - camX;
      final headSy = remote.headPos.y - camY;
      if (headSx > -hr * 2 &&
          headSx < sw + hr * 2 &&
          headSy > -hr * 2 &&
          headSy < sh + hr * 2) {
        canvas.drawCircle(
          Offset(headSx + 2, headSy + 2),
          hr,
          Paint()..color = Colors.black.withValues(alpha: 0.28),
        );

        if (remote.isBoosting) {
          canvas.drawCircle(
            Offset(headSx, headSy),
            hr + 4,
            Paint()..color = skin.accentColor.withValues(alpha: 0.35),
          );
        }

        canvas.drawCircle(
          Offset(headSx, headSy),
          hr,
          Paint()..color = skin.bodyColor,
        );
        canvas.drawCircle(
          Offset(headSx - hr * 0.25, headSy - hr * 0.25),
          hr * 0.35,
          Paint()..color = Colors.white.withValues(alpha: 0.45),
        );

        for (final ey in [-hr * 0.4, hr * 0.4]) {
          canvas.drawCircle(
            Offset(headSx + hr * 0.22, headSy + ey),
            hr * 0.28,
            Paint()..color = Colors.white,
          );
          canvas.drawCircle(
            Offset(headSx + hr * 0.28, headSy + ey),
            hr * 0.14,
            Paint()..color = Colors.black,
          );
        }

        final namePainter = TextPainter(
          text: TextSpan(
            text: remote.name,
            style: TextStyle(
              color: skin.accentColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              shadows: const [Shadow(color: Color(0xFF000000), blurRadius: 4)],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        namePainter.paint(
          canvas,
          Offset(headSx - namePainter.width / 2, headSy - hr - 18),
        );

        final scorePainter = TextPainter(
          text: TextSpan(
            text: '${remote.score}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        scorePainter.paint(
          canvas,
          Offset(headSx - scorePainter.width / 2, headSy - hr - 6),
        );
      }
    }
  }
}
