import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _enabled = true;
  bool _hasVibrator = false;
  bool _isInitialized = false;

  static HapticService get instance => _instance;

  bool get enabled => _enabled;
  set enabled(bool value) {
    _enabled = value;
  }

  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      _hasVibrator = true;
    } catch (e) {
      _hasVibrator = false;
    }
    
    _isInitialized = true;
  }

  Future<void> light() async {
    if (!_enabled || !_hasVibrator) return;
    try {
      HapticFeedback.lightImpact();
    } catch (e) {}
  }

  Future<void> medium() async {
    if (!_enabled || !_hasVibrator) return;
    try {
      HapticFeedback.mediumImpact();
    } catch (e) {}
  }

  Future<void> heavy() async {
    if (!_enabled || !_hasVibrator) return;
    try {
      HapticFeedback.heavyImpact();
    } catch (e) {}
  }

  Future<void> selection() async {
    if (!_enabled || !_hasVibrator) return;
    try {
      HapticFeedback.selectionClick();
    } catch (e) {}
  }

  Future<void> eat() async {
    if (!_enabled || !_hasVibrator) return;
    try {
      HapticFeedback.lightImpact();
    } catch (e) {}
  }

  Future<void> boost() async {
    if (!_enabled || !_hasVibrator) return;
    try {
      HapticFeedback.mediumImpact();
    } catch (e) {}
  }

  Future<void> kill() async {
    if (!_enabled || !_hasVibrator) return;
    try {
      HapticFeedback.heavyImpact();
    } catch (e) {}
  }

  Future<void> die() async {
    if (!_enabled || !_hasVibrator) return;
    try {
      HapticFeedback.heavyImpact();
    } catch (e) {}
  }

  Future<void> vibrate({int duration = 50, int amplitude = 128}) async {
    if (!_enabled || !_hasVibrator) return;
    try {
      if (duration < 30) {
        HapticFeedback.lightImpact();
      } else if (duration < 80) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
    } catch (e) {}
  }

  Future<void> vibrateLight() async => light();
  Future<void> vibrateMedium() async => medium();
  Future<void> vibrateHeavy() async => heavy();
  Future<void> vibrateSuccess() async => medium();
  Future<void> vibrateError() async => heavy();
  Future<void> vibrateSelection() async => selection();

  bool get hasVibrator => _hasVibrator;
}
