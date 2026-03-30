// lib/utils/constants.dart
import 'package:flutter/material.dart' show Color;
export '../game/skins/snake_skin.dart' show SnakeSkin;
export '../game/skins/skin_data.dart' show kPlayerSkins, kTotalSkins;

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
const double kBattleTotalTime = 300.0; // 5 minutos de partida total
const double kZoneDelayBeforeStart = 60.0; // 1 minuto de "paz" antes de fechar
const double kZoneGraceTime = 60.0;
const double kMinZoneRadius = 250.0; // Raio final onde a zona para
const double kZoneDamagePerSecond = 5.0; // Dano por segundo fora da zona

// ─── COMIDA E COLETÁVEIS ──────────────────────────────────────
const double kFoodCommonRadius = 6.0;
const double kFoodMassRadius = 11.0;
const double kFoodMassGlowRadius = 18.0;
const int kFoodCommonValue = 5;
const int kFoodStarValue = 10;
const double kFoodStarRadius = 9.0;
const int kFoodBotMassValue = 5;
const int kFoodBoostMassValue = 3;
const int kCommonFoodCount = 2000; // total inicial de comida no mapa
const int kFoodMinCount = 30; // mínimo absoluto dentro da zona final
const double kMinFoodDensity = 0.004; // comidas por px² dentro da zona ativa
const double kEatRadius = 14.0;

// ─── CRESCIMENTO ──────────────────────────────────────────────
const int kGrowThreshold = 10;

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

// ============================================================================
// EXPORTAÇÕES DO SISTEMA DE SKINS (NOVO SISTEMA)
// ============================================================================
const String kOverlayWin = 'WinOverlay';

// ============================================================================
// MODO DE DESENVOLVIMENTO
// ============================================================================
const bool DEV_MODE = false;  // Mude para false em produção
