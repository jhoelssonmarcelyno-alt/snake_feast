import 'package:flutter/material.dart';
import 'world_progress_service.dart';
import 'skin_progress_service.dart';

class ProgressSyncService {
  static final ProgressSyncService _instance = ProgressSyncService._internal();
  factory ProgressSyncService() => _instance;
  ProgressSyncService._internal();
  
  // Quando um mundo é desbloqueado, também desbloqueia a skin correspondente
  Future<void> onWorldUnlocked(int worldIndex) async {
    // O mundo 0 desbloqueia a skin 10
    // O mundo 1 desbloqueia a skin 11, etc.
    final targetSkinId = 10 + worldIndex;
    
    if (targetSkinId < 250) {
      // Verifica se a skin ainda não está desbloqueada
      if (!SkinProgressService().isSkinUnlocked(targetSkinId)) {
        // Para desbloquear a skin, precisamos "falsificar" vitórias
        // Vamos simular as 10 vitórias para a skin
        for (int i = 0; i < 10; i++) {
          await SkinProgressService().recordWinForSkin(targetSkinId);
        }
        debugPrint('🎨 Mundo $worldIndex desbloqueou a skin $targetSkinId!');
      }
    }
  }
  
  // Retorna a próxima skin a ser desbloqueada
  int getNextSkinToUnlock() {
    return SkinProgressService().nextSkinToUnlock;
  }
}
