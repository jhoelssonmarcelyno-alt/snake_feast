import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class HudSnakeCounter extends StatelessWidget {
  final ValueListenable<int> alive;
  final ValueListenable<int> total;

  const HudSnakeCounter({
    super.key,
    required this.alive,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: alive,
      builder: (_, aliveValue, __) {
        return ValueListenableBuilder<int>(
          valueListenable: total,
          builder: (_, totalValue, __) {
            final ratio = totalValue > 0 ? aliveValue / totalValue : 0.0;

            final Color barColor = ratio > 0.66
                ? const Color(0xFF69FF47)
                : ratio > 0.33
                    ? const Color(0xFFFFD600)
                    : const Color(0xFFFF5252);

            return _SnakeCounterUI(
              alive: aliveValue,
              total: totalValue,
              ratio: ratio,
              barColor: barColor,
            );
          },
        );
      },
    );
  }
}

class _SnakeCounterUI extends StatelessWidget {
  final int alive;
  final int total;
  final double ratio;
  final Color barColor;

  const _SnakeCounterUI({
    required this.alive,
    required this.total,
    required this.ratio,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      // 🔥 evita redraw desnecessário
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🐍', style: TextStyle(fontSize: 10)),
              const SizedBox(width: 4),

              const Text(
                'COBRAS',
                style: TextStyle(
                  color: Color(0xFF546E7A),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(width: 6),

              // 🔥 número animado
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: alive),
                duration: const Duration(milliseconds: 250),
                builder: (_, value, __) {
                  return Text(
                    '$value',
                    style: TextStyle(
                      color: barColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  );
                },
              ),

              Text(
                ' / $total',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.40),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          SizedBox(
            width: 110,
            height: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Stack(
                children: [
                  Container(color: Colors.white.withValues(alpha: 0.10)),

                  // 🔥 barra animada suave
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 300),
                    builder: (_, value, __) {
                      return FractionallySizedBox(
                        widthFactor: value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: barColor.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
