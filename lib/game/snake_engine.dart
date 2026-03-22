// lib/game/snake_engine.dart
import 'dart:math';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart'
    show
        AppLifecycleState, // ← ADICIONADO
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

  // Segmentos interpolados para render
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
    // Inicializa segmentos atrás da cabeça
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

class SnakeEngine extends FlameGame with DragCallbacks {
  // ─── Mundo ───────────────────────────────────────────────────
  final Vector2 worldSize = Vector2(kWorldWidth, kWorldHeight);
  Vector2 cameraOffset = Vector2.zero();

  // ─── Componentes ─────────────────────────────────────────────
  late SnakePlayer player;
  final List<SnakeBot> bots = [];
  final List<Food> foods = [];

  // ─── MULTIPLAYER ─────────────────────────────────────────────
  bool isMultiplayer = false;
  GameSync? _gameSync;
  final Map<String, RemoteSnake> remotePlayers = {};
  final Map<String, Food> remoteFoods = {};

  // ─── Estado ──────────────────────────────────────────────────
  int _skinIndex = 0;
  int get skinIndex => _skinIndex;

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
    // Inclui jogadores remotos no ranking de líder
    for (final r in remotePlayers.values) {
      if (r.isAlive && r.length > bestLen) {
        best = r;
        bestLen = r.length;
      }
    }
    return best;
  }

  final List<RespawnTask> respawnQueue = [];
  final Random rng = Random();

  // ─── Sistema de reviver ───────────────────────────────────────
  int revivesUsed = 0;
  static const int kMaxRevives = 3;

  // ─── Grama ───────────────────────────────────────────────────
  late final List<GrassBlade> grassBlades;

  // ─── Paints — fundo ──────────────────────────────────────────
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

  // ─── Paints — muro ───────────────────────────────────────────
  final Paint wallBase = Paint()..color = const Color(0xFF5D4037);
  final Paint wallBrick = Paint()..color = const Color(0xFF4E342E);
  final Paint wallHighlight = Paint()
    ..color = const Color(0xFF795548)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  final Paint wallShadow = Paint()..color = const Color(0x88000000);

  // ─── Paints — minimap ────────────────────────────────────────
  final Paint minimapBg = Paint()..color = const Color(0x00000000);
  final Paint minimapBorder = Paint()
    ..color = const Color(0x2200FF88)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final Paint minimapPlayer = Paint()..color = kPlayerColor;
  final Paint minimapBot = Paint();
  final Paint minimapFood = Paint()..color = const Color(0x99FFFFFF);
  final Paint minimapViewport = Paint()
    ..color = const Color(0x33FFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  // ─── Paints — leaderboard ────────────────────────────────────
  final Paint lbBg = Paint()..color = const Color(0x00000000);
  final Paint lbBorder = Paint()
    ..color = const Color(0x1100FF88)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  // ─── TextPainters — leaderboard ──────────────────────────────
  late TextPainter lbTitlePainter;
  final List<TextPainter> lbEntryPainters = [];

  // ─── Throttle ────────────────────────────────────────────────
  double _collisionTimer = 0.0;
  static const double _collisionInterval = 1.0 / 20.0;
  double _lbUpdateTimer = 0.0;
  double attractTimer = 0.0;
  static const double _lbUpdateInterval = 1.0;

  // ═══════════════════════════════════════════════════════════ //
  //  onLoad                                                      //
  // ═══════════════════════════════════════════════════════════ //
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

    for (int i = 0; i < kBotCount; i++) {
      final colors = kBotPalette[i % kBotPalette.length];
      final personality =
          BotPersonality.values[i % BotPersonality.values.length];
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

    spawnCommonFood(kCommonFoodCount);
    spawnStars();
    overlays.add(kOverlayMainMenu);
    pauseEngine();
    AudioService.instance.playMenuMusic();
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

  // ═══════════════════════════════════════════════════════════ //
  //  CICLO DE VIDA DO APP — pausa/retoma música ao minimizar    //
  // ═══════════════════════════════════════════════════════════ //
  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // App minimizado, tela desligada ou interrompido
        AudioService.instance.pause();
        break;
      case AppLifecycleState.resumed:
        // Voltou para o app — só retoma se estava jogando ativamente
        if (overlays.isActive(kOverlayHud)) {
          AudioService.instance.resume();
        }
        // No menu ou pause: a música certa já está configurada,
        // basta retomar se não estava mutado
        else if (overlays.isActive(kOverlayMainMenu) ||
            overlays.isActive(kOverlayPause)) {
          AudioService.instance.resume();
        }
        break;
      case AppLifecycleState.detached:
        AudioService.instance.stop();
        break;
    }
  }

  // ─── API pública ─────────────────────────────────────────────
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

  void handlePlayerDeath() {
    if (!player.isAlive) return;
    player.die();
    ScoreService.instance.submitScore(player.score);
    ScoreService.instance.processRewards(player.foodEaten);
    overlays.remove(kOverlayHud);
    overlays.add(kOverlayGameOver);
    AudioService.instance.playMenuMusic();

    // Notifica outros jogadores via Bluetooth
    if (isMultiplayer) {
      _gameSync?.notifyDeath();
    }
  }

  void scheduleBotRespawn(SnakeBot bot, {double delay = kBotRespawnDelay}) {
    respawnQueue.add(RespawnTask(bot: bot, timeRemaining: delay));
  }

  void startGame() {
    ScoreService.instance.resetRewardsFlag();
    revivesUsed = 0;
    overlays.remove(kOverlayMainMenu);
    overlays.remove(kOverlayGameOver);
    overlays.add(kOverlayHud);
    resumeEngine();
    AudioService.instance.playGameMusic();
  }

  void restartGame() {
    foods.clear();

    // Para sync multiplayer se estava ativo
    if (isMultiplayer) {
      _stopMultiplayer();
    }

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

      for (int i = 0; i < kBotCount; i++) {
        final colors = kBotPalette[i % kBotPalette.length];
        final personality =
            BotPersonality.values[i % BotPersonality.values.length];
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
      spawnCommonFood(kCommonFoodCount);
      spawnStars();
      startGame();
    });
  }

  // ═══════════════════════════════════════════════════════════ //
  //  MULTIPLAYER — 5 métodos principais                         //
  // ═══════════════════════════════════════════════════════════ //

  /// 1. Inicia partida multiplayer com a lista de jogadores da sala
  void startMultiplayerGame(List<Map<String, dynamic>> players) {
    isMultiplayer = true;
    remotePlayers.clear();
    remoteFoods.clear();

    // Registra os outros jogadores como RemoteSnakes
    final bt = BluetoothGameService.instance;
    for (final p in players) {
      final id = p['id'] as String;
      if (id == bt.localId) continue; // pula o jogador local

      final skinIdx = (p['skinIndex'] as int?) ?? 0;
      final skin = kPlayerSkins[skinIdx.clamp(0, kPlayerSkins.length - 1)];

      remotePlayers[id] = RemoteSnake(
        playerId: id,
        name: p['name'] as String? ?? 'Jogador',
        skinIndex: skinIdx,
        headPos: worldSize / 2 +
            Vector2(rng.nextDouble() * 400 - 200, rng.nextDouble() * 400 - 200),
        direction: Vector2(1, 0),
        length: kPlayerInitialSegments,
        score: 0,
        color: skin.bodyColor,
      );
    }

    // Em modo multiplayer, reduz bots para dar espaço
    // (mantém só metade dos bots normais)
    final botsToRemove = bots.length - (kBotCount ~/ 2);
    if (botsToRemove > 0) {
      for (int i = 0; i < botsToRemove; i++) {
        final bot = bots.removeLast();
        remove(bot);
      }
    }

    // Inicia sincronização Bluetooth
    _gameSync = GameSync(engine: this);
    _gameSync!.start();

    // Inicia partida normalmente
    startGame();
  }

  /// 2. Atualiza posição/estado de um jogador remoto
  void updateRemotePlayer(RemotePlayerState state) {
    final remote = remotePlayers[state.id];
    if (remote == null) {
      // Jogador novo — cria
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

  /// 3. Remove jogador remoto (saiu/morreu)
  void removeRemotePlayer(String playerId) {
    remotePlayers.remove(playerId);
  }

  /// 4a. Spawna comida enviada pelo host
  void spawnRemoteFood(String foodId, double x, double y, int foodType) {
    final pos = Vector2(x, y);
    Food food;
    switch (foodType) {
      case 1:
        food = Food.star(position: pos);
        break;
      case 2:
        food =
            Food.botMass(position: pos, segmentColor: const Color(0xFFFFAB40));
        break;
      default:
        food = Food.common(position: pos);
    }
    remoteFoods[foodId] = food;
    foods.add(food);
  }

  /// 4b. Remove comida (alguém comeu)
  void removeRemoteFood(String foodId) {
    final food = remoteFoods.remove(foodId);
    if (food != null) {
      foods.remove(food);
    }
  }

  /// 5. Trata fim de partida multiplayer
  void handleMultiplayerGameOver(Map<String, dynamic> data) {
    _stopMultiplayer();

    overlays.remove(kOverlayHud);
    overlays.add(kOverlayGameOver);
    AudioService.instance.playMenuMusic();
  }

  // ─── Para o modo multiplayer ──────────────────────────────────
  void _stopMultiplayer() {
    _gameSync?.stop();
    _gameSync = null;
    isMultiplayer = false;
    remotePlayers.clear();
    remoteFoods.clear();
  }

  // ─── Render remoto (chamado pelo engine_render.dart) ──────────
  /// Renderiza as cobras dos outros jogadores
  void renderRemotePlayers(Canvas canvas) {
    if (!isMultiplayer || remotePlayers.isEmpty) return;

    final double camX = cameraOffset.x;
    final double camY = cameraOffset.y;
    final double sw = size.x;
    final double sh = size.y;

    for (final remote in remotePlayers.values) {
      if (!remote.isAlive || remote.segments.isEmpty) continue;

      final skinIdx = remote.skinIndex.clamp(0, kPlayerSkins.length - 1);
      final skin = kPlayerSkins[skinIdx];

      // Culling rápido
      final hx = remote.headPos.x - camX;
      final hy = remote.headPos.y - camY;
      if (hx < -200 || hx > sw + 200 || hy < -200 || hy > sh + 200) continue;

      final hr = kPlayerHeadRadius.toDouble();

      // Renderiza segmentos
      for (int i = remote.segments.length - 1; i >= 1; i--) {
        final sx = remote.segments[i].x - camX;
        final sy = remote.segments[i].y - camY;
        if (sx < -30 || sx > sw + 30 || sy < -30 || sy > sh + 30) continue;

        final t = 1.0 - (i / remote.segments.length);
        final r = (hr * (1.0 - i / remote.segments.length * 0.18))
            .clamp(hr * 0.70, hr);

        final Color bodyColor =
            Color.lerp(skin.bodyColorDark, skin.bodyColor, t)!;

        // Sombra
        canvas.drawCircle(
          Offset(sx + r * 0.15, sy + r * 0.20),
          r * 0.90,
          Paint()..color = Colors.black.withValues(alpha: 0.24),
        );
        // Corpo
        canvas.drawCircle(Offset(sx, sy), r, Paint()..color = bodyColor);
        // Highlight
        canvas.drawCircle(
          Offset(sx - r * 0.28, sy - r * 0.28),
          r * 0.32,
          Paint()..color = Colors.white.withValues(alpha: 0.28 * t),
        );

        // Glow de boost
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
        // Sombra
        canvas.drawCircle(
          Offset(headSx + 2, headSy + 2),
          hr,
          Paint()..color = Colors.black.withValues(alpha: 0.28),
        );

        // Glow se boost
        if (remote.isBoosting) {
          canvas.drawCircle(
            Offset(headSx, headSy),
            hr + 4,
            Paint()..color = skin.accentColor.withValues(alpha: 0.35),
          );
        }

        // Corpo da cabeça
        canvas.drawCircle(
          Offset(headSx, headSy),
          hr,
          Paint()..color = skin.bodyColor,
        );
        // Highlight
        canvas.drawCircle(
          Offset(headSx - hr * 0.25, headSy - hr * 0.25),
          hr * 0.35,
          Paint()..color = Colors.white.withValues(alpha: 0.45),
        );

        // Olhos simples
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

        // Nome do jogador remoto
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

        // Badge de score
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

  // ─── Respawn Queue ────────────────────────────────────────────
  void _processRespawnQueue(double dt) {
    for (final task in List<RespawnTask>.from(respawnQueue)) {
      task.timeRemaining -= dt;
      if (task.timeRemaining <= 0) {
        task.bot.respawn();
        respawnQueue.remove(task);
      }
    }
  }

  // ─── Update ──────────────────────────────────────────────────
  @override
  void update(double dt) {
    super.update(dt);
    updateCamera();

    _collisionTimer += dt;
    if (_collisionTimer >= _collisionInterval) {
      _collisionTimer = 0;
      checkCollisions();
      checkWallCollision();

      // Colisão com cobras remotas
      if (isMultiplayer) _checkRemoteCollisions();
    }

    _lbUpdateTimer += dt;
    if (_lbUpdateTimer >= _lbUpdateInterval) {
      _lbUpdateTimer = 0;
      rebuildLeaderboard();
    }

    _processRespawnQueue(dt);
    attractFoodToPlayer(dt: dt);

    // Limpa estados remotos obsoletos (>500ms)
    if (isMultiplayer) _gameSync?.cleanStaleStates();
  }

  // ─── Colisão com cobras remotas ───────────────────────────────
  void _checkRemoteCollisions() {
    if (!player.isAlive) return;
    final head = player.headPosition;

    for (final remote in remotePlayers.values) {
      if (!remote.isAlive || remote.segments.isEmpty) continue;

      // Colisão da cabeça local com corpo do remoto
      for (int i = 2; i < remote.segments.length; i += 2) {
        if (head.distanceTo(remote.segments[i]) <
            kPlayerHeadRadius * kCollisionBodyRatio) {
          handlePlayerDeath();
          return;
        }
      }

      // Colisão de cabeça com cabeça (head-on)
      if (head.distanceTo(remote.headPos) < kPlayerHeadRadius * 1.5) {
        // Quem tem mais segmentos vence
        if (player.length <= remote.length) {
          handlePlayerDeath();
          return;
        }
      }
    }
  }

  // ─── Render ──────────────────────────────────────────────────
  @override
  void render(Canvas canvas) {
    renderWorld(canvas);
    super.render(canvas);

    // Renderiza cobras dos outros jogadores
    if (isMultiplayer) renderRemotePlayers(canvas);

    renderHud(canvas);
  }

  // ─── Drag ────────────────────────────────────────────────────
  @override
  bool onDragStart(DragStartEvent event) {
    if (player.isAlive) player.onDragStart(event);
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    if (player.isAlive) player.onDragUpdate(event);
    return true;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    if (player.isAlive) player.onDragEnd(event);
    return true;
  }

  @override
  bool onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    if (player.isAlive) player.onDragCancel(event);
    return true;
  }
}
