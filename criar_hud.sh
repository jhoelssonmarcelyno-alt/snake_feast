#!/bin/bash
# Script de refatoração do HUD - Serpent Strike
# Rodar no Git Bash na raiz do projeto:
# bash criar_hud.sh

PROJECT="/f/Documentos/PROJETOS/serpent_strike"
HUD="$PROJECT/lib/overlays/hud"

echo "📁 Criando pasta $HUD..."
mkdir -p "$HUD"

# ─────────────────────────────────────────────────────────────
# 1. hud_widgets.dart — HudCard e HudStat
# ─────────────────────────────────────────────────────────────
cat > "$HUD/hud_widgets.dart" << 'DART'
// lib/overlays/hud/hud_widgets.dart
import 'package:flutter/material.dart';

class HudCard extends StatelessWidget {
  final List<Widget> children;
  const HudCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );
}

class HudStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;
  final Color valueColor;

  const HudStat({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: iconColor, size: 10),
            const SizedBox(width: 3),
            Text(label,
                style: const TextStyle(
                  color: Color(0xFF546E7A),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  decoration: TextDecoration.none,
                )),
          ]),
          const SizedBox(height: 1),
          Text(value,
              style: TextStyle(
                color: valueColor,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                height: 1.0,
                decoration: TextDecoration.none,
              )),
        ],
      );
}
DART

echo "✅ hud_widgets.dart criado"

# ─────────────────────────────────────────────────────────────
# 2. hud_snake_counter.dart
# ─────────────────────────────────────────────────────────────
cat > "$HUD/hud_snake_counter.dart" << 'DART'
// lib/overlays/hud/hud_snake_counter.dart
import 'package:flutter/material.dart';

class HudSnakeCounter extends StatelessWidget {
  final int alive;
  final int total;

  const HudSnakeCounter({super.key, required this.alive, required this.total});

  @override
  Widget build(BuildContext context) {
    final double ratio = total > 0 ? alive / total : 0.0;

    final Color barColor = ratio > 0.66
        ? const Color(0xFF69FF47)
        : ratio > 0.33
            ? const Color(0xFFFFD600)
            : const Color(0xFFFF5252);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐍',
                style: TextStyle(fontSize: 10, decoration: TextDecoration.none)),
            const SizedBox(width: 4),
            const Text('COBRAS',
                style: TextStyle(
                  color: Color(0xFF546E7A),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  decoration: TextDecoration.none,
                )),
            const SizedBox(width: 6),
            Text('$alive',
                style: TextStyle(
                  color: barColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  decoration: TextDecoration.none,
                )),
            Text(' / $total',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.40),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                  decoration: TextDecoration.none,
                )),
          ],
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: 110,
          height: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              children: [
                Container(color: Colors.white.withValues(alpha: 0.10)),
                FractionallySizedBox(
                  widthFactor: ratio.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: barColor.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
DART

echo "✅ hud_snake_counter.dart criado"

# ─────────────────────────────────────────────────────────────
# 3. hud_battle_timer.dart
# ─────────────────────────────────────────────────────────────
cat > "$HUD/hud_battle_timer.dart" << 'DART'
// lib/overlays/hud/hud_battle_timer.dart
import 'package:flutter/material.dart';

class HudBattleTimer extends StatelessWidget {
  final String timerText;
  final int phase; // 0=normal, 1=aviso, 2=perigo
  final bool inGrace;
  final AnimationController pulseCtrl;

  const HudBattleTimer({
    super.key,
    required this.timerText,
    required this.phase,
    required this.inGrace,
    required this.pulseCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final Color timerColor = switch (phase) {
      1 => const Color(0xFFFFD600),
      2 => const Color(0xFFFF3D00),
      _ => const Color(0xFF00E5FF),
    };

    Widget timerWidget = Text(
      timerText,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        letterSpacing: 3,
        height: 1.0,
        color: timerColor,
        decoration: TextDecoration.none,
        shadows: [
          Shadow(
            color: timerColor.withValues(alpha: phase == 2 ? 0.8 : 0.4),
            blurRadius: phase == 2 ? 16 : 8,
          ),
        ],
      ),
    );

    if (phase == 2) {
      timerWidget = AnimatedBuilder(
        animation: pulseCtrl,
        builder: (_, child) => Opacity(
          opacity: 0.6 + pulseCtrl.value * 0.4,
          child: child,
        ),
        child: timerWidget,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withValues(alpha: 0.35),
        border: Border.all(
          color: timerColor.withValues(alpha: phase == 2 ? 0.8 : 0.3),
          width: phase == 2 ? 1.5 : 1.0,
        ),
        boxShadow: phase >= 1
            ? [
                BoxShadow(
                  color: timerColor.withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            inGrace ? Icons.shield_rounded : Icons.compress_rounded,
            color: timerColor.withValues(alpha: 0.85),
            size: 14,
          ),
          const SizedBox(width: 6),
          timerWidget,
          if (inGrace) ...[
            const SizedBox(width: 6),
            Text(
              'GRAÇA',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: timerColor.withValues(alpha: 0.55),
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
DART

echo "✅ hud_battle_timer.dart criado"

# ─────────────────────────────────────────────────────────────
# 4. hud_boost_button.dart
# ─────────────────────────────────────────────────────────────
cat > "$HUD/hud_boost_button.dart" << 'DART'
// lib/overlays/hud/hud_boost_button.dart
import 'package:flutter/material.dart';

class HudBoostButton extends StatelessWidget {
  final bool isPressed;
  final bool isBoosting;
  final void Function(PointerDownEvent) onDown;
  final void Function(PointerUpEvent) onUp;
  final void Function(PointerCancelEvent) onCancel;

  static const double size = 76.0;

  const HudBoostButton({
    super.key,
    required this.isPressed,
    required this.isBoosting,
    required this.onDown,
    required this.onUp,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: onDown,
      onPointerUp: onUp,
      onPointerCancel: onCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: isPressed ? size - 4 : size,
        height: isPressed ? size - 4 : size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isBoosting
              ? const Color(0xFF00E5FF).withValues(alpha: 0.30)
              : Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: isBoosting
                ? const Color(0xFF00E5FF)
                : Colors.white.withValues(alpha: 0.30),
            width: isBoosting ? 2.5 : 1.5,
          ),
          boxShadow: isBoosting
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flash_on_rounded,
              color: isBoosting
                  ? const Color(0xFF00E5FF)
                  : Colors.white.withValues(alpha: 0.5),
              size: 28,
            ),
            Text(
              'BOOST',
              style: TextStyle(
                color: isBoosting
                    ? const Color(0xFF00E5FF)
                    : Colors.white.withValues(alpha: 0.4),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
DART

echo "✅ hud_boost_button.dart criado"

# ─────────────────────────────────────────────────────────────
# 5. hud_joystick.dart
# ─────────────────────────────────────────────────────────────
cat > "$HUD/hud_joystick.dart" << 'DART'
// lib/overlays/hud/hud_joystick.dart
import 'package:flutter/material.dart';

class HudJoystick extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final Offset? origin;
  final Offset? thumb;
  final void Function(PointerDownEvent) onDown;
  final void Function(PointerMoveEvent) onMove;
  final void Function(PointerUpEvent) onUp;
  final void Function(PointerCancelEvent) onCancel;

  static const double baseRadius = 55.0;
  static const double thumbRadius = 24.0;

  const HudJoystick({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.origin,
    required this.thumb,
    required this.onDown,
    required this.onMove,
    required this.onUp,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      width: screenWidth * 0.5,
      height: screenHeight,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: onDown,
        onPointerMove: onMove,
        onPointerUp: onUp,
        onPointerCancel: onCancel,
        child: Stack(clipBehavior: Clip.none, children: [
          // Hint quando joystick está inativo
          if (origin == null)
            Positioned(
              left: screenWidth * 0.10,
              bottom: screenHeight * 0.10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(Icons.gamepad_outlined,
                        color: Colors.white.withValues(alpha: 0.12), size: 20),
                  ),
                  const SizedBox(height: 5),
                  Text('Arraste aqui',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.09),
                        fontSize: 9,
                        letterSpacing: 1.5,
                        decoration: TextDecoration.none,
                      )),
                ],
              ),
            ),

          // Base do joystick
          if (origin != null)
            Positioned(
              left: origin!.dx - baseRadius,
              top: origin!.dy - baseRadius,
              child: Container(
                width: baseRadius * 2,
                height: baseRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1.5,
                  ),
                ),
              ),
            ),

          // Thumb do joystick
          if (thumb != null)
            Positioned(
              left: thumb!.dx - thumbRadius,
              top: thumb!.dy - thumbRadius,
              child: Container(
                width: thumbRadius * 2,
                height: thumbRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.38),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.80),
                    width: 2,
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
DART

echo "✅ hud_joystick.dart criado"

# ─────────────────────────────────────────────────────────────
# 6. hud_stats_card.dart
# ─────────────────────────────────────────────────────────────
cat > "$HUD/hud_stats_card.dart" << 'DART'
// lib/overlays/hud/hud_stats_card.dart
import 'package:flutter/material.dart';
import 'hud_widgets.dart';
import 'hud_snake_counter.dart';

class HudStatsCard extends StatelessWidget {
  final int kills;
  final int length;
  final int highScore;
  final int level;
  final int coins;
  final int diamonds;
  final int revives;
  final int aliveSnakes;
  final int totalSnakes;

  const HudStatsCard({
    super.key,
    required this.kills,
    required this.length,
    required this.highScore,
    required this.level,
    required this.coins,
    required this.diamonds,
    required this.revives,
    required this.aliveSnakes,
    required this.totalSnakes,
  });

  Color _levelColor(int lvl) {
    if (lvl >= 50) return const Color(0xFF00E5FF);
    if (lvl >= 30) return const Color(0xFFE040FB);
    if (lvl >= 20) return const Color(0xFFFFD600);
    if (lvl >= 10) return const Color(0xFFB0BEC5);
    return const Color(0xFFCD7F32);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(right: 12, top: 10),
          child: HudCard(children: [
            // Linha 1: KILLS / TAMANHO / RECORDE
            Row(mainAxisSize: MainAxisSize.min, children: [
              HudStat(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFFF5252),
                label: 'KILLS',
                value: '$kills',
                valueColor: const Color(0xFFFF5252),
              ),
              const SizedBox(width: 12),
              HudStat(
                icon: Icons.linear_scale_rounded,
                iconColor: const Color(0xFF69F0AE),
                label: 'TAMANHO',
                value: '$length',
                valueColor: const Color(0xFF69F0AE),
              ),
              const SizedBox(width: 12),
              HudStat(
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFFFFD700),
                label: 'RECORDE',
                value: '$highScore',
                valueColor: const Color(0xFFFFD700),
              ),
            ]),
            const SizedBox(height: 6),
            // Linha 2: LEVEL / MOEDAS / DIAMANTES / VIDAS
            Row(mainAxisSize: MainAxisSize.min, children: [
              HudStat(
                icon: Icons.star_rounded,
                iconColor: _levelColor(level),
                label: 'LEVEL',
                value: '$level',
                valueColor: _levelColor(level),
              ),
              const SizedBox(width: 12),
              HudStat(
                icon: Icons.monetization_on_rounded,
                iconColor: const Color(0xFFFFD600),
                label: 'MOEDAS',
                value: '$coins',
                valueColor: const Color(0xFFFFD600),
              ),
              const SizedBox(width: 12),
              HudStat(
                icon: Icons.diamond_rounded,
                iconColor: const Color(0xFF00E5FF),
                label: 'DIAMANTES',
                value: '$diamonds',
                valueColor: const Color(0xFF00E5FF),
              ),
              const SizedBox(width: 12),
              HudStat(
                icon: Icons.favorite_rounded,
                iconColor: const Color(0xFF2ECC71),
                label: 'VIDAS',
                value: '$revives',
                valueColor: const Color(0xFF2ECC71),
              ),
            ]),
            const SizedBox(height: 6),
            // Linha 3: Contador de cobras
            HudSnakeCounter(alive: aliveSnakes, total: totalSnakes),
          ]),
        ),
      ),
    );
  }
}
DART

echo "✅ hud_stats_card.dart criado"

# ─────────────────────────────────────────────────────────────
# 7. hud_overlay.dart — Widget principal
# ─────────────────────────────────────────────────────────────
cat > "$HUD/hud_overlay.dart" << 'DART'
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
    WidgetsBinding.instance.addPostFrameCallback(_tick);
  }

  void _tick(Duration _) {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback(_tick);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Joystick handlers ───────────────────────────────────────
  void _onJoyDown(PointerDownEvent e) {
    if (_joystickPointer != null) return;
    _joystickPointer = e.pointer;
    setState(() {
      _joystickOrigin = e.localPosition;
      _joystickThumb = e.localPosition;
    });
    widget.engine.player.setJoystick(e.localPosition, e.localPosition);
  }

  void _onJoyMove(PointerMoveEvent e) {
    if (e.pointer != _joystickPointer || _joystickOrigin == null) return;
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
    if (e.pointer != _joystickPointer) return;
    _joystickPointer = null;
    setState(() {
      _joystickOrigin = null;
      _joystickThumb = null;
    });
    widget.engine.player.clearJoystick();
  }

  void _onJoyCancel(PointerCancelEvent e) {
    if (e.pointer != _joystickPointer) return;
    _joystickPointer = null;
    setState(() {
      _joystickOrigin = null;
      _joystickThumb = null;
    });
    widget.engine.player.clearJoystick();
  }

  // ── Boost handlers ──────────────────────────────────────────
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
                  child: Center(
                    child: Text('PAUSE',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
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
                          color: isRecord
                              ? const Color(0xFFFFD600)
                              : Colors.white,
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
DART

echo "✅ hud_overlay.dart criado"

# ─────────────────────────────────────────────────────────────
# Resumo final
# ─────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════"
echo "✅ Refatoração concluída!"
echo "Arquivos criados em: $HUD"
echo ""
echo "⚠️  Lembre de:"
echo "  1. Atualizar os imports em main.dart ou onde o HudOverlay era importado:"
echo "     import 'overlays/hud/hud_overlay.dart';"
echo "  2. Deletar o arquivo antigo lib/overlays/hud.dart"
echo "════════════════════════════════════════"