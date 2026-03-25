import 'package:flutter/material.dart';
import '../snake_engine.dart';
import '../../services/score_service.dart';
import '../../services/xp_reward.dart';
import '../../utils/constants.dart';

// widgets
import '../widgets/win/stat_row.dart';
import '../widgets/win/divider.dart';
import '../widgets/win/xp_breakdown.dart';
import '../widgets/win/rank_progress.dart';
import '../widgets/win/win_button.dart';

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
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );

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
    const goldColor = Color(0xFFFFD700);
    const bgColor = Color(0xFF0A1628);

    final svc = ScoreService.instance;
    final reward = svc.lastXpReward;

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
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HEADER
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      'BOOYAH!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        StatRow(
                          icon: Icons.stars,
                          color: Colors.cyan,
                          label: 'PONTUAÇÃO',
                          value: '${widget.game.player.score}',
                        ),
                        const SizedBox(height: 10),
                        if (reward != null) ...[
                          const DividerLabel(label: 'XP GANHO'),
                          XpBreakdown(reward: reward),
                        ],
                        const SizedBox(height: 10),
                        RankProgress(
                          rank: svc.currentRank,
                          next: svc.nextRank,
                          progress: svc.rankProgress,
                          totalXP: svc.totalXP,
                        ),
                        const SizedBox(height: 16),
                        WinButton(
                          label: 'JOGAR NOVAMENTE',
                          icon: Icons.replay,
                          color: goldColor,
                          textColor: Colors.black,
                          onTap: _playAgain,
                        ),
                        const SizedBox(height: 10),
                        WinButton(
                          label: 'MENU',
                          icon: Icons.home,
                          color: Colors.blueGrey,
                          textColor: Colors.white,
                          outlined: true,
                          onTap: _goMenu,
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
