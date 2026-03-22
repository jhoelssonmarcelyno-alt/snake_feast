// lib/overlays/hud.dart
import 'package:flutter/material.dart';
import '../game/snake_engine.dart';
import '../services/score_service.dart';
import '../utils/constants.dart';

class HudOverlay extends StatefulWidget {
  final SnakeEngine engine;
  const HudOverlay({super.key, required this.engine});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  Offset? _joystickOrigin;
  Offset? _joystickThumb;
  int? _joystickPointer;

  static const double _baseRadius = 55.0;
  static const double _thumbRadius = 24.0;
  bool _boostPressed = false;

  static const _base = TextStyle(
    decoration: TextDecoration.none,
    decorationColor: Colors.transparent,
    decorationThickness: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_tick);
  }

  void _tick(Duration _) {
    if (!mounted) return;
    if (mounted) setState(() {});
    if (mounted) WidgetsBinding.instance.addPostFrameCallback(_tick);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent e) {
    if (_joystickPointer != null) return;
    _joystickPointer = e.pointer;
    setState(() {
      _joystickOrigin = e.localPosition;
      _joystickThumb = e.localPosition;
    });
    widget.engine.player.setJoystick(e.localPosition, e.localPosition);
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (e.pointer != _joystickPointer || _joystickOrigin == null) return;
    final delta = e.localPosition - _joystickOrigin!;
    final dist = delta.distance;
    final clamped = dist <= _baseRadius
        ? e.localPosition
        : _joystickOrigin! + Offset(delta.dx, delta.dy) / dist * _baseRadius;
    setState(() => _joystickThumb = clamped);
    widget.engine.player.setJoystick(_joystickOrigin!, e.localPosition);
  }

  void _onPointerUp(PointerUpEvent e) {
    if (e.pointer != _joystickPointer) return;
    _joystickPointer = null;
    setState(() {
      _joystickOrigin = null;
      _joystickThumb = null;
    });
    widget.engine.player.clearJoystick();
  }

  void _onPointerCancel(PointerCancelEvent e) {
    if (e.pointer != _joystickPointer) return;
    _joystickPointer = null;
    setState(() {
      _joystickOrigin = null;
      _joystickThumb = null;
    });
    widget.engine.player.clearJoystick();
  }

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
    final score = widget.engine.player.score;
    final kills = widget.engine.player.kills;
    final length = widget.engine.player.length;
    final hs = ScoreService.instance.highScore;
    final coins = ScoreService.instance.coins;
    final diamonds = ScoreService.instance.diamonds;
    final revives = ScoreService.instance.revives;
    final isRecord = score >= hs && score > 0;
    final size = MediaQuery.of(context).size;
    final isBoosting = widget.engine.player.isBoosting;

    const double boostSize = 76.0;
    const double boostRight = 24.0;
    const double boostBottom = 24.0;

    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: _base,
        child: Stack(
          children: [
            // ── Área do joystick (metade esquerda) ────────────
            Positioned(
              left: 0,
              top: 0,
              width: size.width * 0.5,
              height: size.height,
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _onPointerDown,
                onPointerMove: _onPointerMove,
                onPointerUp: _onPointerUp,
                onPointerCancel: _onPointerCancel,
                child: Stack(clipBehavior: Clip.none, children: [
                  // Hint joystick
                  if (_joystickOrigin == null)
                    Positioned(
                      left: size.width * 0.10,
                      bottom: size.height * 0.10,
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
                            child: Icon(
                              Icons.gamepad_outlined,
                              color: Colors.white.withValues(alpha: 0.12),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Arraste aqui',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.09),
                              fontSize: 9,
                              letterSpacing: 1.5,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Base do joystick
                  if (_joystickOrigin != null)
                    Positioned(
                      left: _joystickOrigin!.dx - _baseRadius,
                      top: _joystickOrigin!.dy - _baseRadius,
                      child: Container(
                        width: _baseRadius * 2,
                        height: _baseRadius * 2,
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
                  if (_joystickThumb != null)
                    Positioned(
                      left: _joystickThumb!.dx - _thumbRadius,
                      top: _joystickThumb!.dy - _thumbRadius,
                      child: Container(
                        width: _thumbRadius * 2,
                        height: _thumbRadius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              const Color(0xFF00E5FF).withValues(alpha: 0.38),
                          border: Border.all(
                            color:
                                const Color(0xFF00E5FF).withValues(alpha: 0.80),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ]),
              ),
            ),

            // ── BOOST — canto inferior direito ────────────────
            Positioned(
              right: boostRight,
              bottom: boostBottom,
              child: Listener(
                onPointerDown: _onBoostDown,
                onPointerUp: _onBoostUp,
                onPointerCancel: _onBoostCancel,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  width: _boostPressed ? boostSize - 4 : boostSize,
                  height: _boostPressed ? boostSize - 4 : boostSize,
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
                              color: const Color(0xFF00E5FF)
                                  .withValues(alpha: 0.4),
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
              ),
            ),

            // ── PAUSE — card estilo boost ─────────────────────
            Positioned(
              right: boostRight + (boostSize - 64) / 2,
              bottom: boostBottom + boostSize + 12.0,
              child: GestureDetector(
                onTap: () {
                  widget.engine.pauseEngine();
                  widget.engine.overlays.remove(kOverlayHud);
                  widget.engine.overlays.add(kOverlayPause);
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
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'PAUSE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        decoration: TextDecoration.none,
                      ),
                    ),
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
                    Text(
                      '$score',
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
                                ? const Color(0xFFFFD600).withValues(alpha: 0.6)
                                : Colors.black.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    if (isRecord)
                      const Text(
                        '● RECORDE',
                        style: TextStyle(
                          color: Color(0xFFFFD600),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          decoration: TextDecoration.none,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Stats top right ────────────────────────────────
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12, top: 10),
                  child: _HudCard(children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      _HudStat(
                        icon: Icons.local_fire_department_rounded,
                        iconColor: const Color(0xFFFF5252),
                        label: 'KILLS',
                        value: '$kills',
                        valueColor: const Color(0xFFFF5252),
                      ),
                      const SizedBox(width: 12),
                      _HudStat(
                        icon: Icons.linear_scale_rounded,
                        iconColor: const Color(0xFF69F0AE),
                        label: 'TAMANHO',
                        value: '$length',
                        valueColor: const Color(0xFF69F0AE),
                      ),
                      const SizedBox(width: 12),
                      _HudStat(
                        icon: Icons.emoji_events_rounded,
                        iconColor: const Color(0xFFFFD700),
                        label: 'RECORDE',
                        value: '$hs',
                        valueColor: const Color(0xFFFFD700),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      _HudStat(
                        icon: Icons.monetization_on_rounded,
                        iconColor: const Color(0xFFFFD600),
                        label: 'MOEDAS',
                        value: '$coins',
                        valueColor: const Color(0xFFFFD600),
                      ),
                      const SizedBox(width: 12),
                      _HudStat(
                        icon: Icons.diamond_rounded,
                        iconColor: const Color(0xFF00E5FF),
                        label: 'DIAMANTES',
                        value: '$diamonds',
                        valueColor: const Color(0xFF00E5FF),
                      ),
                      const SizedBox(width: 12),
                      _HudStat(
                        icon: Icons.favorite_rounded,
                        iconColor: const Color(0xFF2ECC71),
                        label: 'VIDAS',
                        value: '$revives',
                        valueColor: const Color(0xFF2ECC71),
                      ),
                    ]),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudCard extends StatelessWidget {
  final List<Widget> children;
  const _HudCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );
}

class _HudStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;
  final Color valueColor;
  const _HudStat({
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
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF546E7A),
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                decoration: TextDecoration.none,
              ),
            ),
          ]),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1.0,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      );
}
