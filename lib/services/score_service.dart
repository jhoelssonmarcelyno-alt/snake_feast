import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame_audio/flame_audio.dart';
import 'rank_system.dart';
import 'xp_reward.dart';
import 'wins_service.dart';

class ScoreService {
  static final ScoreService _instance = ScoreService._internal();
  factory ScoreService() => _instance;
  ScoreService._internal();

  static const String _prefHighScore = 'high_score';
  static const String _prefPlayerName = 'player_name';
  static const String _prefCoins = 'coins';
  static const String _prefDiamonds = 'diamonds';
  static const String _prefRevives = 'revives';
  static const String _prefExtraBoosts = 'extra_boosts';
  static const String _prefUnlockedSkins = 'unlocked_skins';
  static const String _prefSelectedSkin = 'selected_skin';
  static const String _prefUnlockedCosmetics = 'unlocked_cosmetics';
  static const String _prefTotalScore = 'total_score';

  late SharedPreferences _prefs;
  bool _initialized = false;

  int _highScore = 0;
  int _coins = 0;
  int _diamonds = 0;
  int _revives = 0;
  int _extraBoosts = 0;
  int _revivePrice = 100;
  String _playerName = 'Jogador';
  int _totalScore = 0;

  List<String> _unlockedSkins = [];
  int _selectedSkinIndex = 0;
  List<String> _unlockedCosmetics = [];
  XpReward? _lastXpReward;

  // Getters
  static ScoreService get instance => _instance;
  int get highScore => _highScore;
  int get coins => _coins;
  int get diamonds => _diamonds;
  int get revives => _revives;
  int get extraBoosts => _extraBoosts;
  int get revivePrice => _revivePrice;
  String get playerName => _playerName;
  List<String> get unlockedSkins => _unlockedSkins;
  int get selectedSkinIndex => _selectedSkinIndex;
  List<String> get unlockedCosmetics => _unlockedCosmetics;
  XpReward? get lastXpReward => _lastXpReward;
  int get totalScore => _totalScore;

  // Propriedades de rank baseadas em vitórias
  RankInfo get currentRank {
    final wins = WinsService().totalWins as int;
    return RankSystem.getRankForWins(wins);
  }
  
  RankInfo? get nextRank {
    final wins = WinsService().totalWins as int;
    final current = RankSystem.getRankForWins(wins);
    return RankSystem.getNextRank(current);
  }
  
  double get rankProgress {
    final wins = WinsService().totalWins as int;
    return RankSystem.rankProgress(wins);
  }
  
  int get totalXP {
    final wins = WinsService().totalWins as int;
    final rank = RankSystem.getRankForWins(wins);
    return rank.winsRequired;
  }

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _loadData();
    _initialized = true;
  }

  void _loadData() {
    _highScore = _prefs.getInt(_prefHighScore) ?? 0;
    _coins = _prefs.getInt(_prefCoins) ?? 0;
    _diamonds = _prefs.getInt(_prefDiamonds) ?? 0;
    _revives = _prefs.getInt(_prefRevives) ?? 3;
    _extraBoosts = _prefs.getInt(_prefExtraBoosts) ?? 0;
    _playerName = _prefs.getString(_prefPlayerName) ?? 'Jogador';
    _totalScore = _prefs.getInt(_prefTotalScore) ?? 0;

    _unlockedSkins = _prefs.getStringList(_prefUnlockedSkins) ?? [];
    _selectedSkinIndex = _prefs.getInt(_prefSelectedSkin) ?? 0;
    _unlockedCosmetics = _prefs.getStringList(_prefUnlockedCosmetics) ?? [];

    if (_unlockedSkins.isEmpty) {
      _unlockedSkins.add('classic');
      _saveSkins();
    }
  }

  Future<void> _saveData() async {
    await _prefs.setInt(_prefHighScore, _highScore);
    await _prefs.setInt(_prefCoins, _coins);
    await _prefs.setInt(_prefDiamonds, _diamonds);
    await _prefs.setInt(_prefRevives, _revives);
    await _prefs.setInt(_prefExtraBoosts, _extraBoosts);
    await _prefs.setString(_prefPlayerName, _playerName);
    await _prefs.setInt(_prefTotalScore, _totalScore);
  }

  void _saveSkins() {
    _prefs.setStringList(_prefUnlockedSkins, _unlockedSkins);
    _prefs.setInt(_prefSelectedSkin, _selectedSkinIndex);
  }

  void _saveCosmetics() {
    _prefs.setStringList(_prefUnlockedCosmetics, _unlockedCosmetics);
  }

  Future<void> addCoins(int amount) async {
    _coins += amount;
    await _saveData();
  }

  Future<bool> spendCoins(int amount) async {
    if (_coins >= amount) {
      _coins -= amount;
      await _saveData();
      return true;
    }
    return false;
  }

  Future<void> addDiamonds(int amount) async {
    _diamonds += amount;
    await _saveData();
  }

  Future<bool> spendDiamonds(int amount) async {
    if (_diamonds >= amount) {
      _diamonds -= amount;
      await _saveData();
      return true;
    }
    return false;
  }

  Future<bool> buyRevive() async {
    if (_coins >= _revivePrice) {
      _coins -= _revivePrice;
      _revives++;
      _revivePrice = (100 + (_revives * 10)).clamp(100, 1000);
      await _saveData();
      return true;
    }
    return false;
  }

  void useRevive() {
    if (_revives > 0) {
      _revives--;
      _saveData();
    }
  }

  Future<void> addExtraBoosts(int amount) async {
    _extraBoosts += amount;
    await _saveData();
  }

  bool useBoost() {
    if (_extraBoosts > 0) {
      _extraBoosts--;
      _saveData();
      return true;
    }
    return false;
  }

  bool isSkinUnlocked(String skinId) {
    return _unlockedSkins.contains(skinId);
  }

  Future<void> unlockSkin(String skinId) async {
    if (!_unlockedSkins.contains(skinId)) {
      _unlockedSkins.add(skinId);
      _saveSkins();
    }
  }

  Future<void> saveSkinIndex(int index) async {
    _selectedSkinIndex = index;
    await _prefs.setInt(_prefSelectedSkin, index);
  }

  bool isCosmeticUnlocked(String cosmeticId) {
    return _unlockedCosmetics.contains(cosmeticId);
  }

  Future<void> unlockCosmetic(String cosmeticId) async {
    if (!_unlockedCosmetics.contains(cosmeticId)) {
      _unlockedCosmetics.add(cosmeticId);
      _saveCosmetics();
    }
  }

  Future<void> updateHighScore(int score) async {
    if (score > _highScore) {
      _highScore = score;
      await _saveData();
    }
  }

  Future<void> setPlayerName(String name) async {
    _playerName = name.trim();
    if (_playerName.isEmpty) _playerName = 'Jogador';
    await _prefs.setString(_prefPlayerName, _playerName);
  }

  Future<void> addScore(int score) async {
    _totalScore += score;
    await _saveData();
    await updateHighScore(score);
  }

  void resetCurrentScore() {}

  Future<void> submitFullReward({
    required int score,
    required int kills,
    required int level,
    required double secondsAlive,
    required bool isVictory,
  }) async {
    final wins = WinsService().totalWins;
    
    _lastXpReward = RankSystem.calculateReward(
      score: score,
      kills: kills,
      level: level,
      secondsAlive: secondsAlive,
      isVictory: isVictory,
      totalWins: wins,
    );
    
    final xpTotal = _lastXpReward!.total;
    await addCoins(xpTotal ~/ 10);
    
    if (isVictory) {
      await WinsService().addWin();
    }
  }
}
