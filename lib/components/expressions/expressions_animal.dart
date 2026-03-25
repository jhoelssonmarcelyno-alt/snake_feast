// lib/components/expressions/expressions_animal.dart
import 'dart:ui';
import 'package:flutter/material.dart' show Color;
import '../animal_skins.dart';

const _animalSkins = {
  'gato', 'cachorro', 'leao', 'vaca', 'coelho',
  'peixe', 'dragao_animal', 'raposa',
};

bool isAnimalSkin(String skinId) => _animalSkins.contains(skinId);

void renderAnimalBackLayer(
  Canvas canvas,
  String skinId,
  double hr,
  double t,
  Color bodyColor,
  Color bodyColorDark,
) {
  renderAnimalBackLayer(canvas, skinId, hr, t, bodyColor, bodyColorDark);
}

void renderAnimalFrontLayer(
  Canvas canvas,
  String skinId,
  double hr,
  double t,
  Color bodyColor,
  Color bodyColorDark,
) {
  renderAnimalFront(canvas, skinId, hr, t, bodyColor, bodyColorDark);
}
