import 'dart:ui';
import 'package:flutter/material.dart' show Colors;

mixin BotPaints {
  final Paint botBodyPaint = Paint();
  final Paint botShadowPaint = Paint()..color = const Color(0x28000000);
  final Paint botHighlightPaint = Paint()..color = const Color(0x55FFFFFF);
  final Paint botEyeWhite = Paint()..color = Colors.white;
  final Paint botEyePupil = Paint()..color = Colors.black;
  final Paint botBoostGlowPaint = Paint()..color = const Color(0x40FFFFFF);
  final Paint botHeadPaint = Paint();
}
