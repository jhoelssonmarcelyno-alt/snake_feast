// lib/overlays/settings_overlay.dart
import 'package:flutter/material.dart';
import '../game/snake_engine.dart';
import '../services/haptic_service.dart';
import '../services/audio_service.dart';
import '../utils/constants.dart';

class SettingsOverlay extends StatefulWidget {
  final SnakeEngine engine;
  const SettingsOverlay({super.key, required this.engine});

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  bool _haptic = true;
  bool _menuMusicEnabled = true;
  bool _gameMusicEnabled = true;
  bool _sfx = true;

  double _menuVolume = 0.65;
  double _gameVolume = 0.55;
  double _sfxVolume = 0.70;

  static const _noLine = TextStyle(decoration: TextDecoration.none);

  @override
  void initState() {
    super.initState();
    _haptic = HapticService.instance.enabled;

    // Carrega estados do AudioService
    _menuMusicEnabled = AudioService.instance.menuMusicEnabled;
    _gameMusicEnabled = AudioService.instance.gameMusicEnabled;
    _sfx = AudioService.instance.sfxEnabled;
    _menuVolume = AudioService.instance.menuVolume;
    _gameVolume = AudioService.instance.gameVolume;
    _sfxVolume = AudioService.instance.sfxVolume;

    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _close() => widget.engine.overlays.remove(kOverlaySettings);

  void _toggleHaptic(bool v) {
    setState(() => _haptic = v);
    HapticService.instance.enabled = v;
    if (v) HapticService.instance.light();
  }

  void _toggleMenuMusic(bool v) {
    setState(() => _menuMusicEnabled = v);
    AudioService.instance.setMenuMusic(v);
  }

  void _toggleGameMusic(bool v) {
    setState(() => _gameMusicEnabled = v);
    AudioService.instance.setGameMusic(v);
  }

  void _toggleSfx(bool v) {
    setState(() => _sfx = v);
    AudioService.instance.setSfx(v);
  }

  void _onMenuVolumeChange(double v) {
    setState(() => _menuVolume = v);
    AudioService.instance.setMenuVolume(v);
  }

  void _onGameVolumeChange(double v) {
    setState(() => _gameVolume = v);
    AudioService.instance.setGameVolume(v);
  }

  void _onSfxVolumeChange(double v) {
    setState(() => _sfxVolume = v);
    AudioService.instance.setSfxVolume(v);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: _noLine,
        child: GestureDetector(
          onTap: _close,
          child: Container(
            color: Colors.black.withValues(alpha: 0.75),
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 360,
                      constraints: const BoxConstraints(maxHeight: 580),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: const Color(0xFF070F1A),
                        border: Border.all(
                            color:
                                const Color(0xFF00E5FF).withValues(alpha: 0.2),
                            width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF00E5FF).withValues(alpha: 0.12),
                            blurRadius: 40,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Header(onClose: _close),
                          Flexible(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                              child: Column(
                                children: [
                                  // ── SEÇÃO: MÚSICA DO MENU ──────────
                                  _SectionTitle(
                                    icon: Icons.menu_open_rounded,
                                    label: 'MÚSICA DO MENU',
                                    color: const Color(0xFF00E5FF),
                                  ),
                                  const SizedBox(height: 8),
                                  _SettingTile(
                                    icon: Icons.music_note_rounded,
                                    iconColor: const Color(0xFF00E5FF),
                                    title: 'Música do Menu',
                                    subtitle: _menuMusicEnabled
                                        ? 'Ativada'
                                        : 'Desativada',
                                    trailing: _Switch(
                                        value: _menuMusicEnabled,
                                        onChanged: _toggleMenuMusic),
                                  ),
                                  if (_menuMusicEnabled) ...[
                                    const SizedBox(height: 4),
                                    _VolumeSlider(
                                      icon: Icons.volume_up_rounded,
                                      color: const Color(0xFF00E5FF),
                                      label: 'Volume',
                                      value: _menuVolume,
                                      onChanged: _onMenuVolumeChange,
                                    ),
                                  ],

                                  _Divider(),
                                  const SizedBox(height: 4),

                                  // ── SEÇÃO: MÚSICA DO JOGO ──────────
                                  _SectionTitle(
                                    icon: Icons.sports_esports_rounded,
                                    label: 'MÚSICA DO JOGO',
                                    color: const Color(0xFF69F0AE),
                                  ),
                                  const SizedBox(height: 8),
                                  _SettingTile(
                                    icon: Icons.music_note_rounded,
                                    iconColor: const Color(0xFF69F0AE),
                                    title: 'Música do Jogo',
                                    subtitle: _gameMusicEnabled
                                        ? 'Ativada'
                                        : 'Desativada',
                                    trailing: _Switch(
                                        value: _gameMusicEnabled,
                                        color: const Color(0xFF69F0AE),
                                        onChanged: _toggleGameMusic),
                                  ),
                                  if (_gameMusicEnabled) ...[
                                    const SizedBox(height: 4),
                                    _VolumeSlider(
                                      icon: Icons.volume_up_rounded,
                                      color: const Color(0xFF69F0AE),
                                      label: 'Volume',
                                      value: _gameVolume,
                                      onChanged: _onGameVolumeChange,
                                    ),
                                  ],

                                  _Divider(),
                                  const SizedBox(height: 4),

                                  // ── SEÇÃO: EFEITOS SONOROS ─────────
                                  _SectionTitle(
                                    icon: Icons.graphic_eq_rounded,
                                    label: 'EFEITOS SONOROS',
                                    color: const Color(0xFFFFD600),
                                  ),
                                  const SizedBox(height: 8),
                                  _SettingTile(
                                    icon: Icons.volume_up_rounded,
                                    iconColor: const Color(0xFFFFD600),
                                    title: 'Efeitos Sonoros',
                                    subtitle: _sfx ? 'Ativados' : 'Desativados',
                                    trailing: _Switch(
                                        value: _sfx,
                                        color: const Color(0xFFFFD600),
                                        onChanged: _toggleSfx),
                                  ),
                                  if (_sfx) ...[
                                    const SizedBox(height: 4),
                                    _VolumeSlider(
                                      icon: Icons.graphic_eq_rounded,
                                      color: const Color(0xFFFFD600),
                                      label: 'Volume',
                                      value: _sfxVolume,
                                      onChanged: _onSfxVolumeChange,
                                    ),
                                  ],

                                  _Divider(),
                                  const SizedBox(height: 4),

                                  // ── VIBRAÇÃO ───────────────────────
                                  _SettingTile(
                                    icon: Icons.vibration_rounded,
                                    iconColor: const Color(0xFFFF80AB),
                                    title: 'Vibração',
                                    subtitle:
                                        _haptic ? 'Ativada' : 'Desativada',
                                    trailing: _Switch(
                                        value: _haptic,
                                        color: const Color(0xFFFF80AB),
                                        onChanged: _toggleHaptic),
                                  ),

                                  _Divider(),
                                  const SizedBox(height: 4),

                                  // ── SOBRE ──────────────────────────
                                  _SettingTile(
                                    icon: Icons.info_outline_rounded,
                                    iconColor: const Color(0xFF546E7A),
                                    title: 'Sobre',
                                    subtitle: 'Serpent Strike v1.0',
                                    trailing: const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Color(0xFF546E7A)),
                                    onTap: () => _showAbout(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Material(
        color: Colors.transparent,
        child: DefaultTextStyle(
          style: _noLine,
          child: Center(
            child: Container(
              width: 300,
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFF070F1A),
                border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                      border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                          width: 1.5),
                    ),
                    child: const Icon(Icons.sports_esports_rounded,
                        color: Color(0xFF00E5FF), size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text('SERPENT STRIKE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          decoration: TextDecoration.none)),
                  const SizedBox(height: 4),
                  const Text('Versão 1.0.0',
                      style: TextStyle(
                          color: Color(0xFF546E7A),
                          fontSize: 12,
                          decoration: TextDecoration.none)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.03),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: const Text(
                      'Jogo de cobra com bots inteligentes, '
                      'skins exclusivas e partículas de morte épicas.\n\n'
                      'Feito com Flutter + Flame.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF78909C),
                          fontSize: 12,
                          height: 1.6,
                          decoration: TextDecoration.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: double.infinity,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(colors: [
                          const Color(0xFF00E5FF).withValues(alpha: 0.15),
                          const Color(0xFF69F0AE).withValues(alpha: 0.10),
                        ]),
                        border: Border.all(
                            color:
                                const Color(0xFF00E5FF).withValues(alpha: 0.35),
                            width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: const Text('FECHAR',
                          style: TextStyle(
                              color: Color(0xFF00E5FF),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                              decoration: TextDecoration.none)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── WIDGETS INTERNOS ─────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionTitle(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: color, size: 12),
      const SizedBox(width: 6),
      Text(label,
          style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              decoration: TextDecoration.none)),
      const SizedBox(width: 8),
      Expanded(
          child: Container(height: 1, color: color.withValues(alpha: 0.18))),
    ]);
  }
}

class _VolumeSlider extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _VolumeSlider({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(Icons.volume_down_rounded,
            color: color.withValues(alpha: 0.5), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.18),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.18),
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.volume_up_rounded,
            color: color.withValues(alpha: 0.5), size: 16),
        const SizedBox(width: 8),
        SizedBox(
          width: 34,
          child: Text(
            '${(value * 100).round()}%',
            textAlign: TextAlign.right,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none),
          ),
        ),
      ]),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        gradient: LinearGradient(colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.08),
          Colors.transparent,
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border(
            bottom: BorderSide(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.1))),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
            border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.settings_rounded,
              color: Color(0xFF00E5FF), size: 18),
        ),
        const SizedBox(width: 12),
        const Text('CONFIGURAÇÕES',
            style: TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                decoration: TextDecoration.none)),
        const Spacer(),
        GestureDetector(
          onTap: onClose,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Icon(Icons.close_rounded,
                color: Color(0xFF546E7A), size: 16),
          ),
        ),
      ]),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.10),
              border: Border.all(
                  color: iconColor.withValues(alpha: 0.25), width: 1),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none)),
              Text(subtitle,
                  style: const TextStyle(
                      color: Color(0xFF546E7A),
                      fontSize: 11,
                      decoration: TextDecoration.none)),
            ]),
          ),
          trailing,
        ]),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;

  const _Switch({
    required this.value,
    required this.onChanged,
    this.color = const Color(0xFF00E5FF),
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      // CORREÇÃO: activeColor → activeThumbColor (deprecated após v3.31)
      activeThumbColor: color,
      activeTrackColor: color.withValues(alpha: 0.25),
      inactiveThumbColor: const Color(0xFF546E7A),
      inactiveTrackColor: const Color(0xFF546E7A).withValues(alpha: 0.15),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: Colors.white.withValues(alpha: 0.05));
}
