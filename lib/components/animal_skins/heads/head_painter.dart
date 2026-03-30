import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Color;

/// Contrato que toda cabeca de animal deve implementar.
abstract class HeadPainter {
  /// Camada de tras (orelhas, crina, etc.) - desenhada ANTES do corpo.
  void paintBack(Canvas canvas, double r, Color body, Color dark);

  /// Camada da frente (focinho, olhos, bico, etc.) - desenhada DEPOIS do corpo.
  /// [t] e o accTimer para animacoes (piscar, boca, etc.)
  void paintFront(Canvas canvas, double r, double t, Color body, Color dark);
}
