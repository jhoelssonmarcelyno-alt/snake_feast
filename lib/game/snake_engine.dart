import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart';
import 'weather_manager.dart';
import 'engine_zone_effects.dart';
import '../services/wins_service.dart';
import '../services/world_progress_service.dart';
import '../services/skin_progress_service.dart';

import '../components/food.dart';
import '../components/snake_player.dart';
import '../components/snake_bot.dart';
import '../components/snake_bot_ai.dart';
import '../services/score_service.dart';
import '../services/audio_service.dart';
import '../services/level_service.dart';
import '../models/level_config.dart';

import 'engine_camera.dart';
import 'engine_collision.dart';
import 'engine_food.dart';
import 'engine_render.dart';
import 'engine_leaderboard.dart';
import 'engine_snakes.dart';
import 'engine_multiplayer.dart';
import 'engine_input.dart';
import 'engine_zone.dart' hide kBattleTotalTime, kZoneGraceTime;
import 'engine_win.dart';
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
  static const double kTotalGameTime = 300.0;

  static const List<Color> _worldBgColors = [
    Color(0xFF2D5A2D),
    Color(0xFF1A3A5C),
    Color(0xFF5C3A1A),
    Color(0xFF5C1A1A),
    Color(0xFF1A3A5C),
    Color(0xFF1A1A2E),
    Color(0xFF1B3A1B),
    Color(0xFF4A3000),
    Color(0xFF263238),
    Color(0xFF006064),
    Color(0xFF37474F),
    Color(0xFF1B5E20),
    Color(0xFF0D0D0D),
    Color(0xFF1A0033),
    Color(0xFF4A1942),
    Color(0xFF3E2723),
    Color(0xFF4A0000),
    Color(0xFF00838F),
    Color(0xFF1A0044),
    Color(0xFF1C1C1C),
    Color(0xFF01579B),
    Color(0xFF212121),
    Color(0xFF4A0000),
    Color(0xFF0D0030),
    Color(0xFF000000),
  ];

  static const List<Color> _worldAccentColors = [
    Color(0xFF4CAF50),
    Color(0xFF29CFFF),
    Color(0xFFFF9500),
    Color(0xFFFF3D00),
    Color(0xFF80DEEA),
    Color(0xFF7B1FA2),
    Color(0xFF8BC34A),
    Color(0xFFFFB300),
    Color(0xFFB0BEC5),
    Color(0xFF00E5FF),
    Color(0xFF90A4AE),
    Color(0xFF69F0AE),
    Color(0xFF455A64),
    Color(0xFFE040FB),
    Color(0xFFFF80AB),
    Color(0xFFBCAAA4),
    Color(0xFFFF1744),
    Color(0xFF84FFFF),
    Color(0xFF7C4DFF),
    Color(0xFF00E676),
    Color(0xFF40C4FF),
    Color(0xFFEEEEEE),
    Color(0xFFFFD600),
    Color(0xFFAA00FF),
    Color(0xFFFFFFFF),
  ];

  int selectedWorld = 0;

  LevelConfig? _levelConfig;
  LevelConfig? get currentLevelConfig => _levelConfig;
  set currentLevelConfig(LevelConfig? value) {
    _levelConfig = value;
    _applyWorldTheme();
  }

  SnakeEngine({LevelConfig? levelConfig}) : _levelConfig = levelConfig;

  final Vector2 worldSize = Vector2(kWorldWidth, kWorldHeight);
  Vector2 cameraOffset = Vector2.zero();

  bool battleActive = false;

  late SnakePlayer player;
  final List<SnakeBot> bots = [];
  final List<Food> foods = [];

  int _skinIndex = 0;
  int get skinIndex => _skinIndex;

  double sessionTime = 0.0;
  double battleTimer = SnakeEngine.kTotalGameTime;

  bool get isFinalStage => battleTimer <= 120.0;

  Vector2 get zoneCenter => Vector2(worldSize.x / 2, worldSize.y / 2);

  double get zoneRadius {
    final double halfW = worldSize.x / 2;
    final double halfH = worldSize.y / 2;
    final double absoluteMaxR = sqrt(halfW * halfW + halfH * halfH);
    final double elapsed =
        (kBattleTotalTime - battleTimer).clamp(0.0, kBattleTotalTime);
    if (elapsed <= kZoneGraceTime) return absoluteMaxR;
    final double shrinkDuration = kBattleTotalTime - kZoneGraceTime;
    final double shrinkElapsed =
        (elapsed - kZoneGraceTime).clamp(0.0, shrinkDuration);
    final double t = shrinkElapsed / shrinkDuration;
    return (absoluteMaxR * (1.0 - t)).clamp(0.0, absoluteMaxR);
  }

  dynamic get leader {
    dynamic best;
    int bestLen = 0;
    if (player.isAlive) {
      best = player;
      bestLen = player.length;
    }
    for (int i = 0; i < bots.length; i++) {
      final b = bots[i];
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

  double zoneDamageAccum = 0.0;
  bool battleEnded = false;
  String? battleWinner;

  late Paint bgPaint;
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

  void _applyWorldTheme() {
    final int idx = selectedWorld.clamp(0, _worldBgColors.length - 1);
    final Color bg = _worldBgColors[idx];
    final Color accent = _worldAccentColors[idx];

    bgPaint.color = bg;
    grassLightPaint.color = Color.lerp(bg, accent, 0.35)!;
    grassDarkPaint.color = Color.lerp(bg, accent, 0.20)!;
    bladeDark.color = Color.lerp(bg, accent, 0.25)!;
    bladeLight.color = Color.lerp(bg, accent, 0.40)!;
    gridPaint.color = Color.lerp(
      const Color(0x22FFFFFF),
      accent.withValues(alpha: 0.15),
      0.5,
    )!;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await ScoreService.instance.init();
    await AudioService.instance.init();
    await LevelService.instance.init();
    await WorldProgressService().init(devMode: DEV_MODE);
    await SkinProgressService().init(devMode: DEV_MODE);
    await WinsService().init();
    _skinIndex = ScoreService.instance.selectedSkinIndex;

    WeatherManager.init(this);
    ZoneEffectManager.init();

    bgPaint = Paint()..color = const Color(0xFF2D5A2D);
    _applyWorldTheme();

    grassBlades = _generateGrass();
    buildLbTitle();

    player = SnakePlayer(engine: this, skin: kPlayerSkins[_skinIndex]);
    player.name = ScoreService.instance.playerName;

    if (_levelConfig != null) {
      player.speed = _levelConfig!.speed;
    }

    add(player);
    _initBots();
    spawnCommonFood(kCommonFoodCount);
    spawnStars();
    initSnakeCounters();

    if (_levelConfig == null) {
      overlays.add(kOverlayMainMenu);
      pauseEngine();
      AudioService.instance.playMenuMusic();
    } else {
      startGame();
    }
  }

  void _initBots() {
    final worldDifficulty = _worldDifficulty();

    for (int i = 0; i < kBotCount; i++) {
      final colors = kBotPalette[i % kBotPalette.length];

      BotPersonalityType personality;
      if (worldDifficulty > 1.2) {
        final hardPersonalities = [
          BotPersonalityType.aggressive,
          BotPersonalityType.hunter,
          BotPersonalityType.stalker,
        ];
        personality = hardPersonalities[i % hardPersonalities.length];
      } else if (worldDifficulty > 0.7) {
        personality =
            BotPersonalityType.values[i % BotPersonalityType.values.length];
      } else {
        final easyPersonalities = [
          BotPersonalityType.passive,
          BotPersonalityType.cautious,
          BotPersonalityType.explorer,
        ];
        personality = easyPersonalities[i % easyPersonalities.length];
      }

      final bot = SnakeBot(
        botId: i,
        name: kBotNames[i % kBotNames.length],
        engine: this,
        bodyColor: colors[0],
        bodyColorDark: colors[1],
        personality: personality,
        difficultyOverride: worldDifficulty,
      );
      bots.add(bot);
      add(bot);
    }
  }

  double _worldDifficulty() => selectedWorld / 24.0;

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

  void handlePlayerDeath() async {
    if (overlays.isActive('WinOverlay') || battleEnded) return;
    if (!player.isAlive) return;

    player.die();

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
  }

  void scheduleBotRespawn(SnakeBot bot, {double delay = kBotRespawnDelay}) {
    if (battleActive) return;
    respawnQueue.add(RespawnTask(bot: bot, timeRemaining: delay));
  }

  void startGame() {
    revivesUsed = 0;
    battleEnded = false;
    battleWinner = null;
    zoneDamageAccum = 0.0;
    attractTimer = 0.0;
    sessionTime = 0.0;
    battleTimer = SnakeEngine.kTotalGameTime;
    battleActive = false;

    _applyWorldTheme();
    initBattleZone();

    overlays.remove(kOverlayMainMenu);
    overlays.remove(kOverlayGameOver);
    overlays.remove('WinOverlay');
    overlays.add(kOverlayHud);

    resumeEngine();
    AudioService.instance.playGameMusic();
  }

  void restartGame() {
    pauseEngine();

    overlays.remove(kOverlayHud);
    overlays.remove(kOverlayGameOver);
    overlays.remove(kOverlayRevive);
    overlays.remove('WinOverlay');

    if (player.isAlive) player.forceKill();
    foods.clear();

    for (final b in bots) {
      if (b.isMounted) remove(b);
    }
    bots.clear();

    respawnQueue.clear();
    lbEntryPainters.clear();

    if (player.isMounted) remove(player);

    Future.delayed(const Duration(milliseconds: 100), () {
      ScoreService.instance.resetCurrentScore();

      player = SnakePlayer(engine: this, skin: kPlayerSkins[_skinIndex]);
      player.name = ScoreService.instance.playerName;

      if (_levelConfig != null) {
        player.speed = _levelConfig!.speed;
      }

      _applyWorldTheme();

      add(player);
      _initBots();
      spawnCommonFood(kCommonFoodCount);
      spawnStars();
      initSnakeCounters();

      startGame();
    });
  }

  void consumeFood(dynamic snake, Food food) {
    if (foods.contains(food)) {
      foods.remove(food);
      try {
        snake.grow(food.value);
      } catch (e) {
        // Ignora erro de crescimento
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (paused) return;

    updateCamera();
    WeatherManager.update(dt);

    if (player.isAlive) sessionTime += dt;

    if (battleTimer > 0) {
      battleTimer -= dt;
      if (battleTimer < 0) battleTimer = 0;
    }

    updateBattleZone(dt);

    if (battleActive) {
      final r = zoneRadius;
      final center = zoneCenter;
      for (int i = foods.length - 1; i >= 0; i--) {
        if (foods[i].position.distanceTo(center) > r) {
          foods.removeAt(i);
        }
      }
    }

    if (battleTimer > 120.0) {
      if (foods.length < kCommonFoodCount) {
        spawnCommonFood(1);
      }
    }

    if (_levelConfig != null && player.score >= _levelConfig!.targetScore) {
      checkVictoryCondition();
    }

    if (!battleActive) {
      processRespawnQueue(dt);
    }

    if (!player.isAlive &&
        !overlays.isActive('WinOverlay') &&
        !overlays.isActive(kOverlayGameOver) &&
        !overlays.isActive(kOverlayRevive)) {
      handlePlayerDeath();
    }

    _collisionTimer += dt;
    if (_collisionTimer >= _collisionInterval) {
      _collisionTimer = 0;
      checkCollisions();
      checkWallCollision();
    }

    _lbUpdateTimer += dt;
    if (_lbUpdateTimer >= _lbUpdateInterval) {
      _lbUpdateTimer = 0;
      rebuildLeaderboard();
    }

    attractFoodToPlayer(dt: dt);
  }

  @override
  void render(Canvas canvas) {
    renderWorld(canvas);
    WeatherManager.render(canvas);
    super.render(canvas);
    if (battleActive) renderZone(canvas);
    renderHud(canvas);
  }
}
