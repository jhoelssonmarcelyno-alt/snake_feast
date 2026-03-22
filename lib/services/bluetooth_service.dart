// bluetooth_service.dart — stub (bluetooth desabilitado)
import 'dart:async';

enum PacketType { playerState, playerDied, foodRemove, foodSpawn, gameOver }

class GamePacket {
  final PacketType type;
  final String playerId;
  final Map<String, dynamic> data;
  GamePacket({required this.type, required this.playerId, this.data = const {}});
}

class BluetoothGameService {
  BluetoothGameService._();
  static final BluetoothGameService instance = BluetoothGameService._();
  String get localId => 'local';
  bool get isHost => false;
  Stream<GamePacket> get onPacket => const Stream.empty();
  void send(GamePacket packet) {}
}
