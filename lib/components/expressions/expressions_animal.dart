import '../../components/animal_skins/heads/head_registry.dart';
// lib/components/expressions/expressions_animal.dart
import 'dart:ui';
import 'package:flutter/material.dart' show Color;

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

void renderAnimalFront(Canvas canvas, String animalType, double r, double t, Color body, Color dark) {
  final head = HeadRegistry.get(animalType);
  head.paintFront(canvas, r, t, body, dark);
}
