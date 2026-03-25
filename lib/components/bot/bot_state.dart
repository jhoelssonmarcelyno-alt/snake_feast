// lib/components/bot/bot_state.dart
mixin BotState {
  bool isAlive = false;
  int score = 0;
  int level = 1;

  // ── Crescimento (igual ao player: 1 segmento a cada 10 pontos) ──
  int growAccum = 0;
  static const int growThreshold = 10;

  // ── Level (espelha exatamente o player) ──────────────────────
  int starsForLevel = 0; // food.value >= 5 → 2 estrelas = +1 level
  int foodForLevel = 0;  // comida normal: 10 unidades = +1 level
  int killsForLevel = 0; // 1 kill = +1 level
  double levelUpTimer = 0.0;

  // ── Boost ─────────────────────────────────────────────────────
  bool isBoosting = false;
  double boostTimer = 0.0;
  double boostDrainAccum = 0.0;

  void resetState() {
    score = 0;
    level = 1;
    starsForLevel = 0;
    foodForLevel = 0;
    killsForLevel = 0;
    growAccum = 0;
    levelUpTimer = 0.0;
    isBoosting = false;
    boostTimer = 0;
    boostDrainAccum = 0;
  }
}
