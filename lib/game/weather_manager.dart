// lib/game/weather_manager.dart
import 'dart:ui';
import 'weather/weather_controller.dart';
import 'snake_engine.dart';

class WeatherManager {
  static WeatherController? _controller;
  
  static void init(SnakeEngine engine) {
    _controller = WeatherController(engine);
  }
  
  static void update(double dt) {
    _controller?.update(dt);
  }
  
  static void render(Canvas canvas) {
    _controller?.render(canvas);
  }
  
  static void reset() {
    _controller?.reset();
  }
  
  static bool get isActive => _controller != null;
}
