import 'package:flutter/material.dart';
import '../../game/snake_engine.dart';
import '../../game/engine_zone.dart' hide kBattleTotalTime, kZoneGraceTime;
import '../../services/score_service.dart';
import '../../utils/constants.dart';
import '../../ui/main_menu/widgets/pause_button.dart';
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
  Offset? _joystickOrigin;
  Offset? _joystickThumb;
  int? _joystickPointer;
  bool _boostPressed = false;
  late AnimationController _pulseCtrl;
  bool _tickActive = false; // ← controla o loop

  static const TextStyle _base = TextStyle(
    decoration: TextDecoration.none,
    decorationColor: Colors.transparent,
    decorationThickness: 0,
  );

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _tickActive = true;
    WidgetsBinding.instance.addPostFrameCallback(_tick);
  }

  void _tick(Duration _) {
    if (!_tickActive || !mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback(_tick);
  }

  @override
  void dispose() {
    _tickActive = false; // ← para o loop antes de tudo
    _pulseCtrl.stop();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Joystick ────────────────────────────────────────────────
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

  void _onJoyCancel(PointerCancelEvent e) =>
      _onJoyUp(PointerUpEvent(pointer: e.pointer));

  // ── Boost ───────────────────────────────────────────────────
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

  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;
    final player = engine.player;
    final size = MediaQuery.of(context).size;

    engine.refreshSnakeCounts();
    final inGrace = engine.battleTimer > (kBattleTotalTime - kZoneGraceTime);
    final int hs = ScoreService.instance.highScore;

    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: _base,
        child: Stack(
          children: [
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
            Positioned(
              right: 24,
              bottom: 24,
              child: HudBoostButton(
                isPressed: _boostPressed,
                isBoosting: player.isBoosting,
                onDown: _onBoostDown,
                onUp: _onBoostUp,
                onCancel: _onBoostCancel,
              ),
            ),
            Positioned(
              right: 24,
              bottom: 115,
              child: HudPauseButton(engine: engine),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Column(
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: player.scoreNotifier,
                      builder: (context, score, _) {
                        return Text(
                          '$score',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                            decoration: TextDecoration.none,
                          ),
                        );
                      },
                    ),
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
            HudStatsCard(
              kills: player.kills,
              length: player.length,
              highScore: hs,
              level: player.level,
              coins: 0,
              diamonds: 0,
              revives: 0,
              aliveSnakes: ValueNotifier<int>(engine.aliveSnakes),
              totalSnakes: ValueNotifier<int>(engine.totalSnakesAtStart),
            ),
          ],
        ),
      ),
    );
  }
}
