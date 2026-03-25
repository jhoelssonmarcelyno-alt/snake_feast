import 'package:flutter/material.dart';

class HudController {
  final score = ValueNotifier<int>(0);
  final kills = ValueNotifier<int>(0);
  final snakesAlive = ValueNotifier<int>(0);
  final time = ValueNotifier<int>(0);
  final boost = ValueNotifier<double>(1.0);

  void dispose() {
    score.dispose();
    kills.dispose();
    snakesAlive.dispose();
    time.dispose();
    boost.dispose();
  }
}
