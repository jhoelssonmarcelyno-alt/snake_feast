import 'dart:math';
import 'package:flutter/material.dart';
import '../../../utils/dev_mode.dart';

class MenuTitle extends StatefulWidget {
  final double titleFade;
  final double subtitleFade;
  final double titleSlide;

  const MenuTitle({
    super.key,
    required this.titleFade,
    required this.subtitleFade,
    required this.titleSlide,
  });

  @override
  State<MenuTitle> createState() => _MenuTitleState();
}

class _MenuTitleState extends State<MenuTitle> with SingleTickerProviderStateMixin {
  late AnimationController _colorController;
  late Animation<double> _colorAnimation;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _colorController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _colorAnimation = Tween<double>(begin: 0, end: 1).animate(_colorController);
    _pulseAnimation = Tween<double>(begin: 1, end: 1.05).animate(
      CurvedAnimation(
        parent: _colorController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() => setState(() {}));
  }
  
  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.titleFade,
      child: Transform.translate(
        offset: Offset(0, widget.titleSlide),
        child: Column(
          children: [
            GestureDetector(
              onLongPress: () async {
                print('🔧 Modo desenvolvedor ativado!');
                await DevMode.unlockAllSkins();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔓 MODO DESENVOLVEDOR ATIVADO! Todas as skins desbloqueadas!'),
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: AnimatedBuilder(
                animation: _colorAnimation,
                builder: (context, child) {
                  // Cores gradiente que mudam
                  final colors = [
                    Color.lerp(Colors.green.shade400, Colors.cyan.shade400, _colorAnimation.value),
                    Color.lerp(Colors.lime.shade400, Colors.teal.shade400, _colorAnimation.value),
                    Color.lerp(Colors.orange.shade400, Colors.purple.shade400, _colorAnimation.value),
                  ];
                  
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              colors[0]!,
                              colors[1]!,
                              colors[2]!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'SNAKE',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 6,
                              fontFamily: 'Poppins',
                              shadows: [
                                Shadow(
                                  blurRadius: 20,
                                  color: Colors.white.withOpacity(0.9),
                                  offset: Offset(0, 0),
                                ),
                                Shadow(
                                  blurRadius: 15,
                                  color: Colors.white.withOpacity(0.6),
                                  offset: Offset(2, 2),
                                ),
                                Shadow(
                                  blurRadius: 25,
                                  color: Colors.amber.withOpacity(0.4),
                                  offset: Offset(-2, -2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              colors[2]!,
                              colors[1]!,
                              colors[0]!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'FEAST',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 6,
                              fontFamily: 'Poppins',
                              shadows: [
                                Shadow(
                                  blurRadius: 20,
                                  color: Colors.white.withOpacity(0.9),
                                  offset: Offset(0, 0),
                                ),
                                Shadow(
                                  blurRadius: 15,
                                  color: Colors.white.withOpacity(0.6),
                                  offset: Offset(2, 2),
                                ),
                                Shadow(
                                  blurRadius: 25,
                                  color: Colors.orange.withOpacity(0.4),
                                  offset: Offset(-2, -2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: widget.subtitleFade,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white24, Colors.white12],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🐍', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      'SNAKE ARENA',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 2,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.white.withOpacity(0.5),
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('🐍', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
