// lib/ui/main_menu/main_menu.dart
import 'package:flutter/material.dart';
import '../../game/snake_engine.dart';
import '../../services/score_service.dart';
import '../../services/rank_system.dart';
import '../../utils/constants.dart';
import 'models/particle.dart';
import 'painters/particle_painter.dart';
import 'painters/grass_painter.dart';
import 'widgets/menu_title.dart';
import 'widgets/name_field.dart';
import 'widgets/skin_selector.dart';
import 'widgets/play_row.dart';
import 'widgets/tips_column.dart';
import 'widgets/glow_icon_button.dart';
import 'widgets/wallet_badge.dart';
import '../../overlays/lobby_overlay.dart';
import '../../overlays/rank_overlay.dart';
import 'dart:math';

class MainMenuOverlay extends StatefulWidget {
  final SnakeEngine engine;
  const MainMenuOverlay({super.key, required this.engine});

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay>
    with TickerProviderStateMixin {
  // ── Animações ─────────────────────────────────────────────
  late final AnimationController _entryCtrl,
      _snakeCtrl,
      _particleCtrl,
      _borderCtrl,
      _glowCtrl;
  late final Animation<double> _titleFade, _subtitleFade, _cardFade, _btnFade;
  late final Animation<Offset> _titleSlide, _cardSlide;
  late final List<Particle> _particles;

  // ── Estado ────────────────────────────────────────────────
  int _selectedSkin = 0;
  bool _isOnline = false;
  bool _showRank = false;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _selectedSkin = widget.engine.skinIndex;
    _nameController =
        TextEditingController(text: ScoreService.instance.playerName);

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _titleFade = CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut));
    _subtitleFade = CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.2, 0.55, curve: Curves.easeOut));
    _cardFade = CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut));
    _btnFade = CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut));
    _titleSlide = Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic)));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic)));

    _snakeCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _particleCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();
    _borderCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);

    _particles = List.generate(20, (_) => Particle(Random()));
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _snakeCtrl.dispose();
    _particleCtrl.dispose();
    _borderCtrl.dispose();
    _glowCtrl.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ── Ações ─────────────────────────────────────────────────
  void _selectSkin(int i) {
    setState(() => _selectedSkin = i);
    widget.engine.setSkin(i);
  }

  void _prevSkin() => _selectSkin(
      (_selectedSkin - 1 + kPlayerSkins.length) % kPlayerSkins.length);
  void _nextSkin() => _selectSkin((_selectedSkin + 1) % kPlayerSkins.length);
  void _onPlay() => widget.engine.player.isAlive
      ? widget.engine.startGame()
      : widget.engine.restartGame();
  void _onMulti() {
    setState(() => _isOnline = !_isOnline);
    if (_isOnline) widget.engine.overlays.add(kOverlayLobby);
  }

  void _onShop() => widget.engine.overlays.add(kOverlayShop);
  void _onSettings() => widget.engine.overlays.add(kOverlaySettings);
  void _onName(String v) {
    ScoreService.instance.savePlayerName(v);
    widget.engine.player.name = v.trim().isEmpty ? 'Você' : v.trim();
  }

  void _onRank() => setState(() => _showRank = true);
  void _closeRank() => setState(() => _showRank = false);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final safeH = size.height - mq.padding.top - mq.padding.bottom;
    final scale = (safeH / 440.0).clamp(0.50, 1.0);
    final hs = ScoreService.instance.highScore;
    final coins = ScoreService.instance.coins;
    final diamonds = ScoreService.instance.diamonds;
    final rank = ScoreService.instance.currentRank;

    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: const TextStyle(
            decoration: TextDecoration.none, decorationThickness: 0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Fundo gradiente ──────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2ECC40), Color(0xFF27AE35)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // ── Grama ────────────────────────────────────────
            CustomPaint(size: size, painter: GrassPainter()),

            // ── Partículas ───────────────────────────────────
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: ParticlePainter(_particles, _particleCtrl.value),
              ),
            ),

            // ── Conteúdo scrollável ──────────────────────────
            Positioned.fill(
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(top: 8, bottom: 100 * scale),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MenuTitle(
                        scale: scale,
                        titleFade: _titleFade,
                        subtitleFade: _subtitleFade,
                        titleSlide: _titleSlide,
                      ),
                      SizedBox(height: 12 * scale),
                      NameField(
                        controller: _nameController,
                        fadeAnim: _cardFade,
                        scale: scale,
                        onChanged: _onName,
                      ),
                      SizedBox(height: 12 * scale),
                      SkinSelector(
                        selectedSkin: _selectedSkin,
                        snakeCtrl: _snakeCtrl,
                        cardFade: _cardFade,
                        cardSlide: _cardSlide,
                        scale: scale,
                        onPrev: _prevSkin,
                        onNext: _nextSkin,
                        onSelect: _selectSkin,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Botão JOGAR fixo embaixo ─────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Center(
                child: PlayRow(
                  borderCtrl: _borderCtrl,
                  glowCtrl: _glowCtrl,
                  btnFade: _btnFade,
                  scale: scale,
                  highScore: hs,
                  onPlay: _onPlay,
                  onMulti: _onMulti,
                ),
              ),
            ),

            // ── Dicas canto esquerdo ─────────────────────────
            Positioned(
              left: 12,
              bottom: 20,
              child: TipsColumn(fadeAnim: _btnFade),
            ),

            // ── Botão Online/Offline ─────────────────────────
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 12),
                  child: FadeTransition(
                    opacity: _btnFade,
                    child: GestureDetector(
                      onTap: _onMulti,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: _isOnline
                              ? const Color(0xFF29CFFF).withOpacity(0.25)
                              : Colors.black.withOpacity(0.25),
                          border: Border.all(
                            color: _isOnline
                                ? const Color(0xFF29CFFF)
                                : Colors.white.withOpacity(0.35),
                            width: 1.5,
                          ),
                          boxShadow: _isOnline
                              ? [
                                  BoxShadow(
                                      color: const Color(0xFF29CFFF)
                                          .withOpacity(0.3),
                                      blurRadius: 10)
                                ]
                              : [],
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                            _isOnline
                                ? Icons.wifi_rounded
                                : Icons.wifi_off_rounded,
                            color: _isOnline
                                ? const Color(0xFF29CFFF)
                                : Colors.white.withOpacity(0.55),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isOnline ? 'ONLINE' : 'OFFLINE',
                            style: TextStyle(
                              color: _isOnline
                                  ? const Color(0xFF29CFFF)
                                  : Colors.white.withOpacity(0.55),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Saldo ────────────────────────────────────────
            WalletBadge(coins: coins, diamonds: diamonds, fadeAnim: _btnFade),

            // ── Botões topo direito ──────────────────────────
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 12),
                  child: FadeTransition(
                    opacity: _btnFade,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      GlowIconButton(
                          onTap: _onShop,
                          color: const Color(0xFFFFD600),
                          icon: Icons.store_rounded),
                      const SizedBox(width: 8),
                      GlowIconButton(
                          onTap: _onSettings,
                          color: const Color(0xFF29CFFF),
                          icon: Icons.settings_rounded),
                    ]),
                  ),
                ),
              ),
            ),

            // ── Badge de patente (canto inferior direito) ────
            Positioned(
              bottom: 20,
              right: 12,
              child: FadeTransition(
                opacity: _btnFade,
                child: GestureDetector(
                  onTap: _onRank,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: rank.colorDark.withOpacity(0.7),
                      border: Border.all(
                          color: rank.color.withOpacity(0.7), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                            color: rank.color.withOpacity(0.3), blurRadius: 8)
                      ],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(rank.icon, color: rank.color, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        rank.name.toUpperCase(),
                        style: TextStyle(
                          color: rank.color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),

            // ── Tabela de patentes (modal) ───────────────────
            if (_showRank) RankOverlay(onClose: _closeRank),
          ],
        ),
      ),
    );
  }
}
