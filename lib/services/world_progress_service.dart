import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'progress_sync_service.dart';

class WorldProgressService {
  static final WorldProgressService _instance = WorldProgressService._internal();
  factory WorldProgressService() => _instance;
  WorldProgressService._internal();
  
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  
  Map<int, int> _worldWins = {};
  int _maxUnlockedWorld = 0;
  bool _devMode = false;
  
  static const int WINS_NEEDED = 10;
  
  Future<void> init({bool devMode = false}) async {
    if (_isInitialized) return;
    
    _devMode = devMode;
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
    _isInitialized = true;
  }
  
  Future<void> _loadData() async {
    for (int i = 0; i < 250; i++) {
      final wins = _prefs.getInt('world_wins_$i') ?? 0;
      _worldWins[i] = wins;
    }
    _maxUnlockedWorld = _prefs.getInt('max_unlocked_world') ?? 0;
    if (_maxUnlockedWorld < 0) _maxUnlockedWorld = 0;
  }
  
  Future<void> _saveData() async {
    for (var entry in _worldWins.entries) {
      await _prefs.setInt('world_wins_${entry.key}', entry.value);
    }
    await _prefs.setInt('max_unlocked_world', _maxUnlockedWorld);
  }
  
  Future<void> recordWin(int worldIndex) async {
    if (_devMode) return;
    if (worldIndex < 0 || worldIndex >= 250) return;
    
    final currentWins = _worldWins[worldIndex] ?? 0;
    final newWins = currentWins + 1;
    _worldWins[worldIndex] = newWins;
    
    // Verifica se desbloqueia o próximo mundo
    if (newWins >= WINS_NEEDED && worldIndex + 1 > _maxUnlockedWorld) {
      _maxUnlockedWorld = worldIndex + 1;
      if (_maxUnlockedWorld > 249) _maxUnlockedWorld = 249;
      
      // Sincroniza: quando um mundo é desbloqueado, desbloqueia a skin correspondente
      await ProgressSyncService().onWorldUnlocked(worldIndex);
    }
    
    await _saveData();
  }
  
  bool isWorldUnlocked(int worldIndex) {
    if (_devMode) return true;
    return worldIndex <= _maxUnlockedWorld;
  }
  
  int getWorldWins(int worldIndex) {
    if (_devMode) return WINS_NEEDED;
    return _worldWins[worldIndex] ?? 0;
  }
  
  double getWorldProgress(int worldIndex) {
    if (_devMode) return 1.0;
    final wins = getWorldWins(worldIndex);
    return (wins / WINS_NEEDED).clamp(0.0, 1.0);
  }
  
  int getWinsNeededForNext(int worldIndex) {
    if (_devMode) return 0;
    final wins = getWorldWins(worldIndex);
    final needed = WINS_NEEDED - wins;
    return needed > 0 ? needed : 0;
  }
  
  int get nextWorldToUnlock {
    if (_devMode) return 1;
    return _maxUnlockedWorld + 1;
  }
  
  bool get hasNextWorld {
    if (_devMode) return true;
    return nextWorldToUnlock < 250;
  }
  
  double getUnlockProgress() {
    final unlocked = _maxUnlockedWorld + 1;
    return unlocked / 250;
  }
  
  Future<void> resetAllProgress() async {
    if (_devMode) return;
    _worldWins.clear();
    _maxUnlockedWorld = 0;
    await _saveData();
  }
  
  void setDevMode(bool enabled) {
    _devMode = enabled;
  }
  
  bool get isDevMode => _devMode;
}
