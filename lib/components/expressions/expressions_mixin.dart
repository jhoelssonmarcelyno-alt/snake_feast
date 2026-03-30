import '../../components/animal_skins/heads/head_registry.dart';
// lib/components/expressions/expressions_mixin.dart
import 'dart:ui';
import 'package:flutter/material.dart' show Color;
// ✅ Ocultamos a função repetida para o Dart usar a que vem de expressions_animal
import '../animal_skins.dart' hide renderAnimalBackLayer;
import 'expressions_animal.dart';
import 'expressions_skins.dart';

mixin PlayerExpressions {
  Color get skinBodyColor;
  Color get skinBodyColorDark;
  Color get skinAccentColor;
  String get skinId;
  Paint get eyeWhite;
  Paint get eyePupil;

  (double, double) headShape() {
    final animalShape = animalHeadShape(skinId);
    if (animalShape != (2.2, 1.9)) return animalShape;
    return switch (skinId) {
      'classic' => (2.2, 1.9),
      'hot' => (2.4, 1.7),
      'sorriso' => (2.0, 2.2),
      'veneno' => (2.6, 1.6),
      'fantasma' => (1.9, 2.1),
      'piranha' => (2.8, 1.5),
      'lava' => (2.3, 1.8),
      'alien' => (2.0, 2.3),
      'lili' => (2.1, 2.0),
      'robo' => (2.4, 2.0),
      'serpente' => (2.7, 1.6),
      'dragao' => (2.5, 1.8),
      'galaxia' => (2.1, 2.1),
      'neon' => (2.3, 1.7),
      'ouro' => (2.2, 2.0),
      _ => (2.2, 1.9),
    };
  }

  void renderAnimalBack(Canvas canvas, double hr, double t) {
    // Agora o Dart sabe que esta função vem do expressions_animal.dart
    renderAnimalBackLayer(
        canvas, skinId, hr, t, skinBodyColor, skinBodyColorDark);
  }

  void renderExpression(Canvas canvas, double hr, double t) {
    if (isAnimalSkin(skinId)) {
      renderAnimalFrontLayer(
          canvas, skinId, hr, t, skinBodyColor, skinBodyColorDark);
      return;
    }
    renderSkinExpression(
      canvas,
      skinId,
      hr,
      t,
      eyeWhite,
      eyePupil,
      skinBodyColor,
      skinBodyColorDark,
      skinAccentColor,
    );
  }
}

(double, double) animalHeadShape(String animalType) {
  switch (animalType) {
    case 'cat': return (2.0, 2.2);
    case 'dog': return (2.2, 2.3);
    case 'lion': return (2.6, 2.5);
    case 'rabbit': return (1.9, 2.4);
    case 'fox': return (2.5, 2.0);
    case 'dragon': return (2.6, 2.0);
    case 'wolf': return (2.4, 2.2);
    case 'tiger': return (2.5, 2.3);
    case 'bear': return (2.7, 2.4);
    case 'eagle': return (2.3, 1.9);
    default: return (2.2, 1.9);
  }
}
