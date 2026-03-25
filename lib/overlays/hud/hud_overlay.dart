// lib/overlays/hud/hud_overlay.dart
import 'package:flutter/material.dart';
import '../../game/snake_engine.dart';
import '../../game/engine_zone.dart' hide kBattleTotalTime;
import '../../services/score_service.dart';
import '../../utils/constants.dart';
import 'hud_joystick.dart';
import 'hud_boost_button.dart';
import 'hud_stats_card.dart';
import 'hud_battle_timer.dart';

class HudOverlay extends StatefulWidget {
  final SnakeEngine engine;
  const HudOverlay({super.key, required this.engine});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay>
    with SingleTickerProviderStateMixin {
  // ── Joystick state ──────────────────────────────────────────
  Offset? _joystickOrigin;
  Offset? _joystickThumb;
  int? _joystickPointer;

  // ── Boost state ─────────────────────────────────────────────
  bool _boostPressed = false;

  // ── Animação de pulso do cronômetro ─────────────────────────
  late AnimationController _pulseCtrl;

  static const TextStyle _base = TextStyle(
    decoration: TextDecoration.none,
    decorationColor: Colors.transparent,
    decorationThickness: 0,
  );

  // ── Lifecycle ───────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    // Inicia o loop de atualização da UI
    WidgetsBinding.instance.addPostFrameCallback(_tick);
  }

  void _tick(Duration _) {
    // ✅ CORREÇÃO 1: Se o HUD foi removido, mata o loop imediatamente
    if (!mounted) return;

    setState(() {});

    // Continua o loop apenas se ainda estiver montado
    WidgetsBinding.instance.addPostFrameCallback(_tick);
  }

  @override
  void dispose() {
    // ✅ CORREÇÃO 2: Garante que a animação pare antes de destruir
    _pulseCtrl.stop();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Joystick handlers ───────────────────────────────────────
  void _onJoyDown(PointerDownEvent e) {
    if (!mounted || _joystickPointer != null) return;
    _joystickPointer = e.pointer;
    setState(() {
      _joystickOrigin = e.localPosition;
      _joystickThumb = e.localPosition;
    });
    widget.engine.player.setJoystick(e.localPosition, e.localPosition);
  }

  void _onJoyMove(PointerMoveEvent e) {
    // ✅ CORREÇÃO 3: Proteção contra setState pós-dispose
    if (!mounted || e.pointer != _joystickPointer || _joystickOrigin == null)
      return;

    final delta = e.localPosition - _joystickOrigin!;
    final dist = delta.distance;
    final clamped = dist <= HudJoystick.baseRadius
        ? e.localPosition
        : _joystickOrigin! +
            Offset(delta.dx, delta.dy) / dist * HudJoystick.baseRadius;

    setState(() => _joystickThumb = clamped);
    widget.engine.player.setJoystick(_joystickOrigin!, e.localPosition);
  }

  void _onJoyUp(PointerUpEvent e) {
    if (!mounted || e.pointer != _joystickPointer) return;
    _joystickPointer = null;
    setState(() {
      _joystickOrigin = null;
      _joystickThumb = null;
    });
    widget.engine.player.clearJoystick();
  }

  void _onJoyCancel(PointerCancelEvent e) {
    if (!mounted || e.pointer != _joystickPointer) return;
    _joystickPointer = null;
    setState(() {
      _joystickOrigin = null;
      _joystickThumb = null;
    });
    widget.engine.player.clearJoystick();
  }

  // ── Boost handlers ──────────────────────────────────────────
  void _onBoostDown(PointerDownEvent _) {
    if (!mounted) return;
    setState(() => _boostPressed = true);
    widget.engine.player.setBoost(true);
  }

  void _onBoostUp(PointerUpEvent _) {
    if (!mounted) return;
    setState(() => _boostPressed = false);
    widget.engine.player.setBoost(false);
  }

  void _onBoostCancel(PointerCancelEvent _) {
    if (!mounted) return;
    setState(() => _boostPressed = false);
    widget.engine.player.setBoost(false);
  }

  // ── Build ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;
    final player = engine.player;
    final score = player.score;
    final hs = ScoreService.instance.highScore;
    final isRecord = score >= hs && score > 0;
    final size = MediaQuery.of(context).size;

    engine.refreshSnakeCounts();
    final battleTime = engine.battleTimer;
    final inGrace = battleTime > (kBattleTotalTime - kZoneGraceTime);

    const double boostSize = HudBoostButton.size;
    const double boostRight = 24.0;
    const double boostBottom = 24.0;

    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: _base,
        child: Stack(
          children: [
            // ── Joystick ───────────────────────────────────────
            HudJoystick(
              screenWidth: size.width,
              screenHeight: size.height,
              origin: _joystickOrigin,
              thumb: _joystickThumb,
              onDown: _onJoyDown,
              onMove: _onJoyMove,
              onUp: _onJoyUp,
              onCancel: _onJoyCancel,
            ),

            // ── Boost ──────────────────────────────────────────
            Positioned(
              right: boostRight,
              bottom: boostBottom,
              child: HudBoostButton(
                isPressed: _boostPressed,
                isBoosting: player.isBoosting,
                onDown: _onBoostDown,
                onUp: _onBoostUp,
                onCancel: _onBoostCancel,
              ),
            ),

            // ── Pause ──────────────────────────────────────────
            Positioned(
              right: boostRight + (boostSize - 64) / 2,
              bottom: boostBottom + boostSize + 12.0,
              child: GestureDetector(
                onTap: () {
                  engine.pauseEngine();
                  engine.overlays.remove(kOverlayHud);
                  engine.overlays.add(kOverlayPause);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  width: 64,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withValues(alpha: 0.08),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.30),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text('PAUSE',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          decoration: TextDecoration.none,
                        )),
                  ),
                ),
              ),
            ),

            // ── Score central superior ─────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 6),
                    Text('$score',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          letterSpacing: 2,
                          color:
                              isRecord ? const Color(0xFFFFD600) : Colors.white,
                          decoration: TextDecoration.none,
                          shadows: [
                            Shadow(
                              color: isRecord
                                  ? const Color(0xFFFFD600)
                                      .withValues(alpha: 0.6)
                                  : Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                            )
                          ],
                        )),
                    if (isRecord)
                      const Text('● RECORDE',
                          style: TextStyle(
                            color: Color(0xFFFFD600),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                            decoration: TextDecoration.none,
                          )),
                    const SizedBox(height: 4),
                    HudBattleTimer(
                      timerText: engine.battleTimerFormatted,
                      phase: engine.battleTimerPhase,
                      inGrace: inGrace,
                      pulseCtrl: _pulseCtrl,
                    ),
                  ],
                ),
              ),
            ),

            // ── Stats card ─────────────────────────────────────
            HudStatsCard(
              kills: player.kills,
              length: player.length,
              highScore: hs,
              level: player.level,
              coins: ScoreService.instance.coins,
              diamonds: ScoreService.instance.diamonds,
              revives: ScoreService.instance.revives,
              aliveSnakes: engine.aliveSnakes,
              totalSnakes: engine.totalSnakesAtStart,
            ),
          ],
        ),
      ),
    );
  }
}
