import 'package:flutter/material.dart';

class HudJoystick extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final Offset? origin;
  final Offset? thumb;
  final void Function(PointerDownEvent) onDown;
  final void Function(PointerMoveEvent) onMove;
  final void Function(PointerUpEvent) onUp;
  final void Function(PointerCancelEvent) onCancel;

  static const double baseRadius = 55.0;
  static const double thumbRadius = 24.0;

  const HudJoystick({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.origin,
    required this.thumb,
    required this.onDown,
    required this.onMove,
    required this.onUp,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      width: screenWidth * 0.5,
      height: screenHeight,
      child: RepaintBoundary(
        // ✅ Otimiza o redesenho constante do joystick
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: onDown,
          onPointerMove: onMove,
          onPointerUp: onUp,
          onPointerCancel: onCancel,
          child: ExcludeSemantics(
            // ✅ Melhora a performance de processamento de gestos
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Hint quando joystick está inativo
                if (origin == null)
                  Positioned(
                    left: screenWidth * 0.10,
                    bottom: screenHeight * 0.10,
                    child: _buildHint(),
                  ),

                // Base do joystick
                if (origin != null)
                  Positioned(
                    left: origin!.dx - baseRadius,
                    top: origin!.dy - baseRadius,
                    child: _buildBase(),
                  ),

                // Thumb do joystick (O que se move)
                if (thumb != null)
                  Positioned(
                    left: thumb!.dx - thumbRadius,
                    top: thumb!.dy - thumbRadius,
                    child: _buildThumb(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHint() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.04),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.gamepad_outlined,
            color: Colors.white.withValues(alpha: 0.12),
            size: 20,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Arraste aqui',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.09),
            fontSize: 9,
            letterSpacing: 1.5,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildBase() {
    return Container(
      width: baseRadius * 2,
      height: baseRadius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(
            alpha: 0.05), // ✅ Reduzi levemente para ficar mais sutil
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildThumb() {
    return Container(
      width: thumbRadius * 2,
      height: thumbRadius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF00E5FF).withValues(alpha: 0.30),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.70),
          width:
              2.5, // ✅ Borda levemente mais grossa para destacar no movimento
        ),
        boxShadow: [
          // ✅ Adicionado um leve brilho neon para o feedback visual
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
    );
  }
}
