// lib/game/weather/weather_mixin.dart
import 'dart:ui';
import 'weather_controller.dart';
import '../snake_engine.dart';

mixin WeatherMixin on SnakeEngine {
  WeatherController? _weatherController;
  
  WeatherController get weatherController {
    _weatherController ??= WeatherController(this);
    return _weatherController!;
  }
  
  void updateWeather(double dt) {
    weatherController.update(dt);
  }
  
  void renderWeather(Canvas canvas) {
    weatherController.render(canvas);
  }
}
