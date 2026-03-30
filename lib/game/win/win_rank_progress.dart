import 'package:flutter/material.dart';
import '../../services/rank_system.dart';
import '../../services/wins_service.dart';

class WinRankProgress extends StatefulWidget {
  final RankInfo rank;
  final RankInfo? next;
  final double progress;
  final int totalXP;

  const WinRankProgress({
    super.key,
    required this.rank,
    required this.next,
    required this.progress,
    required this.totalXP,
  });

  @override
  State<WinRankProgress> createState() => _WinRankProgressState();
}

class _WinRankProgressState extends State<WinRankProgress> {
  int _totalWins = 0;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadWins();
  }
  
  Future<void> _loadWins() async {
    final wins = await WinsService().totalWins;
    if (mounted) {
      setState(() {
        _totalWins = wins;
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFF0D1F38),
          border: Border.all(
              color: widget.rank.color.withValues(alpha: 0.30), width: 1),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white54,
            ),
          ),
        ),
      );
    }
    
    final currentRank = RankSystem.getRankForWins(_totalWins);
    final nextRank = RankSystem.getNextRank(currentRank);
    final progress = RankSystem.rankProgress(_totalWins);
    
    return Container(
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
                value: progress,
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
            const SizedBox(height: 4),
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
    );
  }
}
