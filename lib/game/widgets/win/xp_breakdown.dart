import 'package:flutter/material.dart';
import '../../../services/xp_reward.dart';
import 'xp_line.dart';

class XpBreakdown extends StatelessWidget {
  final XpReward reward;

  const XpBreakdown({super.key, required this.reward});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        XpLine(label: 'Score', value: reward.xpFromScore),
        XpLine(label: 'Kills', value: reward.xpFromKills),
        XpLine(label: 'Level', value: reward.xpFromLevel),
        XpLine(label: 'Tempo', value: reward.xpFromSurvival),
      ],
    );
  }
}
