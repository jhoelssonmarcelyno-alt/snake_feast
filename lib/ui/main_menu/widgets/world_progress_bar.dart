import 'package:flutter/material.dart';
import '../../../services/world_progress_service.dart';

class WorldProgressBar extends StatelessWidget {
  final int worldIndex;
  final double scale;

  const WorldProgressBar({
    super.key,
    required this.worldIndex,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final wins = WorldProgressService().getWorldWins(worldIndex);
    final progress = WorldProgressService().getWorldProgress(worldIndex);
    final needed = WorldProgressService().getWinsNeededForNext(worldIndex);
    final isUnlocked = WorldProgressService().isWorldUnlocked(worldIndex);
    
    // Se o mundo não está desbloqueado, mostra cadeado
    if (!isUnlocked) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 4 * scale),
        child: Column(
          children: [
            Icon(
              Icons.lock,
              color: Colors.white38,
              size: 16 * scale,
            ),
            SizedBox(height: 2 * scale),
            Text(
              'BLOQUEADO',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 7 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    
    // Se está desbloqueado, mostra progresso
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4 * scale, vertical: 4 * scale),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$wins',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '/$needed',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 8 * scale,
                ),
              ),
            ],
          ),
          SizedBox(height: 2 * scale),
          Container(
            width: 60 * scale,
            height: 4 * scale,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2 * scale),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2 * scale),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green,
                ),
              ),
            ),
          ),
          if (needed == 0 && worldIndex < 249)
            Padding(
              padding: EdgeInsets.only(top: 2 * scale),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 10 * scale,
              ),
            ),
        ],
      ),
    );
  }
}
