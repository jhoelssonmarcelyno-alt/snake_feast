import 'package:flutter/material.dart';
import '../snake_engine.dart';
import '../../services/score_service.dart';
import '../../services/world_progress_service.dart';
import '../../services/skin_progress_service.dart';
import '../../services/wins_service.dart';
import '../../services/rank_system.dart';
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
  
  bool _isProcessing = false;
  int _worldWins = 0;
  int _skinWins = 0;
  int _nextSkinId = -1;
  bool _nextWorldUnlocked = false;
  bool _nextSkinUnlocked = false;
  int _totalWins = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    
    _recordVictory();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _recordVictory() async {
    if (_isProcessing) return;
    _isProcessing = true;
    
    try {
      final worldIndex = widget.game.selectedWorld;
      final skinIndex = widget.game.skinIndex;
      
      // Registra vitória no serviço de vitórias totais
      await WinsService().addWin();
      
      // Registra vitória no mundo
      await WorldProgressService().recordWin(worldIndex);
      
      // Registra vitória para a skin atual
      await SkinProgressService().recordWinForSkin(skinIndex);
      
      // Atualiza total de vitórias
      _totalWins = await WinsService().totalWins;
      
      // Verifica se o próximo mundo foi desbloqueado
      final nextWorld = WorldProgressService().nextWorldToUnlock;
      _nextWorldUnlocked = nextWorld > worldIndex + 1;
      
      // Verifica se alguma nova skin foi desbloqueada
      final nextSkin = SkinProgressService().nextSkinToUnlock;
      _nextSkinUnlocked = nextSkin > -1;
      _nextSkinId = nextSkin;
      
      // Atualiza contadores
      _worldWins = WorldProgressService().getWorldWins(worldIndex);
      _skinWins = SkinProgressService().getWinsNeededForNextSkin();
      
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Erro ao registrar vitória: $e');
    } finally {
      _isProcessing = false;
    }
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
    const Color progressColor = Color(0xFF4CAF50);
    const Color skinColor = Color(0xFFE040FB);

    final svc = ScoreService.instance;
    final reward = svc.lastXpReward;
    
    final worldIndex = widget.game.selectedWorld;
    final worldProgress = WorldProgressService().getWorldProgress(worldIndex);
    final worldWins = _worldWins;
    final neededWins = 10;
    
    final nextSkinId = _nextSkinId;
    final skinProgress = SkinProgressService().getNextSkinProgress();
    final skinWinsNeeded = _skinWins;
    
    final currentRank = RankSystem.getRankForWins(_totalWins);
    final nextRank = RankSystem.getNextRank(currentRank);
    final rankProgress = RankSystem.rankProgress(_totalWins);

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
                        // Pontuação
                        WinStatRow(
                          icon: Icons.stars_rounded,
                          color: const Color(0xFF00E5FF),
                          label: 'PONTUAÇÃO',
                          value: '${widget.game.player.score}',
                        ),
                        const SizedBox(height: 12),

                        // Barra de progresso do MUNDO
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.public, size: 16, color: Colors.white70),
                                      const SizedBox(width: 4),
                                      Text(
                                        '🌍 MUNDO ${worldIndex + 1}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$worldWins / $neededWins',
                                    style: const TextStyle(
                                      color: goldColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: worldProgress,
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    progressColor,
                                  ),
                                  minHeight: 8,
                                ),
                              ),
                              if (worldProgress >= 1.0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: progressColor,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Mundo ${worldIndex + 2} desbloqueado!',
                                        style: TextStyle(
                                          color: progressColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Faltam ${neededWins - worldWins} vitórias para o próximo mundo',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12),

                        // Barra de progresso da SKIN
                        if (nextSkinId > 0 && nextSkinId < 250)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.palette, size: 16, color: skinColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          '🎨 SKIN ${nextSkinId + 1}',
                                          style: TextStyle(
                                            color: skinColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${10 - skinWinsNeeded} / 10',
                                      style: TextStyle(
                                        color: skinColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: skinProgress,
                                    backgroundColor: Colors.white24,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Color(0xFFE040FB),
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Faltam $skinWinsNeeded vitórias para desbloquear a próxima skin',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 12),

                        if (reward != null) ...[
                          const WinDivider(label: 'XP GANHO'),
                          const SizedBox(height: 6),
                          WinXpBreakdown(reward: reward),
                          const SizedBox(height: 10),
                        ],

                        // Progresso da patente
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFF0D1F38),
                            border: Border.all(
                                color: currentRank.color.withValues(alpha: 0.30), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(currentRank.icon, color: currentRank.color, size: 20),
                                const SizedBox(width: 8),
                                Text(currentRank.name,
                                    style: TextStyle(
                                        color: currentRank.color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const Spacer(),
                                Text('$_totalWins vitórias',
                                    style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.4),
                                        fontSize: 11)),
                              ]),
                              if (nextRank != null) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: rankProgress,
                                    minHeight: 6,
                                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                                    valueColor: AlwaysStoppedAnimation<Color>(currentRank.color),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Próxima: ${nextRank.name}  (${nextRank.winsRequired} vitórias)',
                                  style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.35),
                                      fontSize: 10),
                                ),
                                Text(
                                  'Faltam ${nextRank.winsRequired - _totalWins} vitórias',
                                  style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500),
                                ),
                              ] else
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text('Patente máxima atingida!',
                                      style: TextStyle(
                                          color: currentRank.color.withValues(alpha: 0.7),
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic)),
                                ),
                            ],
                          ),
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
