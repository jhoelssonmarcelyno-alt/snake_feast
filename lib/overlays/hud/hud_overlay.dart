// lib/overlays/hud_overlay.dart
import 'package:flutter/material.dart';
import '../../game/snake_engine.dart';
import '../../game/engine_zone.dart' hide kBattleTotalTime;
import '../../services/score_service.dart';
import '../../utils/constants.dart';
// ✅ Importando o botão de pause que criamos
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
  // ── Estados de Controle ─────────────────────────────────────
  Offset? _joystickOrigin;
  Offset? _joystickThumb;
  int? _joystickPointer;
  bool _boostPressed = false;
  late AnimationController _pulseCtrl;

  static const TextStyle _base = TextStyle(
    decoration: TextDecoration.none,
    decorationColor: Colors.transparent,
    decorationThickness: 0,
  );

  @override
  void initState() {
    super.initState();
    // Animação para o timer de batalha (aviso/perigo)
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    // Tick para atualizar os stats
    WidgetsBinding.instance.addPostFrameCallback(_tick);
  }

  void _tick(Duration _) {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback(_tick);
  }

  @override
  void dispose() {
    _pulseCtrl.stop();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Handlers do Joystick ────────────────────────────────────
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

  // ── Handlers do Boost ───────────────────────────────────────
  void _onBoostDown(PointerDownEvent _) {
    setState(() => _boostPressed = true);
    widget.engine.player.setBoost(true);
  }

  void _onBoostUp(PointerUpEvent _) {
    setState(() => _boostPressed = false);
    widget.engine.player.setBoost(false);
  }

  void _onBoostCancel(PointerCancelEvent _) {
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
            // 🕹️ Joystick (Lado Esquerdo)
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

            // 🔥 Botão de Boost (Canto Inferior Direito)
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

            // ⏸️ Botão de PAUSE (Exatamente EM CIMA do Boost)
            Positioned(
              right: 24, // Alinhado horizontalmente com o Boost
              bottom: 115, // 24 (margem) + 80 (tamanho do boost) + 11 (respiro)
              child: HudPauseButton(engine: engine),
            ),

            // 🏆 Placar Central Superior
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

            // 📊 Stats Card (Informações da Partida)
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
