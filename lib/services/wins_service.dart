import 'package:shared_preferences/shared_preferences.dart';

class WinsService {
  static final WinsService _instance = WinsService._internal();
  factory WinsService() => _instance;
  WinsService._internal();
  
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  int _totalWins = 0;
  
  Future<void> init() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    _totalWins = _prefs.getInt('total_wins') ?? 0;
    _isInitialized = true;
  }
  
  Future<void> addWin() async {
    _totalWins++;
    await _prefs.setInt('total_wins', _totalWins);
  }
  
  int get totalWins => _totalWins;
  
  Future<void> reset() async {
    _totalWins = 0;
    await _prefs.setInt('total_wins', 0);
  }
}
