import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'rank_system.dart';
import 'xp_reward.dart';

class ScoreService {
  ScoreService._();
  static final ScoreService instance = ScoreService._();

  late SharedPreferences _prefs;
  bool _ready = false;

  /// Inicializa o serviço de persistência
  Future<void> init() async {
    if (_ready) return;
    _prefs = await SharedPreferences.getInstance();
    _ready = true;
  }

  // ─── High Score ───────────────────────────────────────────────

  int get highScore => _prefs.getInt(kPrefHighScore) ?? 0;

  /// Submete o XpReward completo de uma partida e salva o recorde
  Future<XpReward> submitFullReward({
    required int score,
    required int kills,
    required int level,
    required double secondsAlive,
    required bool isVictory,
  }) async {
    final reward = RankSystem.calculateReward(
      score: score,
      kills: kills,
      level: level,
      secondsAlive: secondsAlive,
      isVictory: isVictory,
      currentXP: totalXP,
    );

    await addXP(reward.total);

    if (score > highScore) {
      await _prefs.setInt(kPrefHighScore, score);
    }

    _lastXpReward = reward;
    return reward;
  }

  // ─── XP e Patente ─────────────────────────────────────────────

  int get totalXP => _prefs.getInt('total_xp') ?? 0;

  Future<void> addXP(int amount) async {
    if (amount <= 0) return;
    await _prefs.setInt('total_xp', totalXP + amount);
  }

  RankInfo get currentRank => RankSystem.getRankForXP(totalXP);
  RankInfo? get nextRank => RankSystem.getNextRank(currentRank);
  double get rankProgress => RankSystem.rankProgress(totalXP);

  XpReward? _lastXpReward;
  XpReward? get lastXpReward => _lastXpReward;

  // ─── Identidade do Player ─────────────────────────────────────

  String get playerName {
    final n = _prefs.getString('player_name') ?? 'Você';
    return n.trim().isEmpty ? 'Você' : n;
  }

  Future<void> savePlayerName(String name) async {
    final clean = name.trim().isEmpty ? 'Você' : name.trim();
    await _prefs.setString('player_name', clean);
  }

  // ─── Economia (Moedas e Diamantes) ────────────────────────────

  int get coins => _prefs.getInt('coins') ?? 0;
  int get diamonds => _prefs.getInt('diamonds') ?? 0;

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    await _prefs.setInt('coins', coins + amount);
  }

  Future<void> addDiamonds(int amount) async {
    if (amount <= 0) return;
    await _prefs.setInt('diamonds', diamonds + amount);
  }

  Future<bool> spendCoins(int amount) async {
    if (coins < amount) return false;
    await _prefs.setInt('coins', coins - amount);
    return true;
  }

  Future<bool> spendDiamonds(int amount) async {
    if (diamonds < amount) return false;
    await _prefs.setInt('diamonds', diamonds - amount);
    return true;
  }

  // ─── Boost Extra ──────────────────────────────────────────────

  int get extraBoosts => _prefs.getInt('extra_boosts') ?? 0;

  Future<void> addExtraBoosts(int amount) async {
    if (amount <= 0) return;
    await _prefs.setInt('extra_boosts', extraBoosts + amount);
  }

  Future<bool> spendExtraBoost() async {
    if (extraBoosts <= 0) return false;
    await _prefs.setInt('extra_boosts', extraBoosts - 1);
    return true;
  }

  // ─── Customização (Skins e Cosméticos) ────────────────────────

  int get selectedSkinIndex {
    final idx = _prefs.getInt(kPrefSelectedSkin) ?? 0;
    return idx.clamp(0, kPlayerSkins.length - 1);
  }

  Future<void> saveSkinIndex(int index) async {
    await _prefs.setInt(kPrefSelectedSkin, index);
  }

  /// Getter para retornar o objeto da skin selecionada (corrige erro no lobby/shop)
  SnakeSkin get selectedSkin => kPlayerSkins[selectedSkinIndex];

  List<String> get unlockedSkins =>
      _prefs.getStringList('unlocked_skins') ?? ['classic'];

  Future<void> unlockSkin(String id) async {
    final list = unlockedSkins;
    if (!list.contains(id)) {
      list.add(id);
      await _prefs.setStringList('unlocked_skins', list);
    }
  }

  bool isSkinUnlocked(String id) {
    const free = ['classic', 'verde', 'roxo', 'laranja', 'rosa', 'azul'];
    if (free.contains(id)) return true;
    return unlockedSkins.contains(id);
  }

  // ─── Itens Cosméticos (Chapéus, etc) ──────────────────────────

  List<String> get unlockedCosmetics =>
      _prefs.getStringList('unlocked_cosmetics') ?? [];

  Future<void> unlockCosmetic(String id) async {
    final list = List<String>.from(unlockedCosmetics);
    if (!list.contains(id)) {
      list.add(id);
      await _prefs.setStringList('unlocked_cosmetics', list);
    }
  }

  bool isCosmeticUnlocked(String id) => unlockedCosmetics.contains(id);

  // ─── Itens Consumíveis e Revives ──────────────────────────────

  int get revives => _prefs.getInt('revives') ?? 0;
  int get revivesBought => _prefs.getInt('revives_bought') ?? 0;

  int get revivePrice => 10 + (revivesBought * 2);

  Future<bool> buyRevive() async {
    if (await spendCoins(revivePrice)) {
      await _prefs.setInt('revives_bought', revivesBought + 1);
      await _prefs.setInt('revives', revives + 1);
      return true;
    }
    return false;
  }

  Future<bool> useRevive() async {
    if (revives <= 0) return false;
    await _prefs.setInt('revives', revives - 1);
    return true;
  }

  // ─── Ranking Local (Top 10) ───────────────────────────────────

  static const String _kRankingKey = 'local_ranking_v2';

  List<Map<String, dynamic>> getLocalRanking() {
    final raw = _prefs.getString(_kRankingKey) ?? '';
    if (raw.isEmpty) return [];

    final List<Map<String, dynamic>> list = [];
    for (final entry in raw.split('||')) {
      final parts = entry.split('::');
      if (parts.length == 2) {
        list.add({
          'name': parts[0],
          'score': int.tryParse(parts[1]) ?? 0,
        });
      }
    }
    list.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    return list;
  }

  Future<void> submitToLocalRanking(String name, int score) async {
    if (score <= 0) return;
    var list = getLocalRanking();

    list.removeWhere(
        (e) => e['name'].toString().toLowerCase() == name.toLowerCase());
    list.add({'name': name, 'score': score});

    list.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    final topTen = list.take(10).toList();

    final raw = topTen.map((e) => '${e["name"]}::${e["score"]}').join('||');
    await _prefs.setString(_kRankingKey, raw);
  }
}
