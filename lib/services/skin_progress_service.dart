import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'world_progress_service.dart';
import '../../utils/constants.dart';

class SkinProgressService {
  static final SkinProgressService _instance = SkinProgressService._internal();
  factory SkinProgressService() => _instance;
  SkinProgressService._internal();
  
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  bool _devMode = false;
  
  // Última skin desbloqueada (índice)
  int _maxUnlockedSkin = 9; // Começa com 10 skins (0-9)
  
  // Vitórias por skin (para a skin atual que está sendo trabalhada)
  Map<int, int> _skinWins = {};
  
  // Número de vitórias necessárias para desbloquear a próxima skin
  static const int WINS_NEEDED = 10;
  
  Future<void> init({bool devMode = false}) async {
    if (_isInitialized) return;
    
    _devMode = devMode;
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
    _isInitialized = true;
  }
  
  Future<void> _loadData() async {
    if (_devMode) {
      // Modo desenvolvedor: todas as skins desbloqueadas
      _maxUnlockedSkin = 249;
      _skinWins.clear();
      return;
    }
    
    // Carrega a última skin desbloqueada
    _maxUnlockedSkin = _prefs.getInt('max_unlocked_skin') ?? 9;
    if (_maxUnlockedSkin < 9) _maxUnlockedSkin = 9;
    if (_maxUnlockedSkin > 249) _maxUnlockedSkin = 249;
    
    // Carrega vitórias para a próxima skin (a que está tentando desbloquear)
    final nextSkinId = _maxUnlockedSkin + 1;
    if (nextSkinId < 250) {
      _skinWins[nextSkinId] = _prefs.getInt('skin_wins_$nextSkinId') ?? 0;
    }
  }
  
  Future<void> _saveData() async {
    if (_devMode) return;
    
    await _prefs.setInt('max_unlocked_skin', _maxUnlockedSkin);
    
    final nextSkinId = _maxUnlockedSkin + 1;
    if (nextSkinId < 250) {
      await _prefs.setInt('skin_wins_$nextSkinId', _skinWins[nextSkinId] ?? 0);
    }
  }
  
  // Registra uma vitória para a skin atual
  Future<void> recordWinForSkin(int skinId) async {
    if (_devMode) return;
    if (skinId < 0 || skinId >= 250) return;
    
    // Só processa vitórias para a próxima skin a ser desbloqueada
    final nextSkinId = _maxUnlockedSkin + 1;
    if (skinId != nextSkinId) return;
    
    final currentWins = _skinWins[nextSkinId] ?? 0;
    final newWins = currentWins + 1;
    _skinWins[nextSkinId] = newWins;
    
    // Se atingiu 10 vitórias, desbloqueia a próxima skin
    if (newWins >= WINS_NEEDED) {
      _maxUnlockedSkin = nextSkinId;
      _skinWins.remove(nextSkinId);
      debugPrint('🎨 Skin $nextSkinId desbloqueada! Próxima: ${_maxUnlockedSkin + 1}');
    }
    
    await _saveData();
  }
  
  // Verifica se uma skin está desbloqueada
  bool isSkinUnlocked(int skinId) {
    if (_devMode) return true; // Modo dev: todas desbloqueadas
    return skinId <= _maxUnlockedSkin;
  }
  
  // Retorna o progresso da próxima skin (0 a 1)
  double getNextSkinProgress() {
    if (_devMode) return 1.0;
    
    final nextSkinId = _maxUnlockedSkin + 1;
    if (nextSkinId >= 250) return 1.0;
    
    final wins = _skinWins[nextSkinId] ?? 0;
    return (wins / WINS_NEEDED).clamp(0.0, 1.0);
  }
  
  // Retorna quantas vitórias faltam para a próxima skin
  int getWinsNeededForNextSkin() {
    if (_devMode) return 0;
    
    final nextSkinId = _maxUnlockedSkin + 1;
    if (nextSkinId >= 250) return 0;
    
    final wins = _skinWins[nextSkinId] ?? 0;
    return WINS_NEEDED - wins;
  }
  
  // Retorna o índice da próxima skin a ser desbloqueada
  int get nextSkinToUnlock {
    if (_devMode) return 0;
    final next = _maxUnlockedSkin + 1;
    return next < 250 ? next : -1;
  }
  
  // Retorna o total de skins desbloqueadas
  int get unlockedCount {
    if (_devMode) return 250;
    return _maxUnlockedSkin + 1;
  }
  
  // Retorna o progresso total (0 a 1)
  double getTotalProgress() {
    if (_devMode) return 1.0;
    return unlockedCount / 250;
  }
  
  // Reseta todo o progresso (apenas para teste)
  Future<void> resetAllProgress() async {
    if (_devMode) return;
    _maxUnlockedSkin = 9;
    _skinWins.clear();
    await _saveData();
  }
  
  void setDevMode(bool enabled) {
    _devMode = enabled;
    _loadData(); // Recarrega dados com o novo modo
  }
  
  bool get isDevMode => _devMode;
}
