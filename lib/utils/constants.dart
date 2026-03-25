// lib/utils/constants.dart
import 'package:flutter/material.dart' show Color, Colors;

// ─── MUNDO E GRID ─────────────────────────────────────────────
const double kWorldWidth = 6000.0;
const double kWorldHeight = 6000.0;
const double kWorldMargin = 200.0;
const double kGridSpacing = 60.0;

// ─── CONFIGURAÇÕES DO PLAYER ──────────────────────────────────
const double kPlayerBaseSpeed = 160.0;
const double kPlayerBoostSpeed = 290.0;
const double kPlayerBoostDrain = 0.8;
const double kPlayerTurnLerp = 6.0;
const double kPlayerHeadRadius = 12.0;
const double kPlayerSegmentSpacing = 9.0;
const int kPlayerInitialSegments = 4;
const int kPlayerMinSegments = 6;
const double kJoystickDeadzone = 6.0;
const double kJoystickBoostZone = 18.0;
const Color kPlayerColor = Color(0xFF00E5FF);
const Color kPlayerColorDark = Color(0xFF0097A7);

// ─── CONFIGURAÇÕES DOS BOTS ───────────────────────────────────
const double kBotBaseSpeed = 145.0;
const double kBotBoostSpeed = 260.0;
const double kBotTurnLerp = 5.5;
const double kBotHeadRadius = 11.0;
const double kBotSegmentSpacing = 9.0;
const int kBotInitialSegments = 4;
const double kBotWanderTurnAngle = 0.5;
const double kBotWanderInterval = 0.5;
const double kBotFoodDetectDist = 900.0;
const double kBotDangerDist = 180.0;
const double kBotEdgeMargin = 180.0;
const double kBotRespawnDelay = 1.5;
const int kBotCount = 50;
const double kBotBoostChance = 0.006;
const double kBotBoostDuration = 2.0;

// ─── SISTEMA BATTLE ROYALE (ZONA) ─────────────────────────────
const double kBattleTotalTime = 600.0; // 10 minutos de partida total
const double kZoneDelayBeforeStart = 60.0; // 1 minuto de "paz" antes de fechar
const double kMinZoneRadius = 250.0; // Raio final onde a zona para
const double kZoneDamagePerSecond = 5.0; // Dano por segundo fora da zona

// ─── COMIDA E COLETÁVEIS ──────────────────────────────────────
const double kFoodCommonRadius = 6.0;
const double kFoodMassRadius = 11.0;
const double kFoodMassGlowRadius = 18.0;
const int kFoodCommonValue = 1;
const int kFoodStarValue = 10;
const double kFoodStarRadius = 9.0;
const int kFoodBotMassValue = 5;
const int kFoodBoostMassValue = 3;
const int kCommonFoodCount = 1500;
const double kEatRadius = 14.0;

// ─── COLISÃO E PARTÍCULAS ─────────────────────────────────────
const double kCollisionBodyRatio = 0.7;
const int kDeathParticleCount = 28;
const double kDeathParticleSpeed = 200.0;
const double kDeathParticleLife = 0.85;
const double kDeathParticleMaxRadius = 7.0;

// ─── CORES DE AMBIENTE ────────────────────────────────────────
const Color kColorBackground = Color(0xFF2D5A2D);
const Color kColorGrassDark = Color(0xFF2A5228);
const Color kColorGrassLight = Color(0xFF3D7A38);
const Color kColorGrid = Color(0x22FFFFFF);
const Color kColorBorder = Color(0xFF00FF88);

// ─── INTERFACE (HUD / MINIMAP) ───────────────────────────────
const double kMinimapSize = 140.0;
const double kMinimapMargin = 12.0;
const double kMinimapBottomOffset = 210.0;

const double kWallThickness = 20.0;
const double kWallBrickW = 40.0;
const double kWallBrickH = 20.0;

// ─── PREFERÊNCIAS E OVERLAYS ──────────────────────────────────
const String kPrefHighScore = 'high_score';
const String kPrefSelectedSkin = 'selected_skin';
const String kPrefBoostCount = 'boost_count';

const String kOverlayMainMenu = 'MainMenu';
const String kOverlayGameOver = 'GameOver';
const String kOverlayHud = 'HUD';
const String kOverlaySettings = 'Settings';
const String kOverlayPause = 'Pause';
const String kOverlayShop = 'Shop';
const String kOverlayRevive = 'Revive';
const String kOverlayRanking = 'Ranking';
const String kOverlayLobby = 'Lobby';

// ─── IDENTIDADE DOS BOTS ──────────────────────────────────────
const List<String> kBotNames = [
  'SuperSnake',
  'Bobo',
  'Bushido',
  'Morgana',
  'Sherlock',
  'Zorg',
  'Casper',
  'R3X',
  'Bjorn',
  'Officer K',
  'Chef Snek',
  'Dracula',
  'Shadow',
  'Viper',
  'Blaze',
  'Cobra',
  'Naga',
  'Python',
  'Mamba',
  'Rattler',
  'Titan',
  'Kraken',
  'Hydra',
  'Jormungand',
  'Orochi',
  'Ryu',
  'Kaa',
  'Solid',
  'Liquid',
  'Venom',
  'Nagini',
  'Medusa',
  'Asmodeus',
  'Slytherin',
  'Basilisk',
  'Copperhead',
  'Sidewinder',
  'Anaconda',
  'Taipan',
  'Asp',
  'Krait',
  'Garfield',
  'Gollum',
  'Yoda',
  'Neo',
  'Darth',
  'Ragnar',
  'Floki',
  'Loki',
  'Anubis'
];

const List<List<Color>> kBotPalette = [
  [Color(0xFFFF5252), Color(0xFFB71C1C)],
  [Color(0xFFFFAB40), Color(0xFFE65100)],
  [Color(0xFFE040FB), Color(0xFF6A1B9A)],
  [Color(0xFF69F0AE), Color(0xFF1B5E20)],
  [Color(0xFFFFFF00), Color(0xFFF57F17)],
  [Color(0xFFFF80AB), Color(0xFF880E4F)],
  [Color(0xFF40C4FF), Color(0xFF01579B)],
  [Color(0xFFCCFF90), Color(0xFF558B2F)],
  [Color(0xFFFF6E40), Color(0xFFBF360C)],
  [Color(0xFF80D8FF), Color(0xFF006064)],
];

// ─── SISTEMA DE SKINS ─────────────────────────────────────────
class SnakeSkin {
  final String id;
  final String name;
  final String rarity;
  final Color bodyColor;
  final Color bodyColorDark;
  final Color accentColor;
  const SnakeSkin({
    required this.rarity,
    required this.id,
    required this.name,
    required this.bodyColor,
    required this.bodyColorDark,
    required this.accentColor,
  });
}

const List<SnakeSkin> kPlayerSkins = [
  SnakeSkin(
      id: 'classic',
      name: 'CLASSIC',
      rarity: 'comum',
      bodyColor: Color(0xFF00E5FF),
      bodyColorDark: Color(0xFF006A7A),
      accentColor: Color(0xFF00E5FF)),
  SnakeSkin(
      id: 'verde',
      name: 'VERDE',
      rarity: 'comum',
      bodyColor: Color(0xFF69F0AE),
      bodyColorDark: Color(0xFF1B5E20),
      accentColor: Color(0xFF69F0AE)),
  SnakeSkin(
      id: 'roxo',
      name: 'ROXO',
      rarity: 'comum',
      bodyColor: Color(0xFFCE93D8),
      bodyColorDark: Color(0xFF4A148C),
      accentColor: Color(0xFFCE93D8)),
  SnakeSkin(
      id: 'laranja',
      name: 'LARANJA',
      rarity: 'comum',
      bodyColor: Color(0xFFFFAB40),
      bodyColorDark: Color(0xFF7A2E00),
      accentColor: Color(0xFFFFAB40)),
  SnakeSkin(
      id: 'rosa',
      name: 'ROSA',
      rarity: 'comum',
      bodyColor: Color(0xFFFF80AB),
      bodyColorDark: Color(0xFF880E4F),
      accentColor: Color(0xFFFF80AB)),
  SnakeSkin(
      id: 'azul',
      name: 'AZUL',
      rarity: 'comum',
      bodyColor: Color(0xFF40C4FF),
      bodyColorDark: Color(0xFF01579B),
      accentColor: Color(0xFF40C4FF)),
  SnakeSkin(
      id: 'vaca',
      name: 'VACA',
      rarity: 'comum',
      bodyColor: Color(0xFFEEEEEE),
      bodyColorDark: Color(0xFF212121),
      accentColor: Color(0xFFFFFFFF)),
  SnakeSkin(
      id: 'coelho',
      name: 'COELHO',
      rarity: 'comum',
      bodyColor: Color(0xFFFFFFFF),
      bodyColorDark: Color(0xFFE0E0E0),
      accentColor: Color(0xFFFF85A1)),
  SnakeSkin(
      id: 'hot',
      name: 'HOT',
      rarity: 'incomum',
      bodyColor: Color(0xFFFF5252),
      bodyColorDark: Color(0xFF7A1010),
      accentColor: Color(0xFFFF5252)),
  SnakeSkin(
      id: 'sorriso',
      name: 'SORRISO',
      rarity: 'incomum',
      bodyColor: Color(0xFFFFCA28),
      bodyColorDark: Color(0xFF7A4F00),
      accentColor: Color(0xFFFFCA28)),
  SnakeSkin(
      id: 'lili',
      name: 'LILI',
      rarity: 'incomum',
      bodyColor: Color(0xFFF48FB1),
      bodyColorDark: Color(0xFF7B1FA2),
      accentColor: Color(0xFFF48FB1)),
  SnakeSkin(
      id: 'gelo',
      name: 'GELO',
      rarity: 'incomum',
      bodyColor: Color(0xFFE3F2FD),
      bodyColorDark: Color(0xFF1565C0),
      accentColor: Color(0xFF82B1FF)),
  SnakeSkin(
      id: 'coral',
      name: 'CORAL',
      rarity: 'incomum',
      bodyColor: Color(0xFFFF8A65),
      bodyColorDark: Color(0xFF7A2E00),
      accentColor: Color(0xFFFF8A65)),
  SnakeSkin(
      id: 'robo',
      name: 'ROBO',
      rarity: 'incomum',
      bodyColor: Color(0xFFB0BEC5),
      bodyColorDark: Color(0xFF37474F),
      accentColor: Color(0xFF78909C)),
  SnakeSkin(
      id: 'cinza',
      name: 'CINZA',
      rarity: 'incomum',
      bodyColor: Color(0xFF90A4AE),
      bodyColorDark: Color(0xFF263238),
      accentColor: Color(0xFFCFD8DC)),
  SnakeSkin(
      id: 'marrom',
      name: 'MARROM',
      rarity: 'incomum',
      bodyColor: Color(0xFFA1887F),
      bodyColorDark: Color(0xFF3E2723),
      accentColor: Color(0xFFD7CCC8)),
  SnakeSkin(
      id: 'indigo',
      name: 'ÍNDIGO',
      rarity: 'incomum',
      bodyColor: Color(0xFF7986CB),
      bodyColorDark: Color(0xFF1A237E),
      accentColor: Color(0xFF9FA8DA)),
  SnakeSkin(
      id: 'gato',
      name: 'GATO',
      rarity: 'incomum',
      bodyColor: Color(0xFFFF9800),
      bodyColorDark: Color(0xFFE65100),
      accentColor: Color(0xFFFFCC80)),
  SnakeSkin(
      id: 'cachorro',
      name: 'CACHORRO',
      rarity: 'incomum',
      bodyColor: Color(0xFFD4A35A),
      bodyColorDark: Color(0xFF8B5E2A),
      accentColor: Color(0xFFFFE0B2)),
  SnakeSkin(
      id: 'peixe',
      name: 'PEIXE',
      rarity: 'incomum',
      bodyColor: Color(0xFF29B6F6),
      bodyColorDark: Color(0xFF0288D1),
      accentColor: Color(0xFF80DEEA)),
  SnakeSkin(
      id: 'alien',
      name: 'ALIEN',
      rarity: 'rara',
      bodyColor: Color(0xFFCCFF90),
      bodyColorDark: Color(0xFF33691E),
      accentColor: Color(0xFFB2FF59)),
  SnakeSkin(
      id: 'veneno',
      name: 'VENENO',
      rarity: 'rara',
      bodyColor: Color(0xFF1A1A1A),
      bodyColorDark: Color(0xFF000000),
      accentColor: Color(0xFF00E676)),
  SnakeSkin(
      id: 'fantasma',
      name: 'FANTASMA',
      rarity: 'rara',
      bodyColor: Color(0xFFF5F5F5),
      bodyColorDark: Color(0xFFBDBDBD),
      accentColor: Color(0xFFE0E0E0)),
  SnakeSkin(
      id: 'piranha',
      name: 'PIRANHA',
      rarity: 'rara',
      bodyColor: Color(0xFF76FF03),
      bodyColorDark: Color(0xFF33691E),
      accentColor: Color(0xFF76FF03)),
  SnakeSkin(
      id: 'lava',
      name: 'LAVA',
      rarity: 'rara',
      bodyColor: Color(0xFFFF6E40),
      bodyColorDark: Color(0xFF7A1C00),
      accentColor: Color(0xFFFF6E40)),
  SnakeSkin(
      id: 'esmeralda',
      name: 'ESMERALDA',
      rarity: 'rara',
      bodyColor: Color(0xFF00E676),
      bodyColorDark: Color(0xFF003320),
      accentColor: Color(0xFF69F0AE)),
  SnakeSkin(
      id: 'cristal',
      name: 'CRISTAL',
      rarity: 'rara',
      bodyColor: Color(0xFFE8F5E9),
      bodyColorDark: Color(0xFF80CBC4),
      accentColor: Color(0xFFB2EBF2)),
  SnakeSkin(
      id: 'leao',
      name: 'LEÃO',
      rarity: 'rara',
      bodyColor: Color(0xFFC8971F),
      bodyColorDark: Color(0xFF8B5E0A),
      accentColor: Color(0xFFFFD54F)),
  SnakeSkin(
      id: 'raposa',
      name: 'RAPOSA',
      rarity: 'rara',
      bodyColor: Color(0xFFFF6D00),
      bodyColorDark: Color(0xFFBF360C),
      accentColor: Color(0xFFFFCC80)),
  SnakeSkin(
      id: 'serpente',
      name: 'SERPENTE',
      rarity: 'lendaria',
      bodyColor: Color(0xFF1B5E20),
      bodyColorDark: Color(0xFF003300),
      accentColor: Color(0xFF00E676)),
  SnakeSkin(
      id: 'dragao',
      name: 'DRAGÃO',
      rarity: 'lendaria',
      bodyColor: Color(0xFFFF1744),
      bodyColorDark: Color(0xFF7F0000),
      accentColor: Color(0xFFFFD700)),
  SnakeSkin(
      id: 'galaxia',
      name: 'GALÁXIA',
      rarity: 'lendaria',
      bodyColor: Color(0xFF7C4DFF),
      bodyColorDark: Color(0xFF1A0050),
      accentColor: Color(0xFFE040FB)),
  SnakeSkin(
      id: 'neon',
      name: 'NEON',
      rarity: 'lendaria',
      bodyColor: Color(0xFF00E5FF),
      bodyColorDark: Color(0xFF000000),
      accentColor: Color(0xFF76FF03)),
  SnakeSkin(
      id: 'ouro',
      name: 'OURO',
      rarity: 'lendaria',
      bodyColor: Color(0xFFFFD700),
      bodyColorDark: Color(0xFF7A4F00),
      accentColor: Color(0xFFFFFF00)),
  SnakeSkin(
      id: 'vulcao',
      name: 'VULCÃO',
      rarity: 'lendaria',
      bodyColor: Color(0xFFFF6D00),
      bodyColorDark: Color(0xFF3E0000),
      accentColor: Color(0xFFFFD740)),
  SnakeSkin(
      id: 'oceano',
      name: 'OCEANO',
      rarity: 'lendaria',
      bodyColor: Color(0xFF0288D1),
      bodyColorDark: Color(0xFF001970),
      accentColor: Color(0xFF80D8FF)),
  SnakeSkin(
      id: 'aurora',
      name: 'AURORA',
      rarity: 'lendaria',
      bodyColor: Color(0xFFAA00FF),
      bodyColorDark: Color(0xFF1A0033),
      accentColor: Color(0xFF18FFFF)),
  SnakeSkin(
      id: 'dragao_animal',
      name: 'DRAGÃO BESTA',
      rarity: 'lendaria',
      bodyColor: Color(0xFFFF1744),
      bodyColorDark: Color(0xFF7F0000),
      accentColor: Color(0xFFFFD700)),
];
