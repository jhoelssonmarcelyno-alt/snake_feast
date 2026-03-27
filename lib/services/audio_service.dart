import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  // ── Estado interno ────────────────────────────────────────────
  bool _menuMusicEnabled = true;
  bool _gameMusicEnabled = true;
  bool _sfxEnabled = true;

  double _menuVolume = 0.65;
  double _gameVolume = 0.55;
  double _sfxVolume = 0.70;

  String _currentTrack = '';

  // ── Getters (usados pelo settings_overlay) ────────────────────
  bool get menuMusicEnabled => _menuMusicEnabled;
  bool get gameMusicEnabled => _gameMusicEnabled;
  bool get sfxEnabled => _sfxEnabled;

  double get menuVolume => _menuVolume;
  double get gameVolume => _gameVolume;
  double get sfxVolume => _sfxVolume;

  // ── ATALHOS PARA O MAIN_MENU (Compatibilidade) ────────────────
  /// O menu usa 'isMuted' para o ícone de som.
  bool get isMuted => !_menuMusicEnabled;

  /// O menu chama 'toggleMute' ao clicar no ícone circular.
  void toggleMute() {
    setMenuMusic(!_menuMusicEnabled);
  }

  // ── Init ──────────────────────────────────────────────────────
  Future<void> init() async {
    await _loadPrefs();
    // Carrega os sons na memória para não dar "lag" na primeira vez
    await FlameAudio.audioCache.loadAll([
      'menu_music.mp3',
      'game_music.mp3',
    ]);
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _menuMusicEnabled = prefs.getBool('menuMusicEnabled') ?? true;
    _gameMusicEnabled = prefs.getBool('gameMusicEnabled') ?? true;
    _sfxEnabled = prefs.getBool('sfxEnabled') ?? true;
    _menuVolume = prefs.getDouble('menuVolume') ?? 0.65;
    _gameVolume = prefs.getDouble('gameVolume') ?? 0.55;
    _sfxVolume = prefs.getDouble('sfxVolume') ?? 0.70;
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('menuMusicEnabled', _menuMusicEnabled);
    await prefs.setBool('gameMusicEnabled', _gameMusicEnabled);
    await prefs.setBool('sfxEnabled', _sfxEnabled);
    await prefs.setDouble('menuVolume', _menuVolume);
    await prefs.setDouble('gameVolume', _gameVolume);
    await prefs.setDouble('sfxVolume', _sfxVolume);
  }

  // ── Setters (usados pelo settings_overlay) ────────────────────

  void setMenuMusic(bool enabled) {
    _menuMusicEnabled = enabled;
    _savePrefs();
    if (!enabled && _currentTrack == 'menu_music.mp3') {
      FlameAudio.bgm.pause();
    } else if (enabled && _currentTrack == 'menu_music.mp3') {
      if (FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.resume();
      } else {
        playMenuMusic();
      }
    }
  }

  void setGameMusic(bool enabled) {
    _gameMusicEnabled = enabled;
    _savePrefs();
    if (!enabled && _currentTrack == 'game_music.mp3') {
      FlameAudio.bgm.pause();
    } else if (enabled && _currentTrack == 'game_music.mp3') {
      FlameAudio.bgm.resume();
    }
  }

  void setSfx(bool enabled) {
    _sfxEnabled = enabled;
    _savePrefs();
  }

  void setMenuVolume(double volume) {
    _menuVolume = volume.clamp(0.0, 1.0);
    _savePrefs();
    if (_currentTrack == 'menu_music.mp3') {
      FlameAudio.bgm.audioPlayer.setVolume(_menuVolume);
    }
  }

  void setGameVolume(double volume) {
    _gameVolume = volume.clamp(0.0, 1.0);
    _savePrefs();
    if (_currentTrack == 'game_music.mp3') {
      FlameAudio.bgm.audioPlayer.setVolume(_gameVolume);
    }
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    _savePrefs();
  }

  // ── Controle de música ────────────────────────────────────────

  void playMenuMusic() {
    if (!_menuMusicEnabled) return;
    if (_currentTrack == 'menu_music.mp3') return;
    _currentTrack = 'menu_music.mp3';
    FlameAudio.bgm.play('menu_music.mp3', volume: _menuVolume);
  }

  void playGameMusic() {
    if (!_gameMusicEnabled) return;
    if (_currentTrack == 'game_music.mp3') return;
    _currentTrack = 'game_music.mp3';
    FlameAudio.bgm.play('game_music.mp3', volume: _gameVolume);
  }

  /// Pausa a música atual
  void pause() {
    FlameAudio.bgm.pause();
  }

  /// Retoma a música pausada
  void resume() {
    final isMenuTrack = _currentTrack == 'menu_music.mp3';
    final isGameTrack = _currentTrack == 'game_music.mp3';
    if (isMenuTrack && !_menuMusicEnabled) return;
    if (isGameTrack && !_gameMusicEnabled) return;
    FlameAudio.bgm.resume();
  }

  /// Para completamente e limpa a faixa
  void stop() {
    _currentTrack = '';
    FlameAudio.bgm.stop();
  }
}
