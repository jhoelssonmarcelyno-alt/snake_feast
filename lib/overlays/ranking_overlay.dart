import 'package:flutter/material.dart';
import '../game/snake_engine.dart';
import '../services/score_service.dart';
import '../services/rank_system.dart';
import '../services/wins_service.dart';
import '../utils/constants.dart';

class RankingOverlay extends StatefulWidget {
  final SnakeEngine engine;
  final VoidCallback onClose;
  
  const RankingOverlay({
    super.key,
    required this.engine,
    required this.onClose,
  });

  @override
  State<RankingOverlay> createState() => _RankingOverlayState();
}

class _RankingOverlayState extends State<RankingOverlay> {
  List<Map<String, dynamic>> _ranking = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  Future<void> _loadRanking() async {
    setState(() => _isLoading = true);
    
    final wins = await WinsService().totalWins;
    final currentRank = RankSystem.getRankForWins(wins);
    final skinIndex = ScoreService.instance.selectedSkinIndex;
    final skin = kPlayerSkins[skinIndex.clamp(0, kPlayerSkins.length - 1)];
    
    _ranking = [
      {
        'name': ScoreService.instance.playerName,
        'wins': wins,
        'rank': currentRank.name,
        'color': skin.accentColor,
        'isPlayer': true,
      },
      {
        'name': 'Serpente Suprema',
        'wins': (wins * 0.8).toInt(),
        'rank': RankSystem.getRankForWins((wins * 0.8).toInt()).name,
        'color': const Color(0xFFFFD600),
        'isPlayer': false,
      },
      {
        'name': 'Dragão de Fogo',
        'wins': (wins * 0.6).toInt(),
        'rank': RankSystem.getRankForWins((wins * 0.6).toInt()).name,
        'color': const Color(0xFFFF6B6B),
        'isPlayer': false,
      },
      {
        'name': 'Cobra de Gelo',
        'wins': (wins * 0.4).toInt(),
        'rank': RankSystem.getRankForWins((wins * 0.4).toInt()).name,
        'color': const Color(0xFF80DEEA),
        'isPlayer': false,
      },
      {
        'name': 'Víbora da Tempestade',
        'wins': (wins * 0.2).toInt(),
        'rank': RankSystem.getRankForWins((wins * 0.2).toInt()).name,
        'color': const Color(0xFFE040FB),
        'isPlayer': false,
      },
    ];
    
    _ranking.sort((a, b) => b['wins'].compareTo(a['wins']));
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final skinIndex = ScoreService.instance.selectedSkinIndex;
    final skin = kPlayerSkins[skinIndex.clamp(0, kPlayerSkins.length - 1)];
    
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: skin.accentColor, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cabeçalho
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: skin.accentColor.withOpacity(0.2),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.leaderboard,
                          color: skin.accentColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'RANKING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Lista de ranking
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFD600),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _ranking.length,
                        itemBuilder: (context, index) {
                          final entry = _ranking[index];
                          final isPlayer = entry['isPlayer'] as bool;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isPlayer
                                  ? entry['color'].withOpacity(0.2)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(10),
                              border: isPlayer
                                  ? Border.all(color: entry['color'], width: 1)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                // Posição
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isPlayer
                                        ? entry['color']
                                        : Colors.white12,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: isPlayer
                                            ? Colors.black
                                            : Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                
                                // Nome e patente
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry['name'],
                                        style: TextStyle(
                                          color: isPlayer
                                              ? entry['color']
                                              : Colors.white,
                                          fontSize: 14,
                                          fontWeight: isPlayer
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        entry['rank'],
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Vitórias
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${entry['wins']}',
                                      style: TextStyle(
                                        color: isPlayer
                                            ? entry['color']
                                            : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'vitórias',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              
              // Rodapé
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: widget.onClose,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('FECHAR'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
