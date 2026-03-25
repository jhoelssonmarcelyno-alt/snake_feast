import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class HudEventBanner extends StatelessWidget {
  final ValueListenable<String?> event;

  const HudEventBanner({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: event,
      builder: (_, value, __) {
        if (value == null) return const SizedBox();

        return Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 250),
            builder: (_, scale, __) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
