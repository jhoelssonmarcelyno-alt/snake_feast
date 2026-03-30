// Compatibilidade com snake_player_renderer e snake_bot_renderer.
// Usa HeadRegistry internamente - nao adicione switch/cases aqui.
import 'dart:ui';
import 'package:flutter/material.dart' show Color;
import 'head_registry.dart';

void renderAnimalBack(
    Canvas canvas, String skinId, double hr, double t, Color body, Color dark) {
  HeadRegistry.get(skinId).paintBack(canvas, hr, body, dark);
}

void renderAnimalFront(
    Canvas canvas, String skinId, double hr, double t, Color body, Color dark) {
  HeadRegistry.get(skinId).paintFront(canvas, hr, t, body, dark);
}

// Alias de compatibilidade mantido
void renderAnimalBackLayer(
    Canvas canvas, String skinId, double hr, double t, Color body, Color dark) =>
    renderAnimalBack(canvas, skinId, hr, t, body, dark);
