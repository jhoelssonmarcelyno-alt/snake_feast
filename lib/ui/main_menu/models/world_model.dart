// lib/ui/main_menu/models/world_model.dart
import 'package:flutter/material.dart';

class WorldModel {
  final int number;
  final String name;
  final String emoji;
  final Color primary;
  final Color secondary;
  final String description;

  const WorldModel({
    required this.number,
    required this.name,
    required this.emoji,
    required this.primary,
    required this.secondary,
    this.description = '',
  });
}

// Gerador de 250 mundos únicos
class WorldGenerator {
  static List<WorldModel> generateWorlds() {
    final List<WorldModel> worlds = [];
    
    // Cores base para gradiente
    final List<Color> primaryColors = [
      Color(0xFF2D5A2D), Color(0xFF1A3A5C), Color(0xFF5C3A1A), Color(0xFF5C1A1A),
      Color(0xFF1A1A2E), Color(0xFF1B3A1B), Color(0xFF4A3000), Color(0xFF263238),
      Color(0xFF006064), Color(0xFF37474F), Color(0xFF1B5E20), Color(0xFF0D0D0D),
      Color(0xFF1A0033), Color(0xFF4A1942), Color(0xFF3E2723), Color(0xFF4A0000),
      Color(0xFF00838F), Color(0xFF1A0044), Color(0xFF1C1C1C), Color(0xFF01579B),
    ];
    
    final List<Color> secondaryColors = [
      Color(0xFF4CAF50), Color(0xFF29CFFF), Color(0xFFFF9500), Color(0xFFFF3D00),
      Color(0xFF80DEEA), Color(0xFF7B1FA2), Color(0xFF8BC34A), Color(0xFFFFB300),
      Color(0xFFB0BEC5), Color(0xFF00E5FF), Color(0xFF90A4AE), Color(0xFF69F0AE),
      Color(0xFF455A64), Color(0xFFE040FB), Color(0xFFFF80AB), Color(0xFFBCAAA4),
      Color(0xFFFF1744), Color(0xFF84FFFF), Color(0xFF7C4DFF), Color(0xFF00E676),
    ];
    
    final List<String> prefixes = [
      'Floresta', 'Oceano', 'Deserto', 'Vulcão', 'Gelo', 'Caverna', 'Pântano', 'Savana',
      'Tundra', 'Ilha', 'Montanha', 'Selva', 'Abismo', 'Neon', 'Cogumelo', 'Ruína',
      'Submundo', 'Cristal', 'Aurora', 'Robô', 'Submarino', 'Fantasma', 'Dragão', 'Cósmico',
      'Infinito', 'Coral', 'Bambu', 'Tempestade', 'Areia', 'Vapor', 'Pradaria', 'Espaço',
      'Lava', 'Névoa', 'Fada', 'Pirata', 'Antártica', 'Biolum', 'Trevas', 'Mel',
      'Sakura', 'Espelho', 'Tóxico', 'Mecha', 'Sonho', 'Arco-íris', 'Fogo Gelo', 'Pirâmide',
      'Alien', 'Eclipse', 'Bambolê', 'Granito', 'Ciclone', 'Espinho', 'Relíquia', 'Vórtex',
      'Ferrugem', 'Zen', 'Bruxa', 'Platina', 'Nuvem', 'Lodo', 'Pulsar', 'Esqueleto',
      'Safira', 'Esmeralda', 'Rubi', 'Ametista', 'Obsidiana', 'Titânio', 'Plasma', 'Vácuo',
      'Caos', 'Oráculo', 'Templo', 'Fênix', 'Kraken', 'Golem', 'Quasar', 'Éter',
      'Relâmpago', 'Magma', 'Mito', 'Necro', 'Serafim', 'Sombra', 'Veleno', 'Espectro',
      'Titã', 'Nexus', 'Abaddon', 'Arcano', 'Singularidade', 'Divino', 'Abissal', 'Primordial',
      'Astral', 'Eterno', 'Ômega', 'Lendário'
    ];
    
    final List<String> suffixes = [
      'da Lua', 'do Sol', 'das Estrelas', 'dos Ventos', 'das Águas', 'do Fogo', 'da Terra',
      'do Céu', 'do Mar', 'da Montanha', 'do Vale', 'da Floresta', 'do Deserto', 'do Gelo',
      'do Vulcão', 'da Tempestade', 'do Raio', 'da Aurora', 'do Crepúsculo', 'do Amanhecer',
      'da Noite', 'do Dia', 'da Eternidade', 'do Infinito', 'do Caos', 'da Ordem', 'da Vida',
      'da Morte', 'do Tempo', 'do Espaço', 'da Energia', 'da Matéria', 'da Consciência',
      'do Sonho', 'da Realidade', 'da Ilusão', 'da Magia', 'da Tecnologia', 'da Natureza',
      'dos Deuses', 'dos Heróis', 'dos Monstros', 'das Fadas', 'dos Dragões', 'dos Titãs'
    ];
    
    for (int i = 1; i <= 250; i++) {
      final primaryIndex = (i - 1) % primaryColors.length;
      final secondaryIndex = (i - 1) % secondaryColors.length;
      final prefixIndex = ((i - 1) * 3) % prefixes.length;
      final suffixIndex = ((i - 1) * 7) % suffixes.length;
      
      String name;
      String emoji;
      
      // Nomes únicos baseados no número
      if (i <= 100) {
        name = prefixes[prefixIndex];
      } else if (i <= 200) {
        name = '${prefixes[prefixIndex]} ${suffixes[suffixIndex]}';
      } else {
        name = '${prefixes[prefixIndex]} Supremo';
      }
      
      // Emojis variados
      if (i <= 50) {
        emoji = _getNatureEmoji(i);
      } else if (i <= 100) {
        emoji = _getElementEmoji(i);
      } else if (i <= 150) {
        emoji = _getFantasyEmoji(i);
      } else if (i <= 200) {
        emoji = _getCosmicEmoji(i);
      } else {
        emoji = _getLegendaryEmoji(i);
      }
      
      worlds.add(WorldModel(
        number: i,
        name: name,
        emoji: emoji,
        primary: primaryColors[primaryIndex],
        secondary: secondaryColors[secondaryIndex],
        description: _getDescription(i, name),
      ));
    }
    
    return worlds;
  }
  
  static String _getNatureEmoji(int i) {
    final List<String> emojis = ['🌳', '🌲', '🌴', '🌿', '🍃', '🍂', '🍁', '🌸', '🌺', '🌻'];
    return emojis[i % emojis.length];
  }
  
  static String _getElementEmoji(int i) {
    final List<String> emojis = ['🔥', '💧', '🌪️', '❄️', '⚡', '🌊', '🏔️', '🌋'];
    return emojis[i % emojis.length];
  }
  
  static String _getFantasyEmoji(int i) {
    final List<String> emojis = ['🐉', '🧙', '🧚', '🧝', '🦄', '🐲', '🏰', '⚔️'];
    return emojis[i % emojis.length];
  }
  
  static String _getCosmicEmoji(int i) {
    final List<String> emojis = ['🌍', '🌎', '🌏', '🌙', '☀️', '⭐', '🌟', '✨', '🌌', '🪐'];
    return emojis[i % emojis.length];
  }
  
  static String _getLegendaryEmoji(int i) {
    final List<String> emojis = ['👑', '🏆', '💎', '🔱', '⚜️', '🌟', '✨', '⭐'];
    return emojis[i % emojis.length];
  }
  
  static String _getDescription(int number, String name) {
    if (number <= 50) {
      return 'Um mundo natural e tranquilo, cheio de vida e cores.';
    } else if (number <= 100) {
      return 'Um mundo elemental onde os elementos da natureza dominam.';
    } else if (number <= 150) {
      return 'Um mundo mágico repleto de criaturas fantásticas e encantamentos.';
    } else if (number <= 200) {
      return 'Um mundo cósmico onde as estrelas guiam o caminho.';
    } else {
      return 'Um mundo lendário onde apenas os mais fortes sobrevivem.';
    }
  }
}

// Lista de mundos gerada dinamicamente
final List<WorldModel> kWorlds = WorldGenerator.generateWorlds();
