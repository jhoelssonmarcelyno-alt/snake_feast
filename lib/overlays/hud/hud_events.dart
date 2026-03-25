import 'package:flutter/material.dart';

class HudEventController {
  final event = ValueNotifier<String?>(null);

  void show(String text) {
    event.value = text;

    Future.delayed(const Duration(seconds: 2), () {
      event.value = null;
    });
  }

  void dispose() {
    event.dispose();
  }
}
