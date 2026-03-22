// lib/services/score_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ScoreService {
  ScoreService._();
  static final ScoreService instance = ScoreService._();

  late SharedPreferences _prefs;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    _prefs = await SharedPreferences.getInstance();
    _ready = true;
  }

  // ─── High Score ──────────────────────────────────────────────
  int get highScore => _prefs.getInt(kPrefHighScore) ?? 0;

  Future<bool> submitScore(int score) async {
    if (score > highScore) {
      await _prefs.setInt(kPrefHighScore, score);
      return true;
    }
    return false;
  }

  // ─── Skin selecionada ─────────────────────────────────────────
  int get selectedSkinIndex {
    final idx = _prefs.getInt(kPrefSelectedSkin) ?? 0;
    return idx.clamp(0, kPlayerSkins.length - 1);
  }

  Future<void> saveSkinIndex(int index) async {
    await _prefs.setInt(kPrefSelectedSkin, index);
  }

  SnakeSkin get selectedSkin => kPlayerSkins[selectedSkinIndex];

  /// ID da skin selecionada — usado pelo modo online.
  String get selectedSkinId => selectedSkin.id;

  // ─── Nome do player ───────────────────────────────────────────
  String get playerName {
    final n = _prefs.getString('player_name') ?? 'Você';
    return n.trim().isEmpty ? 'Você' : n;
  }

  Future<void> savePlayerName(String name) async {
    final clean = name.trim().isEmpty ? 'Você' : name.trim();
    await _prefs.setString('player_name', clean);
  }

  // ─── Moedas ───────────────────────────────────────────────────
  // Creditadas em tempo real a cada 50 comidas pelo snake_player.
  int get coins => _prefs.getInt('coins') ?? 0;

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    await _prefs.setInt('coins', coins + amount);
  }

  // ─── Diamantes ────────────────────────────────────────────────
  // Creditados em tempo real a cada 5000 comidas pelo snake_player.
  int get diamonds => _prefs.getInt('diamonds') ?? 0;

  Future<void> addDiamonds(int amount) async {
    if (amount <= 0) return;
    await _prefs.setInt('diamonds', diamonds + amount);
  }

  // ─── processRewards — apenas para exibir resumo no Game Over ──
  // NÃO credita mais (evita dupla contagem).
  // As moedas/diamantes já foram creditadas em tempo real.
  Map<String, int> _lastRewards = {'coins': 0, 'diamonds': 0};

  /// Armazena o resumo de recompensas da partida para exibir no Game Over.
  void recordSessionRewards(int foodEaten) {
    _lastRewards = {
      'coins':    foodEaten ~/ 50,
      'diamonds': foodEaten ~/ 5000,
    };
  }

  /// Retorna o resumo da última partida (sem creditar novamente).
  Map<String, int> getLastRewards() => Map.from(_lastRewards);

  /// Mantido por compatibilidade — não credita, só retorna resumo.
  Future<Map<String, int>> processRewards(int foodEaten) async {
    recordSessionRewards(foodEaten);
    return getLastRewards();
  }

  void resetRewardsFlag() {
    _lastRewards = {'coins': 0, 'diamonds': 0};
  }

  // ─── Boost extra (comprado na loja) ──────────────────────────
  int get extraBoosts => _prefs.getInt('extra_boosts') ?? 0;

  Future<void> addExtraBoosts(int amount) async {
    await _prefs.setInt('extra_boosts', extraBoosts + amount);
  }

  Future<bool> spendExtraBoost() async {
    if (extraBoosts <= 0) return false;
    await _prefs.setInt('extra_boosts', extraBoosts - 1);
    return true;
  }

  // ─── Skin desbloqueada via loja ───────────────────────────────
  List<String> get unlockedSkins {
    return _prefs.getStringList('unlocked_skins') ?? ['classic'];
  }

  Future<void> unlockSkin(String id) async {
    final list = unlockedSkins;
    if (!list.contains(id)) {
      list.add(id);
      await _prefs.setStringList('unlocked_skins', list);
    }
  }

  bool isSkinUnlocked(String id) {
    // Skins comuns sempre desbloqueadas
    const free = ['classic','verde','roxo','laranja','rosa','azul'];
    if (free.contains(id)) return true;
    return unlockedSkins.contains(id);
  }

  // ─── Gastar moedas ────────────────────────────────────────────
  Future<bool> spendCoins(int amount) async {
    if (coins < amount) return false;
    await _prefs.setInt('coins', coins - amount);
    return true;
  }

  // ─── Gastar diamantes ─────────────────────────────────────────
  Future<bool> spendDiamonds(int amount) async {
    if (diamonds < amount) return false;
    await _prefs.setInt('diamonds', diamonds - amount);
    return true;
  }


  // ─── Revives comprados (persistidos) ─────────────────────────
  int get revives => _prefs.getInt('revives') ?? 0;

  Future<void> setRevives(int v) async {
    await _prefs.setInt('revives', v);
  }


  // ─── Pílula de reviver com preço crescente (+2 por compra) ──
  int get revivesBought => _prefs.getInt('revives_bought') ?? 0;

  /// Preço atual da pílula = 10 + (revivesBought * 2)
  int get revivePrice => 10 + revivesBought * 2;

  Future<bool> buyRevive() async {
    final price = revivePrice;
    final ok = await spendCoins(price);
    if (ok) {
      await _prefs.setInt('revives_bought', revivesBought + 1);
      await setRevives(revives + 1);
    }
    return ok;
  }


  // ─── Cosméticos visuais ───────────────────────────────────────
  List<String> get unlockedCosmetics =>
      _prefs.getStringList('unlocked_cosmetics') ?? [];

  Future<void> unlockCosmetic(String id) async {
    final list = unlockedCosmetics;
    if (!list.contains(id)) {
      list.add(id);
      await _prefs.setStringList('unlocked_cosmetics', list);
    }
  }

  bool isCosmeticUnlocked(String id) =>
      unlockedCosmetics.contains(id);


  // ─── Ranking local (top 10 recordes por nome) ────────────────
  static const String _kRankingKey = 'local_ranking';

  List<Map<String, dynamic>> getLocalRanking() {
    final raw = _prefs.getString(_kRankingKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<Map<String, dynamic>> list = [];
      for (final e in raw.split('||')) {
        final parts = e.split('::');
        if (parts.length >= 2) {
          list.add({
            'name': parts[0],
            'score': int.tryParse(parts[1]) ?? 0,
          });
        }
      }
      list.sort((a, b) =>
          (b['score'] as int).compareTo(a['score'] as int));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> submitToLocalRanking(String name, int score) async {
    if (score <= 0) return;
    final list = getLocalRanking();
    list.removeWhere((e) =>
        (e['name'] as String).toLowerCase() == name.toLowerCase());
    list.add({'name': name, 'score': score});
    list.sort((a, b) =>
        (b['score'] as int).compareTo(a['score'] as int));
    final top = list.take(10).toList();
    final raw = top.map((e) => '${e["name"]}::${e["score"]}').join('||');
    await _prefs.setString(_kRankingKey, raw);
  }

}
