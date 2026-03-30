import '../../../game/skins/skin_manager.dart';
import '../../../utils/dev_mode.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../game/snake_engine.dart';
import '../../services/score_service.dart';
import '../../services/level_service.dart';
import '../../services/audio_service.dart';
import '../../services/world_progress_service.dart';
import '../../services/skin_progress_service.dart';
import '../../services/wins_service.dart';
import '../../utils/constants.dart';

import 'controllers/menu_animation_controller.dart';
import 'models/particle.dart';
import 'models/world_model.dart';
import 'painters/particle_painter.dart';
import 'painters/grass_painter.dart';

import 'widgets/menu_title.dart';
import 'widgets/play_row.dart';
import 'widgets/top_bar_widget.dart';
import 'widgets/world_vertical_carousel.dart';
import 'widgets/world_grid_selector.dart';
import 'widgets/skin_horizontal_carousel.dart';
import 'widgets/skin_grid_modal.dart';

import '../../overlays/ranking_overlay.dart';

class MainMenuOverlay extends StatefulWidget {
  final SnakeEngine engine;
  const MainMenuOverlay({super.key, required this.engine});

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay>
    with TickerProviderStateMixin {
  final _anim = MenuAnimationController();
  late List<Particle> _particles;
  late TextEditingController _nameCtrl;

  int _selectedSkin = 0;
  int _selectedWorldIndex = 0;
  bool _isMuted = false;
  bool _showRank = false;

  @override
  void initState() {
    super.initState();
    _anim.init(this);

    _selectedSkin = ScoreService.instance.selectedSkinIndex
        .clamp(0, kPlayerSkins.length - 1);

    _nameCtrl = TextEditingController(
      text: ScoreService.instance.playerName,
    );

    _isMuted = AudioService.instance.isMuted;
    _particles = List.generate(15, (_) => Particle(Random()));
    
    // Inicializa os serviços
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await WorldProgressService().init(devMode: DEV_MODE);
      await SkinProgressService().init(devMode: DEV_MODE);
      await WinsService().init();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _onPlay() {
    widget.engine.setSkin(_selectedSkin);
    widget.engine.selectedWorld = _selectedWorldIndex;
    widget.engine.restartGame();
  }

  void _toggleMute() {
    AudioService.instance.toggleMute();
    setState(() => _isMuted = AudioService.instance.isMuted);
  }

  void _openWorldPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => WorldGridSelector(
        selectedIndex: _selectedWorldIndex,
        onSelect: (i) {
          setState(() => _selectedWorldIndex = i);
          Navigator.pop(context);
        },
        scale: _scale,
      ),
    );
  }

  void _openSkinPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SkinGridModal(
        selectedSkin: _selectedSkin,
        onSelect: (i) {
          setState(() => _selectedSkin = i);
          Navigator.pop(context);
        },
        scale: _scale,
      ),
    );
  }

  double get _scale {
    final size = MediaQuery.of(context).size;
    return (size.height / 440.0).clamp(0.6, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _scale;
    final world = kWorlds[_selectedWorldIndex];

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Fundo
          _MenuBackground(
            worldIndex: _selectedWorldIndex,
            particles: _particles,
            anim: _anim,
          ),

          // Conteúdo principal
          SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lado esquerdo - Seletor de mundos vertical
                Container(
                  width: 100 * scale,
                  margin: EdgeInsets.only(left: 8 * scale, top: 60 * scale),
                  child: Column(
                    children: [
                      Text(
                        'MUNDOS',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10 * scale,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      WorldVerticalCarousel(
                        worlds: kWorlds,
                        selectedIndex: _selectedWorldIndex,
                        onSelect: (i) => setState(() => _selectedWorldIndex = i),
                        scale: scale,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _openWorldPicker,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8 * scale,
                            vertical: 4 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(16 * scale),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.grid_view,
                                size: 12 * scale,
                                color: Colors.white54,
                              ),
                              SizedBox(width: 4 * scale),
                              Text(
                                'VER TODOS',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 8 * scale,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Lado direito - Conteúdo principal
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Topo - MenuTopBar
                        MenuTopBar(
                          engine: widget.engine,
                          isMuted: _isMuted,
                          coins: ScoreService.instance.coins,
                          diamonds: ScoreService.instance.diamonds,
                          onToggleMute: _toggleMute,
                          onShowRank: () => setState(() => _showRank = true),
                          fadeAnim: _anim.btnFade,
                          nameCtrl: _nameCtrl,
                        ),
                        
                        const SizedBox(height: 5),
                        
                        // Título
          MenuTitle(
            titleFade: _anim.titleFade.value,
            subtitleFade: _anim.titleFade.value,
            titleSlide: _anim.titleSlide.value.dy,
          ),
                        
                        const SizedBox(height: 5),
                        
                        // Carrossel de Skins HORIZONTAL
                        SkinHorizontalCarousel(
                          selectedSkin: _selectedSkin,
                          onSelect: (i) => setState(() => _selectedSkin = i),
                          scale: scale,
                          snakeCtrl: _anim.snakeCtrl,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Botão "VER TODAS AS SKINS"
                        GestureDetector(
                          onTap: _openSkinPicker,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12 * scale,
                              vertical: 6 * scale,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(20 * scale),
                              border: Border.all(
                                color: Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.grid_view,
                                  size: 14 * scale,
                                  color: Colors.white70,
                                ),
                                SizedBox(width: 6 * scale),
                                Text(
                                  'VER TODAS AS SKINS',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10 * scale,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 5),
                        
                        // Botão Jogar
                        PlayRow(
                          borderCtrl: _anim.borderCtrl,
                          glowCtrl: _anim.glowCtrl,
                          btnFade: _anim.btnFade,
                          scale: scale,
                          highScore: ScoreService.instance.highScore,
                          onPlay: _onPlay,
                          onMulti: () {},
                        ),
                        
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Overlay de rank
          if (_showRank)
            RankingOverlay(
              engine: widget.engine,
              onClose: () => setState(() => _showRank = false),
            ),
        ],
      ),
    );
  }
}

class _MenuBackground extends StatelessWidget {
  final int worldIndex;
  final List<Particle> particles;
  final MenuAnimationController anim;

  const _MenuBackground({
    required this.worldIndex,
    required this.particles,
    required this.anim,
  });

  @override
  Widget build(BuildContext context) {
    final world = kWorlds[worldIndex];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            world.primary,
            Color.lerp(world.primary, world.secondary, 0.28)!,
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
}

// ========== MODO DESENVOLVEDOR ==========
// Toque e segure no título por 3 segundos para desbloquear todas as skins

class DeveloperMode {
  static bool _isEnabled = false;
  static Timer? _timer;
  static int _tapCount = 0;
  
  static void init(BuildContext context) {
    // Verificar se já está desbloqueado
    _isEnabled = false;
  }
  
  static void registerTitleLongPress(BuildContext context, VoidCallback onUnlock) {
    // Adicionar ao título do jogo
  }
  
  static void unlockAllSkins() async {
    final skinManager = SkinManager();
    await skinManager.init();
    
    // Desbloquear todas as skins (1 a 249, pois 0 já está desbloqueada)
    for (int i = 1; i < kPlayerSkins.length; i++) {
      if (!skinManager.isSkinUnlocked(i)) {
        await skinManager.unlockSkin(i);
      }
    }
    
    _isEnabled = true;
    print('🎮 MODO DESENVOLVEDOR ATIVADO! Todas as skins desbloqueadas!');
  }
  
  static bool isEnabled() => _isEnabled;
}
