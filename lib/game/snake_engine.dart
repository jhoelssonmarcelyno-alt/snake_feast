// lib/game/snake_engine.dart

import 'dart:math';
import 'dart:ui';
import '../components/snake_bot_ai.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart'
    show
        AppLifecycleState,
        Color,
        Colors,
        TextPainter,
        TextSpan,
        TextStyle,
        TextDirection,
        FontWeight,
        Shadow;

import '../components/food.dart';
import '../components/snake_player.dart';
import '../components/snake_bot.dart';
import '../services/score_service.dart';
import '../services/audio_service.dart';
import '../services/bluetooth_service.dart';

import 'engine_camera.dart';
import 'engine_collision.dart';
import 'engine_food.dart';
import 'engine_render.dart';
import 'engine_leaderboard.dart';
import 'engine_snakes.dart';
import 'engine_multiplayer.dart';
import 'engine_input.dart';
import 'engine_zone.dart' hide kBattleTotalTime;
import 'engine_minimap.dart';
import 'engine_win.dart';
import 'game_sync.dart';
import '../utils/constants.dart';

class RespawnTask {
  final SnakeBot bot;
  double timeRemaining;
  RespawnTask({required this.bot, required this.timeRemaining});
}

class GrassBlade {
  final double wx, wy, size;
  final bool dark;
  const GrassBlade({
    required this.wx,
    required this.wy,
    required this.size,
    required this.dark,
  });
}

class SnakeEngine extends FlameGame
    with DragCallbacks, SnakesMixin, MultiplayerMixin, InputMixin, WinMixin {
  final Vector2 worldSize = Vector2(kWorldWidth, kWorldHeight);
  Vector2 cameraOffset = Vector2.zero();

  late SnakePlayer player;
  final List<SnakeBot> bots = [];
  final List<Food> foods = [];

  int _skinIndex = 0;
  int get skinIndex => _skinIndex;

  // ── Tempo de vida do player na sessão atual ───────────────────
  double sessionTime = 0.0;

  dynamic get leader {
    dynamic best;
    int bestLen = 0;
    if (player.isAlive && player.length > bestLen) {
      best = player;
      bestLen = player.length;
    }
    for (final b in bots) {
      if (b.isAlive && b.length > bestLen) {
        best = b;
        bestLen = b.length;
      }
    }
    return best;
  }

  final List<RespawnTask> respawnQueue = [];
  final Random rng = Random();

  late final List<GrassBlade> grassBlades;

  // --- Battle Royale Zone State ---
  double battleTimer = kBattleTotalTime;
  double zoneDamageAccum = 0.0;
  bool battleActive = false;
  bool battleEnded = false;
  String? battleWinner;

  // --- Paints Globais ---
  final Paint bgPaint = Paint()..color = const Color(0xFF2D5A2D);
  final Paint grassDarkPaint = Paint()..color = const Color(0xFF2A5228);
  final Paint grassLightPaint = Paint()..color = const Color(0xFF4CAF50);
  final Paint gridPaint = Paint()
    ..color = kColorGrid
    ..strokeWidth = 0.5;
  final Paint bladeDark = Paint()
    ..color = const Color(0xFF2A5C2A)
    ..strokeCap = StrokeCap.round;
  final Paint bladeLight = Paint()
    ..color = const Color(0xFF4A8C3F)
    ..strokeCap = StrokeCap.round;

  final Paint wallBase = Paint()..color = const Color(0xFF5D4037);
  final Paint wallBrick = Paint()..color = const Color(0xFF4E342E);
  final Paint wallHighlight = Paint()
    ..color = const Color(0xFF795548)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  final Paint wallShadow = Paint()..color = const Color(0x88000000);

  final Paint minimapBg = Paint()..color = const Color(0x00000000);
  final Paint minimapBorder = Paint()
    ..color = const Color(0x4400FF88)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  final Paint minimapPlayer = Paint()..color = kPlayerColor;
  final Paint minimapBot = Paint()..color = const Color(0xFFFF5555);
  final Paint minimapFood = Paint()..color = const Color(0x99FFFFFF);
  final Paint minimapViewport = Paint()
    ..color = const Color(0x33FFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  final Paint lbBg = Paint()..color = const Color(0x00000000);
  final Paint lbBorder = Paint()
    ..color = const Color(0x1100FF88)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  late TextPainter lbTitlePainter;
  final List<TextPainter> lbEntryPainters = [];

  double _collisionTimer = 0.0;
  static const double _collisionInterval = 1.0 / 20.0;
  double _lbUpdateTimer = 0.0;
  static const double _lbUpdateInterval = 1.0;

  double attractTimer = 0.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await ScoreService.instance.init();
    await AudioService.instance.init();
    _skinIndex = ScoreService.instance.selectedSkinIndex;

    grassBlades = _generateGrass();
    buildLbTitle();

    player = SnakePlayer(engine: this, skin: kPlayerSkins[_skinIndex]);
    player.name = ScoreService.instance.playerName;
    add(player);

    _initBots();

    spawnCommonFood(kCommonFoodCount);
    spawnStars();
    initSnakeCounters();

    overlays.add(kOverlayMainMenu);
    pauseEngine();
    AudioService.instance.playMenuMusic();
  }

  void _initBots() {
    for (int i = 0; i < kBotCount; i++) {
      final colors = kBotPalette[i % kBotPalette.length];
      final personality =
          BotPersonalityType.values[i % BotPersonalityType.values.length];
      final bot = SnakeBot(
        botId: i,
        name: kBotNames[i % kBotNames.length],
        engine: this,
        bodyColor: colors[0],
        bodyColorDark: colors[1],
        personality: personality,
      );
      bots.add(bot);
      add(bot);
    }
  }

  List<GrassBlade> _generateGrass() {
    final list = <GrassBlade>[];
    const double spacing = 200.0;
    for (double wx = 0; wx < kWorldWidth; wx += spacing) {
      for (double wy = 0; wy < kWorldHeight; wy += spacing) {
        final double jx = (rng.nextDouble() - 0.5) * spacing * 0.85;
        final double jy = (rng.nextDouble() - 0.5) * spacing * 0.85;
        list.add(GrassBlade(
          wx: wx + jx,
          wy: wy + jy,
          size: 5.0 + rng.nextDouble() * 9.0,
          dark: rng.nextBool(),
        ));
      }
    }
    return list;
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        AudioService.instance.pause();
        break;
      case AppLifecycleState.resumed:
        AudioService.instance.resume();
        break;
      case AppLifecycleState.detached:
        AudioService.instance.stop();
        break;
    }
  }

  void setSkin(int index) {
    _skinIndex = index.clamp(0, kPlayerSkins.length - 1);
    ScoreService.instance.saveSkinIndex(_skinIndex);
    if (player.isAlive) player.updateSkin(kPlayerSkins[_skinIndex]);
  }

  void revivePlayer() {
    revivesUsed++;
    player.revive(worldSize / 2);
    overlays.remove(kOverlayRevive);
    overlays.add(kOverlayHud);
    resumeEngine();
  }

  /// ✅ CORRIGIDO: Agora usa o novo sistema de recompensa completa
  void handlePlayerDeath() async {
    if (overlays.isActive('WinOverlay') || battleEnded) return;
    if (!player.isAlive) return;

    player.die();

    // ── Submete XP completo com breakdown (Novo Sistema Jhoelsson Studio) ──
    await ScoreService.instance.submitFullReward(
      score: player.score,
      kills: player.kills,
      level: player.level,
      secondsAlive: sessionTime,
      isVictory: false,
    );

    overlays.remove(kOverlayHud);
    overlays.add(kOverlayGameOver);
    AudioService.instance.playMenuMusic();

    if (isMultiplayer) notifyDeathBluetooth();
  }

  void scheduleBotRespawn(SnakeBot bot, {double delay = kBotRespawnDelay}) {
    if (battleActive) return;
    respawnQueue.add(RespawnTask(bot: bot, timeRemaining: delay));
  }

  void startGame() {
    // ✅ CORRIGIDO: Removido resetRewardsFlag (agora automático no submit)
    revivesUsed = 0;
    battleEnded = false;
    battleWinner = null;
    zoneDamageAccum = 0.0;
    attractTimer = 0.0;
    sessionTime = 0.0;

    initBattleZone();

    overlays.remove(kOverlayMainMenu);
    overlays.remove(kOverlayGameOver);
    overlays.remove('WinOverlay');
    overlays.add(kOverlayHud);

    resumeEngine();
    AudioService.instance.playGameMusic();
  }

  void restartGame() {
    foods.clear();
    if (isMultiplayer) stopMultiplayer();
    for (final b in List<SnakeBot>.from(bots)) {
      remove(b);
    }
    bots.clear();
    respawnQueue.clear();
    lbEntryPainters.clear();
    remove(player);

    Future.microtask(() {
      player = SnakePlayer(engine: this, skin: kPlayerSkins[_skinIndex]);
      player.name = ScoreService.instance.playerName;
      add(player);
      _initBots();
      spawnCommonFood(kCommonFoodCount);
      spawnStars();
      initSnakeCounters();
      startGame();
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateCamera();

    if (player.isAlive) sessionTime += dt;

    updateBattleZone(dt);
    checkVictoryCondition();

    // ── LÓGICA DE ESCASSEZ ──
    if (battleTimer > 60) {
      processRespawnQueue(dt);
    }

    if (!player.isAlive &&
        !overlays.isActive('WinOverlay') &&
        !overlays.isActive(kOverlayGameOver)) {
      handlePlayerDeath();
    }

    _collisionTimer += dt;
    if (_collisionTimer >= _collisionInterval) {
      _collisionTimer = 0;
      checkCollisions();
      checkWallCollision();
      if (isMultiplayer) checkRemoteCollisions();
    }

    _lbUpdateTimer += dt;
    if (_lbUpdateTimer >= _lbUpdateInterval) {
      _lbUpdateTimer = 0;
      rebuildLeaderboard();
    }

    attractFoodToPlayer(dt: dt);
    if (isMultiplayer) gameSync?.cleanStaleStates();
  }

  @override
  void render(Canvas canvas) {
    renderWorld(canvas);
    super.render(canvas);
    if (isMultiplayer) renderRemotePlayers(canvas);
    if (battleActive) renderZone(canvas);
    renderHud(canvas);
  }
}
