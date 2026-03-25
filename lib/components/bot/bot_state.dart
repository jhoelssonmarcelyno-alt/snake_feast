import 'package:flame/components.dart';
import 'dart:ui';
import '../../utils/constants.dart';

mixin BotState {
  bool isAlive = false;
  int score = 0;
  int level = 1;
  int starsForLevel = 0;
  int foodForLevel = 0;
  int growAccum = 0;

  bool isBoosting = false;
  double boostTimer = 0.0;
  double boostDrainAccum = 0.0;

  void resetState() {
    score = 0;
    level = 1;
    starsForLevel = 0;
    foodForLevel = 0;
    growAccum = 0;
    isBoosting = false;
    boostTimer = 0;
    boostDrainAccum = 0;
  }
}
