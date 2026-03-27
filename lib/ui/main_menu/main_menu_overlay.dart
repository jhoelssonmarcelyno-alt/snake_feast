import 'dart:math';
import 'package:flutter/material.dart';

import '../../../game/snake_engine.dart';
import '../../../services/score_service.dart';
import '../../../services/level_service.dart';
import '../../../services/audio_service.dart';
import '../../../utils/constants.dart';

import 'controllers/menu_animation_controller.dart';
import 'models/particle.dart';
import 'painters/particle_painter.dart';
import 'painters/grass_painter.dart';
import 'widgets/menu_title.dart';
import 'widgets/name_field.dart';
import 'widgets/skin_selector.dart';
import 'widgets/play_row.dart';
import 'widgets/glow_icon_button.dart';
import 'widgets/wallet_badge.dart';

import '../../../overlays/rank_overlay.dart';

// ── 25 Mundos ────────────────────────────────────────────────────────────────
class _World {
  final int number;
  final String name;
  final String emoji;
  final Color primary;
  final Color secondary;
  final double botDifficulty;

  const _World({
    required this.number,
    required this.name,
    required this.emoji,
    required this.primary,
    required this.secondary,
    required this.botDifficulty,
  });
}

const List<_World> kWorlds = [
  _World(
      number: 1,
      name: 'Floresta',
      emoji: '🌳',
      primary: Color(0xFF2D5A2D),
      secondary: Color(0xFF4CAF50),
      botDifficulty: 0.04),
  _World(
      number: 2,
      name: 'Oceano',
      emoji: '🌊',
      primary: Color(0xFF1A3A5C),
      secondary: Color(0xFF29CFFF),
      botDifficulty: 0.08),
  _World(
      number: 3,
      name: 'Deserto',
      emoji: '🏜️',
      primary: Color(0xFF5C3A1A),
      secondary: Color(0xFFFF9500),
      botDifficulty: 0.12),
  _World(
      number: 4,
      name: 'Vulcão',
      emoji: '🌋',
      primary: Color(0xFF5C1A1A),
      secondary: Color(0xFFFF3D00),
      botDifficulty: 0.16),
  _World(
      number: 5,
      name: 'Gelo',
      emoji: '❄️',
      primary: Color(0xFF1A3A5C),
      secondary: Color(0xFF80DEEA),
      botDifficulty: 0.20),
  _World(
      number: 6,
      name: 'Caverna',
      emoji: '🦇',
      primary: Color(0xFF1A1A2E),
      secondary: Color(0xFF7B1FA2),
      botDifficulty: 0.24),
  _World(
      number: 7,
      name: 'Pântano',
      emoji: '🐸',
      primary: Color(0xFF1B3A1B),
      secondary: Color(0xFF8BC34A),
      botDifficulty: 0.28),
  _World(
      number: 8,
      name: 'Savana',
      emoji: '🦁',
      primary: Color(0xFF4A3000),
      secondary: Color(0xFFFFB300),
      botDifficulty: 0.32),
  _World(
      number: 9,
      name: 'Tundra',
      emoji: '🐺',
      primary: Color(0xFF263238),
      secondary: Color(0xFFB0BEC5),
      botDifficulty: 0.36),
  _World(
      number: 10,
      name: 'Ilha',
      emoji: '🏝️',
      primary: Color(0xFF006064),
      secondary: Color(0xFF00E5FF),
      botDifficulty: 0.40),
  _World(
      number: 11,
      name: 'Montanha',
      emoji: '⛰️',
      primary: Color(0xFF37474F),
      secondary: Color(0xFF90A4AE),
      botDifficulty: 0.44),
  _World(
      number: 12,
      name: 'Selva',
      emoji: '🌿',
      primary: Color(0xFF1B5E20),
      secondary: Color(0xFF69F0AE),
      botDifficulty: 0.48),
  _World(
      number: 13,
      name: 'Abismo',
      emoji: '🕳️',
      primary: Color(0xFF0D0D0D),
      secondary: Color(0xFF455A64),
      botDifficulty: 0.52),
  _World(
      number: 14,
      name: 'Neon',
      emoji: '⚡',
      primary: Color(0xFF1A0033),
      secondary: Color(0xFFE040FB),
      botDifficulty: 0.56),
  _World(
      number: 15,
      name: 'Cogumelos',
      emoji: '🍄',
      primary: Color(0xFF4A1942),
      secondary: Color(0xFFFF80AB),
      botDifficulty: 0.60),
  _World(
      number: 16,
      name: 'Ruínas',
      emoji: '🏛️',
      primary: Color(0xFF3E2723),
      secondary: Color(0xFFBCAAA4),
      botDifficulty: 0.64),
  _World(
      number: 17,
      name: 'Submundo',
      emoji: '👹',
      primary: Color(0xFF4A0000),
      secondary: Color(0xFFFF1744),
      botDifficulty: 0.68),
  _World(
      number: 18,
      name: 'Cristal',
      emoji: '💎',
      primary: Color(0xFF00838F),
      secondary: Color(0xFF84FFFF),
      botDifficulty: 0.72),
  _World(
      number: 19,
      name: 'Aurora',
      emoji: '🌌',
      primary: Color(0xFF1A0044),
      secondary: Color(0xFF7C4DFF),
      botDifficulty: 0.76),
  _World(
      number: 20,
      name: 'Robótico',
      emoji: '🤖',
      primary: Color(0xFF1C1C1C),
      secondary: Color(0xFF00E676),
      botDifficulty: 0.80),
  _World(
      number: 21,
      name: 'Submarino',
      emoji: '🐙',
      primary: Color(0xFF01579B),
      secondary: Color(0xFF40C4FF),
      botDifficulty: 0.84),
  _World(
      number: 22,
      name: 'Fantasma',
      emoji: '👻',
      primary: Color(0xFF212121),
      secondary: Color(0xFFEEEEEE),
      botDifficulty: 0.88),
  _World(
      number: 23,
      name: 'Dragão',
      emoji: '🐉',
      primary: Color(0xFF4A0000),
      secondary: Color(0xFFFFD600),
      botDifficulty: 0.92),
  _World(
      number: 24,
      name: 'Cósmico',
      emoji: '🪐',
      primary: Color(0xFF0D0030),
      secondary: Color(0xFFAA00FF),
      botDifficulty: 0.96),
  _World(
      number: 25,
      name: 'Infinito',
      emoji: '♾️',
      primary: Color(0xFF000000),
      secondary: Color(0xFFFFFFFF),
      botDifficulty: 1.00),
];

// ─────────────────────────────────────────────────────────────────────────────

class MainMenuOverlay extends StatefulWidget {
  final SnakeEngine engine;
  const MainMenuOverlay({super.key, required this.engine});

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay>
    with TickerProviderStateMixin {
  final anim = MenuAnimationController();

  late List<Particle> particles;
  late TextEditingController nameController;

  int selectedSkin = 0;
  int selectedLevelIndex = 0;
  int selectedWorldIndex = 0;
  bool _isMuted = false;
  bool showRank = false;

  @override
  void initState() {
    super.initState();
    anim.init(this);

    selectedSkin = ScoreService.instance.selectedSkinIndex
        .clamp(0, kPlayerSkins.length - 1);

    final levels = LevelService.instance.allLevels;
    selectedLevelIndex = (ScoreService.instance.currentLevel - 1).clamp(
      0,
      levels.isEmpty ? 0 : levels.length - 1,
    );

    nameController = TextEditingController(
      text: ScoreService.instance.playerName,
    );

    _isMuted = AudioService.instance.isMuted;
    particles = List.generate(15, (_) => Particle(Random()));
  }

  @override
  void dispose() {
    anim.dispose();
    nameController.dispose();
    super.dispose();
  }

  void onPlay() {
    widget.engine.setSkin(selectedSkin);

    final levels = LevelService.instance.allLevels;
    if (levels.isNotEmpty) {
      widget.engine.currentLevelConfig = levels[selectedLevelIndex];
    }

    widget.engine.selectedWorld = selectedWorldIndex;
    widget.engine.restartGame();
  }

  void _toggleMute() {
    AudioService.instance.toggleMute();
    setState(() => _isMuted = AudioService.instance.isMuted);
  }

  void _prevLevel() {
    final levels = LevelService.instance.allLevels;
    if (levels.isEmpty) return;
    setState(() {
      int prev = selectedLevelIndex - 1;
      while (prev >= 0 && !LevelService.instance.isUnlocked(prev + 1)) {
        prev--;
      }
      if (prev >= 0) selectedLevelIndex = prev;
    });
  }

  void _nextLevel() {
    final levels = LevelService.instance.allLevels;
    if (levels.isEmpty) return;
    setState(() {
      int next = selectedLevelIndex + 1;
      if (next < levels.length && LevelService.instance.isUnlocked(next + 1)) {
        selectedLevelIndex = next;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = (size.height / 440.0).clamp(0.6, 1.0);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          _buildBackground(),
          _buildContent(scale),
          _buildWorldSelector(scale),
          _buildTopBar(scale),
          if (showRank)
            RankOverlay(onClose: () => setState(() => showRank = false)),
        ],
      ),
    );
  }

  // ── Background ───────────────────────────────────────────────
  Widget _buildBackground() {
    final world = kWorlds[selectedWorldIndex];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            world.primary,
            Color.lerp(world.primary, world.secondary, 0.3)!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: GrassPainter()),
          AnimatedBuilder(
            animation: anim.particleCtrl,
            builder: (_, __) => CustomPaint(
              painter: ParticlePainter(particles, anim.particleCtrl.value),
            ),
          ),
        ],
      ),
    );
  }

  // ── Conteúdo central ─────────────────────────────────────────
  Widget _buildContent(double scale) {
    return Positioned.fill(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 8 * scale),

              // 1. TÍTULO
              MenuTitle(
                scale: scale,
                titleFade: anim.titleFade,
                subtitleFade: anim.titleFade,
                titleSlide: anim.titleSlide,
              ),

              SizedBox(height: 10 * scale),

              // 2. SELETOR DE NÍVEL
              _buildLevelSelector(scale),

              SizedBox(height: 10 * scale),

              // 3. CAMPO DE NOME
              NameField(
                controller: nameController,
                fadeAnim: anim.cardFade,
                scale: scale,
                onChanged: ScoreService.instance.savePlayerName,
              ),

              SizedBox(height: 14 * scale),

              // 4. SELETOR DE COBRA
              SkinSelector(
                selectedSkin: selectedSkin,
                snakeCtrl: anim.snakeCtrl,
                cardFade: anim.cardFade,
                cardSlide: anim.cardSlide,
                scale: scale,
                onPrev: () => setState(() => selectedSkin =
                    (selectedSkin - 1 + kPlayerSkins.length) %
                        kPlayerSkins.length),
                onNext: () => setState(() =>
                    selectedSkin = (selectedSkin + 1) % kPlayerSkins.length),
                onSelect: (i) => setState(() => selectedSkin = i),
              ),

              SizedBox(height: 18 * scale),

              // 5. BOTÃO JOGAR
              PlayRow(
                borderCtrl: anim.borderCtrl,
                glowCtrl: anim.glowCtrl,
                btnFade: anim.btnFade,
                scale: scale,
                highScore: ScoreService.instance.highScore,
                onPlay: onPlay,
                onMulti: () {},
              ),

              SizedBox(height: 180 * scale),
            ],
          ),
        ),
      ),
    );
  }

  // ── Seletor de nível ─────────────────────────────────────────
  Widget _buildLevelSelector(double scale) {
    final levels = LevelService.instance.allLevels;
    if (levels.isEmpty) return const SizedBox.shrink();

    final level = levels[selectedLevelIndex];
    final unlocked = LevelService.instance.unlockedUpTo;
    final canPrev = selectedLevelIndex > 0;
    final canNext = selectedLevelIndex < levels.length - 1 &&
        LevelService.instance.isUnlocked(selectedLevelIndex + 2);

    return FadeTransition(
      opacity: anim.cardFade,
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 8 * scale),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(16 * scale),
          border:
              Border.all(color: level.themeColor.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(color: level.themeColor.withOpacity(0.2), blurRadius: 12)
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _levelArrow(
                icon: Icons.chevron_left_rounded,
                enabled: canPrev,
                onTap: _prevLevel,
                scale: scale),
            SizedBox(width: 8 * scale),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(level.rankIcon,
                        color: level.themeColor, size: 16 * scale),
                    SizedBox(width: 6 * scale),
                    Text('FASE ${level.number}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            decoration: TextDecoration.none)),
                  ],
                ),
                SizedBox(height: 2 * scale),
                Text(level.rankName.toUpperCase(),
                    style: TextStyle(
                        color: level.themeColor,
                        fontSize: 9 * scale,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        decoration: TextDecoration.none)),
                SizedBox(height: 2 * scale),
                Text(
                    'Meta: ${level.targetScore} pts  •  Desbloqueado: $unlocked/250',
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 7 * scale,
                        decoration: TextDecoration.none)),
              ],
            ),
            SizedBox(width: 8 * scale),
            _levelArrow(
                icon: Icons.chevron_right_rounded,
                enabled: canNext,
                onTap: _nextLevel,
                scale: scale),
          ],
        ),
      ),
    );
  }

  Widget _levelArrow({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required double scale,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: EdgeInsets.all(4 * scale),
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
          child: Icon(icon, color: Colors.white, size: 20 * scale),
        ),
      ),
    );
  }

  // ── Seletor de mundos — canto inferior esquerdo (scroll vertical) ──
  Widget _buildWorldSelector(double scale) {
    final world = kWorlds[selectedWorldIndex];
    final double itemSize = 34 * scale;
    final double spacing = 5 * scale;
    // Mostra 5 itens por vez
    final double listHeight = (itemSize + spacing) * 5 - spacing;

    return Positioned(
      left: 12 * scale,
      bottom: 12 * scale,
      child: FadeTransition(
        opacity: anim.btnFade,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Info do mundo atual
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale, vertical: 6 * scale),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                    color: world.secondary.withOpacity(0.5), width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(world.emoji, style: TextStyle(fontSize: 18 * scale)),
                  SizedBox(width: 6 * scale),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'MUNDO ${world.number}',
                        style: TextStyle(
                          color: world.secondary,
                          fontSize: 9 * scale,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        world.name.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 6 * scale),

            // Lista vertical com scroll livre (cima ↕ baixo)
            SizedBox(
              width: itemSize,
              height: listHeight,
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView.builder(
                  itemCount: kWorlds.length,
                  itemExtent: itemSize + spacing,
                  itemBuilder: (_, i) {
                    final w = kWorlds[i];
                    final selected = i == selectedWorldIndex;
                    return Padding(
                      padding: EdgeInsets.only(bottom: spacing),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedWorldIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: itemSize,
                          height: itemSize,
                          decoration: BoxDecoration(
                            color: selected
                                ? w.secondary.withOpacity(0.9)
                                : w.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8 * scale),
                            border: Border.all(
                              color: selected ? w.secondary : Colors.white12,
                              width: selected ? 2 : 1,
                            ),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                        color: w.secondary.withOpacity(0.5),
                                        blurRadius: 6)
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              w.emoji,
                              style: TextStyle(fontSize: 14 * scale),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────
  Widget _buildTopBar(double scale) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  WalletBadge(
                    coins: ScoreService.instance.coins,
                    diamonds: ScoreService.instance.diamonds,
                    fadeAnim: anim.btnFade,
                  ),
                  const SizedBox(width: 8),
                  _circleBtn(
                    icon: _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: _isMuted ? Colors.redAccent : Colors.white,
                    onTap: _toggleMute,
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GlowIconButton(
                    onTap: () => widget.engine.overlays.add(kOverlayShop),
                    color: const Color(0xFFFFD600),
                    icon: Icons.store,
                  ),
                  const SizedBox(width: 8),
                  GlowIconButton(
                    onTap: () => setState(() => showRank = true),
                    color: const Color(0xFFFF6B35),
                    icon: Icons.emoji_events,
                  ),
                  const SizedBox(width: 8),
                  GlowIconButton(
                    onTap: () => widget.engine.overlays.add(kOverlaySettings),
                    color: const Color(0xFF29CFFF),
                    icon: Icons.settings,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return FadeTransition(
      opacity: anim.btnFade,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }
}
