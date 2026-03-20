// lib/services/audio_service.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de áudio — preparado para receber os arquivos.
/// Quando os arquivos estiverem em assets/audio/, basta
/// descomentar as linhas marcadas com [AUDIO].
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  bool _musicEnabled = true;
  bool _sfxEnabled = true;

  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;

  // ─── Persistência ────────────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _musicEnabled = prefs.getBool('music_enabled') ?? true;
    _sfxEnabled = prefs.getBool('sfx_enabled') ?? true;
  }

  Future<void> setMusic(bool value) async {
    _musicEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', value);
    // [AUDIO] if (value) playMenuMusic(); else stopMusic();
  }

  Future<void> setSfx(bool value) async {
    _sfxEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sfx_enabled', value);
  }

  // ─── Efeitos (chamar quando tiver os arquivos) ────────────────
  void playEat() {/* [AUDIO] if (_sfxEnabled) _play('eat.mp3'); */}
  void playBoost() {/* [AUDIO] if (_sfxEnabled) _play('boost.mp3'); */}
  void playKill() {/* [AUDIO] if (_sfxEnabled) _play('kill.mp3'); */}
  void playDie() {/* [AUDIO] if (_sfxEnabled) _play('die.mp3'); */}

  void playMenuMusic() {
    /* [AUDIO] if (_musicEnabled) _playLoop('menu_music.mp3'); */
  }
  void playGameMusic() {
    /* [AUDIO] if (_musicEnabled) _playLoop('game_music.mp3'); */
  }
  void stopMusic() {/* [AUDIO] _stopLoop(); */}
}
