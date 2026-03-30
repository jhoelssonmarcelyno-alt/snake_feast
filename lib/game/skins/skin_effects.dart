// lib/game/skins/skin_effects.dart
import 'snake_skin.dart';

class SkinEffects {
  static double getSpeedBonus(SnakeSkin skin) {
    return skin.speedBonus;
  }

  static double getHealthBonus(SnakeSkin skin) {
    return skin.healthBonus;
  }

  static int getDamageBonus(SnakeSkin skin) {
    // Retorna int
    return skin.damageBonus;
  }

  static double getBoostBonus(SnakeSkin skin) {
    return skin.speedBonus * 0.5;
  }

  static double getRegenBonus(SnakeSkin skin) {
    return skin.healthBonus * 0.5;
  }

  static Map<String, dynamic> getAllBonuses(SnakeSkin skin) {
    return {
      'speed': getSpeedBonus(skin),
      'health': getHealthBonus(skin),
      'damage': getDamageBonus(skin),
      'boost': getBoostBonus(skin),
      'regen': getRegenBonus(skin),
      'totalPower': skin.power,
    };
  }

  static String getFormattedBonuses(SnakeSkin skin) {
    final speed = getSpeedBonus(skin);
    final health = getHealthBonus(skin);
    final damage = getDamageBonus(skin);

    final parts = <String>[];
    if (speed > 0) parts.add('+${(speed * 100).toInt()}% Velocidade');
    if (health > 0) parts.add('+${(health * 100).toInt()}% Vida');
    if (damage > 0) parts.add('+$damage Dano'); // damage é int

    return parts.isEmpty ? 'Sem bônus' : parts.join(' • ');
  }
}
