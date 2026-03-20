import 'package:vibration/vibration.dart';

class HapticService {
  HapticService._();
  static final HapticService instance = HapticService._();

  bool enabled = true;
  bool? _hasVibrator;

  Future<void> _init() async {
    _hasVibrator ??= await Vibration.hasVibrator() ?? false;
  }

  Future<void> _vibrate({int duration = 50, int amplitude = 128}) async {
    if (!enabled) return;
    await _init();
    if (_hasVibrator != true) return;
    Vibration.vibrate(duration: duration, amplitude: amplitude);
  }

  void eat()   => _vibrate(duration: 30,  amplitude: 80);
  void boost() => _vibrate(duration: 60,  amplitude: 150);
  void die()   => _vibrate(duration: 300, amplitude: 255);
  void kill() {
    if (!enabled) return;
    _vibrate(duration: 80, amplitude: 200);
    Future.delayed(const Duration(milliseconds: 100),
        () => _vibrate(duration: 40, amplitude: 120));
  }

  void light()  => _vibrate(duration: 30,  amplitude: 80);
  void medium() => _vibrate(duration: 60,  amplitude: 150);
  void heavy()  => _vibrate(duration: 200, amplitude: 255);
}
