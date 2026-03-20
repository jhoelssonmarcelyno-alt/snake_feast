import 'package:flutter/material.dart' show Color;

const double kWorldWidth = 6000.0;
const double kWorldHeight = 6000.0;
const double kWorldMargin = 200.0;
const double kGridSpacing = 60.0;

const double kPlayerBaseSpeed = 160.0;
const double kPlayerBoostSpeed = 290.0;
const double kPlayerBoostDrain = 0.8;
const double kPlayerTurnLerp = 6.0;
const double kPlayerHeadRadius = 10.0;
const double kPlayerSegmentSpacing = 5.0;
const int kPlayerInitialSegments = 4;
const int kPlayerMinSegments = 6;
const double kJoystickDeadzone = 6.0;
const double kJoystickBoostZone = 18.0;
const Color kPlayerColor = Color(0xFF00E5FF);
const Color kPlayerColorDark = Color(0xFF0097A7);

const double kBotBaseSpeed = 145.0;
const double kBotBoostSpeed = 260.0;
const double kBotTurnLerp = 5.5;
const double kBotHeadRadius = 9.0;
const double kBotSegmentSpacing = 5.0;
const int kBotInitialSegments = 4;
const double kBotWanderTurnAngle = 0.5;
const double kBotWanderInterval = 0.5;
const double kBotFoodDetectDist = 900.0;
const double kBotDangerDist = 180.0;
const double kBotEdgeMargin = 180.0;
const double kBotRespawnDelay = 1.5;
const int kBotCount = 20;
const double kBotBoostChance = 0.006;
const double kBotBoostDuration = 2.0;

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

const double kFoodCommonRadius = 6.0;
const double kFoodMassRadius = 11.0;
const double kFoodMassGlowRadius = 18.0;
const int kFoodCommonValue = 1;
const int kFoodBotMassValue = 5;
const int kFoodBoostMassValue = 3;
const int kCommonFoodCount = 1500;
const double kEatRadius = 14.0;

const double kCollisionBodyRatio = 0.7;

const int kDeathParticleCount = 28;
const double kDeathParticleSpeed = 200.0;
const double kDeathParticleLife = 0.85;
const double kDeathParticleMaxRadius = 7.0;

// ─── Cores da arena (verde claro visível) ─────────────────────
const Color kColorBackground = Color(0xFF2D5A2D); // verde escuro base
const Color kColorGrassDark = Color(0xFF2A5228); // tile escuro
const Color kColorGrassLight = Color(0xFF3D7A38); // tile claro — mais visível
const Color kColorGrid = Color(0x22FFFFFF);
const Color kColorBorder = Color(0xFF00FF88);

const double kMinimapSize = 140.0;
const double kMinimapMargin = 12.0;
const double kMinimapBottomOffset = 210.0;

// Parede de muro
const double kWallThickness = 20.0;
const double kWallBrickW = 40.0;
const double kWallBrickH = 20.0;

const String kPrefHighScore = 'high_score';
const String kPrefSelectedSkin = 'selected_skin';
const String kPrefBoostCount = 'boost_count';

// ─── Overlays ────────────────────────────────────────────────
const String kOverlayMainMenu = 'MainMenu';
const String kOverlayGameOver = 'GameOver';
const String kOverlayHud = 'HUD';
const String kOverlaySettings = 'Settings'; // ← novo

class SnakeSkin {
  final String id;
  final String name;
  final Color bodyColor;
  final Color bodyColorDark;
  final Color accentColor;
  const SnakeSkin({
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
      bodyColor: Color(0xFF00E5FF),
      bodyColorDark: Color(0xFF006A7A),
      accentColor: Color(0xFF00E5FF)),
  SnakeSkin(
      id: 'hot',
      name: 'HOT',
      bodyColor: Color(0xFFFF5252),
      bodyColorDark: Color(0xFF7A1010),
      accentColor: Color(0xFFFF5252)),
  SnakeSkin(
      id: 'sorriso',
      name: 'SORRISO',
      bodyColor: Color(0xFFFFCA28),
      bodyColorDark: Color(0xFF7A4F00),
      accentColor: Color(0xFFFFCA28)),
  SnakeSkin(
      id: 'veneno',
      name: 'VENENO',
      bodyColor: Color(0xFF1A1A1A),
      bodyColorDark: Color(0xFF000000),
      accentColor: Color(0xFF00E676)),
  SnakeSkin(
      id: 'fantasma',
      name: 'FANTASMA',
      bodyColor: Color(0xFFF5F5F5),
      bodyColorDark: Color(0xFFBDBDBD),
      accentColor: Color(0xFFE0E0E0)),
  SnakeSkin(
      id: 'piranha',
      name: 'PIRANHA',
      bodyColor: Color(0xFF76FF03),
      bodyColorDark: Color(0xFF33691E),
      accentColor: Color(0xFF76FF03)),
  SnakeSkin(
      id: 'lava',
      name: 'LAVA',
      bodyColor: Color(0xFFFF6E40),
      bodyColorDark: Color(0xFF7A1C00),
      accentColor: Color(0xFFFF6E40)),
  SnakeSkin(
      id: 'alien',
      name: 'ALIEN',
      bodyColor: Color(0xFFCCFF90),
      bodyColorDark: Color(0xFF33691E),
      accentColor: Color(0xFFB2FF59)),
  SnakeSkin(
      id: 'lili',
      name: 'LILI',
      bodyColor: Color(0xFFF48FB1),
      bodyColorDark: Color(0xFF7B1FA2),
      accentColor: Color(0xFFF48FB1)),
  SnakeSkin(
      id: 'robo',
      name: 'ROBO',
      bodyColor: Color(0xFFB0BEC5),
      bodyColorDark: Color(0xFF37474F),
      accentColor: Color(0xFF78909C)),
];

const String kOverlayPause = 'Pause';
const String kOverlayShop = 'Shop';
const String kOverlayRevive = 'Revive';
