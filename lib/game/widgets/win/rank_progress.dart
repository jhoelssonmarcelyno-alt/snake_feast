import 'package:flutter/material.dart';

class RankProgress extends StatelessWidget {
  final dynamic rank;
  final dynamic next;
  final double progress;
  final int totalXP;

  const RankProgress({
    super.key,
    required this.rank,
    required this.next,
    required this.progress,
    required this.totalXP,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(rank.name),
        LinearProgressIndicator(value: progress),
        Text('$totalXP XP'),
      ],
    );
  }
}
