// lib/game/win/win_overlay.dart
import 'package:flutter/material.dart';
import '../snake_engine.dart';
import '../../services/score_service.dart';
import '../../utils/constants.dart';
import 'win_widgets.dart';
import 'win_xp_breakdown.dart';
import 'win_rank_progress.dart';

class WinOverlay extends StatefulWidget {
  final SnakeEngine game;
  const WinOverlay({super.key, required this.game});

  @override
  State<WinOverlay> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<WinOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _goMenu() {
    widget.game.overlays.remove('WinOverlay');
    widget.game.overlays.add(kOverlayMainMenu);
    widget.game.pauseEngine();
  }

  void _playAgain() {
    widget.game.overlays.remove('WinOverlay');
    widget.game.restartGame();
  }

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFFFD700);
    const Color bgColor = Color(0xFF0A1628);

    final svc = ScoreService.instance;
    final reward = svc.lastXpReward;
    final rank = svc.currentRank;
    final next = svc.nextRank;
    final progress = svc.rankProgress;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.88,
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: bgColor,
                border: Border.all(color: goldColor, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: goldColor.withValues(alpha: 0.4),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Cabeçalho dourado ──────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(22)),
                      gradient: LinearGradient(colors: [
                        Color(0xFFB8860B),
                        Color(0xFFFFD700),
                        Color(0xFFB8860B),
                      ]),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events,
                            color: Color(0xFF3D2000), size: 52),
                        SizedBox(height: 6),
                        Text('BOOYAH!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF3D2000),
                              letterSpacing: 6,
                              fontStyle: FontStyle.italic,
                            )),
                        SizedBox(height: 2),
                        Text('Você é o último sobrevivente!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5C3000),
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),

                  // ── Corpo ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        WinStatRow(
                          icon: Icons.stars_rounded,
                          color: const Color(0xFF00E5FF),
                          label: 'PONTUAÇÃO',
                          value: '${widget.game.player.score}',
                        ),
                        const SizedBox(height: 8),

                        if (reward != null) ...[
                          const WinDivider(label: 'XP GANHO'),
                          const SizedBox(height: 6),
                          WinXpBreakdown(reward: reward),
                          const SizedBox(height: 10),
                        ],

                        WinRankProgress(
                          rank: rank,
                          next: next,
                          progress: progress,
                          totalXP: svc.totalXP,
                        ),
                        const SizedBox(height: 16),

                        WinButton(
                          label: 'JOGAR NOVAMENTE',
                          icon: Icons.replay_rounded,
                          color: goldColor,
                          textColor: const Color(0xFF3D2000),
                          onTap: _playAgain,
                        ),
                        const SizedBox(height: 10),
                        WinButton(
                          label: 'MENU PRINCIPAL',
                          icon: Icons.home_rounded,
                          color: const Color(0xFF1E3A5F),
                          textColor: Colors.white,
                          onTap: _goMenu,
                          outlined: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
