import 'package:flutter/material.dart';
import '../game/skins/skin_manager.dart';
import '../game/skins/skin_data.dart';

class DevMode {
  static bool _isActive = false;
  
  static Future<void> unlockAllSkins() async {
    try {
      final skinManager = SkinManager();
      await skinManager.init();

      int unlockedCount = 0;
      for (int i = 0; i < kPlayerSkins.length; i++) {
        if (!skinManager.isSkinUnlocked(i)) {
          await skinManager.unlockSkin(i);
          unlockedCount++;
        }
      }
      
      print('🔓 Desbloqueadas $unlockedCount skins! Total: ${kPlayerSkins.length}');
    } catch (e) {
      print('Erro ao desbloquear skins: $e');
    }
  }
  
  static bool isActive() => _isActive;
}
