// lib/components/animal_skins/heads/heads.dart
// Dispatcher de cabeças — chama o arquivo correto por skinId.
import 'dart:ui';
import 'package:flutter/material.dart' show Color;
import 'cat.dart';
import 'dog.dart';
import 'lion.dart';
import 'cow.dart';
import 'rabbit.dart';
import 'fish.dart';
import 'dragon.dart';
import 'fox.dart';

void renderAnimalBack(
    Canvas canvas, String skinId, double hr, double t, Color body, Color dark) {
  switch (skinId) {
    case 'gato':          catBack(canvas, hr, body);        break;
    case 'cachorro':      dogBack(canvas, hr);              break;
    case 'leao':          lionBack(canvas, hr);             break;
    case 'vaca':          cowBack(canvas, hr);              break;
    case 'coelho':        rabbitBack(canvas, hr, body);     break;
    case 'peixe':         fishBack(canvas, hr, body, dark); break;
    case 'dragao_animal': dragonBack(canvas, hr);           break;
    case 'raposa':        foxBack(canvas, hr, body);        break;
  }
}

void renderAnimalFront(
    Canvas canvas, String skinId, double hr, double t, Color body, Color dark) {
  switch (skinId) {
    case 'gato':          catFront(canvas, hr, t, body, dark);    break;
    case 'cachorro':      dogFront(canvas, hr, t, body, dark);    break;
    case 'leao':          lionFront(canvas, hr, t, body, dark);   break;
    case 'vaca':          cowFront(canvas, hr, t, body, dark);    break;
    case 'coelho':        rabbitFront(canvas, hr, t, body, dark); break;
    case 'peixe':         fishFront(canvas, hr, t, body, dark);   break;
    case 'dragao_animal': dragonFront(canvas, hr, t, body, dark); break;
    case 'raposa':        foxFront(canvas, hr, t, body, dark);    break;
  }
}

// Alias mantido para compatibilidade
void renderAnimalBackLayer(
    Canvas canvas, String skinId, double hr, double t, Color body, Color dark) {
  renderAnimalBack(canvas, skinId, hr, t, body, dark);
}
