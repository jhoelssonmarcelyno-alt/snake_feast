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
  bool _music = true;
  bool _sfx = true;

  static const _noLine = TextStyle(decoration: TextDecoration.none);

  @override
  void initState() {
    super.initState();
    _haptic = HapticService.instance.enabled;
    _music = AudioService.instance.musicEnabled;
    _sfx = AudioService.instance.sfxEnabled;

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

  void _toggleMusic(bool v) {
    setState(() => _music = v);
    AudioService.instance.setMusic(v);
  }

  void _toggleSfx(bool v) {
    setState(() => _sfx = v);
    AudioService.instance.setSfx(v);
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
            color: Colors.black.withOpacity(0.75),
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 340,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: const Color(0xFF070F1A),
                        border: Border.all(
                            color: const Color(0xFF00E5FF).withOpacity(0.2),
                            width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withOpacity(0.12),
                            blurRadius: 40,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Header ─────────────────────────
                          _Header(onClose: _close),

                          // ── Opções ──────────────────────────
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                            child: Column(children: [
                              // Música
                              _SettingTile(
                                icon: Icons.music_note_rounded,
                                iconColor: const Color(0xFF00E5FF),
                                title: 'Música',
                                subtitle: _music ? 'Ativada' : 'Desativada',
                                trailing: _Switch(
                                    value: _music, onChanged: _toggleMusic),
                              ),

                              _Divider(),

                              // Som / SFX
                              _SettingTile(
                                icon: Icons.volume_up_rounded,
                                iconColor: const Color(0xFF69F0AE),
                                title: 'Efeitos sonoros',
                                subtitle: _sfx ? 'Ativados' : 'Desativados',
                                trailing:
                                    _Switch(value: _sfx, onChanged: _toggleSfx),
                              ),

                              _Divider(),

                              // Vibração
                              _SettingTile(
                                icon: Icons.vibration_rounded,
                                iconColor: const Color(0xFFFFD600),
                                title: 'Vibração',
                                subtitle: _haptic ? 'Ativada' : 'Desativada',
                                trailing: _Switch(
                                    value: _haptic, onChanged: _toggleHaptic),
                              ),

                              _Divider(),

                              // Sobre
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

                              const SizedBox(height: 8),
                            ]),
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
                    color: const Color(0xFF00E5FF).withOpacity(0.2),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.1),
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
                      color: const Color(0xFF00E5FF).withOpacity(0.08),
                      border: Border.all(
                          color: const Color(0xFF00E5FF).withOpacity(0.3),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withOpacity(0.2),
                          blurRadius: 20,
                        ),
                      ],
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
                        decoration: TextDecoration.none,
                      )),
                  const SizedBox(height: 4),
                  const Text('Versão 1.0.0',
                      style: TextStyle(
                        color: Color(0xFF546E7A),
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      )),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.03),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: const Text(
                      'Jogo de cobra com bots inteligentes, '
                      '10 skins exclusivas e partículas de '
                      'morte épicas.\n\nFeito com Flutter + Flame.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF78909C),
                        fontSize: 12,
                        height: 1.6,
                        decoration: TextDecoration.none,
                      ),
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
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00E5FF).withOpacity(0.15),
                            const Color(0xFF69F0AE).withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(
                            color: const Color(0xFF00E5FF).withOpacity(0.35),
                            width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: const Text('FECHAR',
                          style: TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                            decoration: TextDecoration.none,
                          )),
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

// ── Widgets internos ──────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00E5FF).withOpacity(0.08),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(color: const Color(0xFF00E5FF).withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E5FF).withOpacity(0.12),
              border:
                  Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
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
                decoration: TextDecoration.none,
              )),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Color(0xFF546E7A), size: 16),
            ),
          ),
        ],
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.1),
              border: Border.all(color: iconColor.withOpacity(0.25), width: 1),
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
                    decoration: TextDecoration.none,
                  )),
              Text(subtitle,
                  style: const TextStyle(
                    color: Color(0xFF546E7A),
                    fontSize: 11,
                    decoration: TextDecoration.none,
                  )),
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
  const _Switch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF00E5FF),
      activeTrackColor: const Color(0xFF00E5FF).withOpacity(0.25),
      inactiveThumbColor: const Color(0xFF546E7A),
      inactiveTrackColor: const Color(0xFF546E7A).withOpacity(0.15),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: Colors.white.withOpacity(0.05));
}
