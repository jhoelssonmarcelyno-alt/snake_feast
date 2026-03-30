// lib/game/color_generator.dart (versão alternativa sem HSLColor)
import 'dart:ui';
import 'package:flutter/material.dart' show Colors;

class ColorGenerator {
  // Cores base para interpolação
  static const List<Color> _baseColors = [
    Color(0xFF2D5A2D), // Verde floresta
    Color(0xFF1A3A5C), // Azul oceano
    Color(0xFF5C3A1A), // Marrom deserto
    Color(0xFF5C1A1A), // Vermelho vulcão
    Color(0xFF1A3A5C), // Azul gelo
    Color(0xFF1A1A2E), // Roxo caverna
    Color(0xFF1B3A1B), // Verde pântano
    Color(0xFF4A3000), // Amarelo savana
    Color(0xFF263238), // Cinza montanha
    Color(0xFF006064), // Azul profundo
    Color(0xFF37474F), // Azul acinzentado
    Color(0xFF1B5E20), // Verde brilhante
    Color(0xFF0D0D0D), // Preto abismo
    Color(0xFF1A0033), // Roxo escuro
    Color(0xFF4A1942), // Roxo profundo
    Color(0xFF3E2723), // Marrom escuro
    Color(0xFF4A0000), // Vermelho escuro
    Color(0xFF00838F), // Ciano
    Color(0xFF1A0044), // Azul índigo
    Color(0xFF1C1C1C), // Cinza escuro
    Color(0xFF01579B), // Azul marinho
    Color(0xFF212121), // Cinza
    Color(0xFF4A0000), // Vermelho sangue
    Color(0xFF0D0030), // Azul noturno
    Color(0xFF000000), // Preto
  ];

  static const List<Color> _baseAccents = [
    Color(0xFF4CAF50), // Verde
    Color(0xFF29CFFF), // Azul claro
    Color(0xFFFF9500), // Laranja
    Color(0xFFFF3D00), // Vermelho
    Color(0xFF80DEEA), // Azul gelo
    Color(0xFF7B1FA2), // Roxo
    Color(0xFF8BC34A), // Verde limão
    Color(0xFFFFB300), // Amarelo
    Color(0xFFB0BEC5), // Cinza
    Color(0xFF00E5FF), // Ciano
    Color(0xFF90A4AE), // Cinza azulado
    Color(0xFF69F0AE), // Verde menta
    Color(0xFF455A64), // Azul cinza
    Color(0xFFE040FB), // Roxo vibrante
    Color(0xFFFF80AB), // Rosa
    Color(0xFFBCAAA4), // Bege
    Color(0xFFFF1744), // Vermelho
    Color(0xFF84FFFF), // Ciano claro
    Color(0xFF7C4DFF), // Roxo claro
    Color(0xFF00E676), // Verde
    Color(0xFF40C4FF), // Azul
    Color(0xFFEEEEEE), // Branco
    Color(0xFFFFD600), // Amarelo
    Color(0xFFAA00FF), // Roxo
    Color(0xFFFFFFFF), // Branco
  ];

  /// Gera cor de fundo baseada no índice do mundo (0-249)
  static Color getWorldBgColor(int index) {
    final int safeIndex = index.clamp(0, 249);

    if (safeIndex < _baseColors.length) {
      return _baseColors[safeIndex];
    }

    // Para mundos além dos 25, interpola entre cores base
    final int cycleIndex = safeIndex % _baseColors.length;
    final int nextIndex = (cycleIndex + 1) % _baseColors.length;
    final double t = (safeIndex - cycleIndex) / _baseColors.length;

    return Color.lerp(_baseColors[cycleIndex], _baseColors[nextIndex], t)!;
  }

  /// Gera cor de destaque baseada no índice do mundo (0-249)
  static Color getWorldAccentColor(int index) {
    final int safeIndex = index.clamp(0, 249);

    if (safeIndex < _baseAccents.length) {
      return _baseAccents[safeIndex];
    }

    // Para mundos além dos 25, interpola entre cores base
    final int cycleIndex = safeIndex % _baseAccents.length;
    final int nextIndex = (cycleIndex + 1) % _baseAccents.length;
    final double t = (safeIndex - cycleIndex) / _baseAccents.length;

    return Color.lerp(_baseAccents[cycleIndex], _baseAccents[nextIndex], t)!;
  }
}
