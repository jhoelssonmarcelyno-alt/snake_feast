// lib/game/engine_input.dart
//
// Mixin responsável pelos callbacks de arrasto (Drag) do jogador.
// Separa toda a lógica de input do motor principal.
//
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'snake_engine.dart';

mixin InputMixin on FlameGame, DragCallbacks {
  SnakeEngine get _e => this as SnakeEngine;

  @override
  bool onDragStart(DragStartEvent event) {
    if (_e.player.isAlive) _e.player.onDragStart(event);
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    if (_e.player.isAlive) _e.player.onDragUpdate(event);
    return true;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    if (_e.player.isAlive) _e.player.onDragEnd(event);
    return true;
  }

  @override
  bool onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    if (_e.player.isAlive) _e.player.onDragCancel(event);
    return true;
  }
}
