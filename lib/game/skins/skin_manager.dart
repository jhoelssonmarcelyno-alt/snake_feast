// lib/game/skins/skin_manager.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'snake_skin.dart';
import 'skin_data.dart';
import 'skin_effects.dart';
import 'skin_rarity.dart';

class SkinManager {
  static final SkinManager _instance = SkinManager._internal();
  factory SkinManager() => _instance;
  SkinManager._internal();
  
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  
  int _selectedSkinId = 0;
  Set<int> _unlockedSkins = {};
  
  Future<void> init() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    _selectedSkinId = _prefs.getInt('selected_skin') ?? 0;
    
    final unlockedList = _prefs.getStringList('unlocked_skins') ?? [];
    _unlockedSkins = unlockedList.map((id) => int.tryParse(id)).whereType<int>().toSet();
    
    if (_unlockedSkins.isEmpty && kPlayerSkins.isNotEmpty) {
      await unlockSkin(0);
    }
    
    _isInitialized = true;
  }
  
  SnakeSkin get selectedSkin {
    final index = _selectedSkinId.clamp(0, kPlayerSkins.length - 1);
    return kPlayerSkins[index];
  }
  
  int get selectedSkinId => _selectedSkinId;
  
  Future<void> selectSkin(int skinId) async {
    if (!isSkinUnlocked(skinId)) return;
    
    _selectedSkinId = skinId.clamp(0, kPlayerSkins.length - 1);
    await _prefs.setInt('selected_skin', _selectedSkinId);
  }
  
  bool isSkinUnlocked(int skinId) {
    if (skinId < 0 || skinId >= kPlayerSkins.length) return false;
    if (skinId < 10) return true;
    return _unlockedSkins.contains(skinId);
  }
  
  Future<void> unlockSkin(int skinId) async {
    if (skinId < 0 || skinId >= kPlayerSkins.length) return;
    if (isSkinUnlocked(skinId)) return;
    
    _unlockedSkins.add(skinId);
    await _saveUnlockedSkins();
  }
  
  Future<void> _saveUnlockedSkins() async {
    final list = _unlockedSkins.map((id) => id.toString()).toList();
    await _prefs.setStringList('unlocked_skins', list);
  }
  
  int get nextSkinToUnlock {
    for (int i = 0; i < kPlayerSkins.length; i++) {
      if (!isSkinUnlocked(i)) return i;
    }
    return -1;
  }
  
  int getUnlockCost(int skinId) {
    final skin = kPlayerSkins[skinId];
    return 100 + (skin.power * 10);
  }
  
  double getUnlockProgress() {
    final unlocked = _unlockedSkins.length + 10;
    return unlocked / kPlayerSkins.length;
  }
  
  int getUnlockPercentage() {
    return (getUnlockProgress() * 100).toInt();
  }
  
  List<SnakeSkin> getSkinsByRarity(SkinRarity rarity) {
    return kPlayerSkins.where((skin) => skin.rarity == rarity).toList();
  }
  
  List<SnakeSkin> getUnlockedSkins() {
    return kPlayerSkins.where((skin) => isSkinUnlocked(kPlayerSkins.indexOf(skin))).toList();
  }
  
  List<SnakeSkin> getLockedSkins() {
    return kPlayerSkins.where((skin) => !isSkinUnlocked(kPlayerSkins.indexOf(skin))).toList();
  }
  
  Map<SkinRarity, List<SnakeSkin>> getSkinsGroupedByRarity() {
    final Map<SkinRarity, List<SnakeSkin>> grouped = {};
    for (final skin in kPlayerSkins) {
      grouped.putIfAbsent(skin.rarity, () => []).add(skin);
    }
    return grouped;
  }
  
  int getTotalPower() {
    return selectedSkin.power;
  }
  
  Map<String, dynamic> getCurrentBonuses() {
    return SkinEffects.getAllBonuses(selectedSkin);
  }
  
  bool canUnlockNextSkin(int currentScore) {
    final nextId = nextSkinToUnlock;
    if (nextId == -1) return false;
    final cost = getUnlockCost(nextId);
    return currentScore >= cost;
  }
  
  Future<bool> tryUnlockNextSkin(int currentScore) async {
    final nextId = nextSkinToUnlock;
    if (nextId == -1) return false;
    
    final cost = getUnlockCost(nextId);
    if (currentScore >= cost) {
      await unlockSkin(nextId);
      return true;
    }
    return false;
  }
  
  Future<void> resetAllSkins() async {
    _unlockedSkins.clear();
    _selectedSkinId = 0;
    await _saveUnlockedSkins();
    await _prefs.setInt('selected_skin', 0);
  }
  
  String getSelectedSkinDescription() {
    final skin = selectedSkin;
    final bonuses = SkinEffects.getFormattedBonuses(skin);
    return '${skin.name}\nPoder ${skin.power}\n$bonuses';
  }
  
  SnakeSkin? getSkinById(int id) {
    if (id < 0 || id >= kPlayerSkins.length) return null;
    return kPlayerSkins[id];
  }
  
  List<SnakeSkin> getSkinsByPowerRange(int minPower, int maxPower) {
    return kPlayerSkins.where((skin) => 
      skin.power >= minPower && skin.power <= maxPower
    ).toList();
  }
  
  List<SnakeSkin> getSkinsWithBonus(String bonusType) {
    return kPlayerSkins.where((skin) {
      switch (bonusType) {
        case 'speed':
          return skin.speedBonus > 0;
        case 'health':
          return skin.healthBonus > 0;
        case 'damage':
          return skin.damageBonus > 0;
        default:
          return false;
      }
    }).toList();
  }
}
