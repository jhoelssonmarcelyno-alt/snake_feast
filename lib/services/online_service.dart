// lib/services/online_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// ── Tipos de evento recebidos do servidor ─────────────────────
enum OnlineEventType {
  roomJoined,
  playerJoined,
  playerLeft,
  playerDied,
  stateUpdate,
  leaderboard,
  error,
  disconnected,
}

class OnlineEvent {
  final OnlineEventType type;
  final Map<String, dynamic> data;
  OnlineEvent(this.type, {this.data = const {}});
}

// ── Estado de um jogador remoto ───────────────────────────────
class RemotePlayer {
  final String id;
  final String username;
  String skinId;
  double x, y, dirX, dirY;
  int score, kills, length;
  bool alive;

  RemotePlayer({
    required this.id,
    required this.username,
    this.skinId = 'classic',
    this.x = 0, this.y = 0,
    this.dirX = 1, this.dirY = 0,
    this.score = 0, this.kills = 0,
    this.length = 3,
    this.alive = true,
  });

  factory RemotePlayer.fromJson(Map<String, dynamic> j) => RemotePlayer(
    id:       j['id']       as String,
    username: j['username'] as String? ?? 'Jogador',
    skinId:   j['skinId']   as String? ?? 'classic',
    x:        (j['x']       as num?)?.toDouble() ?? 0,
    y:        (j['y']       as num?)?.toDouble() ?? 0,
    dirX:     (j['dirX']    as num?)?.toDouble() ?? 1,
    dirY:     (j['dirY']    as num?)?.toDouble() ?? 0,
    score:    (j['score']   as int?) ?? 0,
    kills:    (j['kills']   as int?) ?? 0,
    length:   (j['length']  as int?) ?? 3,
    alive:    (j['alive']   as bool?) ?? true,
  );

  void updateFrom(Map<String, dynamic> j) {
    if (j['x']      != null) x      = (j['x']      as num).toDouble();
    if (j['y']      != null) y      = (j['y']      as num).toDouble();
    if (j['dirX']   != null) dirX   = (j['dirX']   as num).toDouble();
    if (j['dirY']   != null) dirY   = (j['dirY']   as num).toDouble();
    if (j['score']  != null) score  = j['score']  as int;
    if (j['kills']  != null) kills  = j['kills']  as int;
    if (j['length'] != null) length = j['length'] as int;
    if (j['alive']  != null) alive  = j['alive']  as bool;
    if (j['skinId'] != null) skinId = j['skinId'] as String;
  }
}

// ── Entrada do placar global ──────────────────────────────────
class LeaderboardEntry {
  final String username;
  final int bestScore, bestLength, totalKills, gamesPlayed;
  LeaderboardEntry.fromJson(Map<String, dynamic> j)
      : username    = j['username']     as String,
        bestScore   = (j['best_score']  as num).toInt(),
        bestLength  = (j['best_length'] as num).toInt(),
        totalKills  = (j['total_kills'] as num).toInt(),
        gamesPlayed = (j['games_played']as num).toInt();
}

// ── Serviço principal ─────────────────────────────────────────
class OnlineService {
  OnlineService._();
  static final OnlineService instance = OnlineService._();

  // ✅ Troque pela URL do seu servidor no Render
  static const String _serverUrl = 'wss://seu-servidor.onrender.com';

  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  final _eventController = StreamController<OnlineEvent>.broadcast();
  Stream<OnlineEvent> get onEvent => _eventController.stream;

  // Estado público
  bool   get isConnected => _channel != null;
  String? localPlayerId;
  String? roomCode;
  final Map<String, RemotePlayer> remotePlayers = {};
  List<LeaderboardEntry> leaderboard = [];

  // ── Conexão ───────────────────────────────────────────────
  Future<bool> connect() async {
    if (_channel != null) return true;
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));
      await _channel!.ready;
      _sub = _channel!.stream.listen(
        _onMessage,
        onDone:  _onDisconnected,
        onError: (_) => _onDisconnected(),
      );
      return true;
    } catch (e) {
      debugPrint('[Online] Falha ao conectar: $e');
      _channel = null;
      return false;
    }
  }

  void disconnect() {
    _sub?.cancel();
    _channel?.sink.close();
    _channel = null;
    localPlayerId = null;
    roomCode = null;
    remotePlayers.clear();
  }

  // ── Ações ─────────────────────────────────────────────────
  Future<bool> joinMatchmaking(String username, String skinId) async {
    if (!isConnected && !await connect()) return false;
    _send({'type': 'join_matchmaking', 'username': username, 'skinId': skinId});
    return true;
  }

  Future<bool> createRoom(String username, String skinId) async {
    if (!isConnected && !await connect()) return false;
    _send({'type': 'create_room', 'username': username, 'skinId': skinId});
    return true;
  }

  Future<bool> joinRoom(String code, String username, String skinId) async {
    if (!isConnected && !await connect()) return false;
    _send({'type': 'join_room', 'code': code, 'username': username, 'skinId': skinId});
    return true;
  }

  // Chamado a cada frame com o estado atual do player local
  void sendPlayerUpdate({
    required double x, required double y,
    required double dirX, required double dirY,
    required int score, required int length, required int kills,
    required bool alive,
  }) {
    if (!isConnected) return;
    _send({
      'type': 'player_update',
      'data': {'x': x, 'y': y, 'dirX': dirX, 'dirY': dirY,
               'score': score, 'length': length, 'kills': kills, 'alive': alive},
    });
  }

  void sendPlayerDied({required int score, required int length, required int kills}) {
    if (!isConnected) return;
    _send({'type': 'player_died', 'score': score, 'length': length, 'kills': kills});
  }

  void requestLeaderboard() {
    if (!isConnected) return;
    _send({'type': 'get_leaderboard'});
  }

  void leaveRoom() {
    if (!isConnected) return;
    _send({'type': 'leave_room'});
    roomCode = null;
    remotePlayers.clear();
  }

  // ── Recebimento ───────────────────────────────────────────
  void _onMessage(dynamic raw) {
    try {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      switch (msg['type'] as String) {

        case 'room_joined':
          localPlayerId = msg['playerId'] as String;
          roomCode      = msg['code']     as String;
          remotePlayers.clear();
          for (final p in (msg['players'] as List)) {
            final rp = RemotePlayer.fromJson(p as Map<String, dynamic>);
            if (rp.id != localPlayerId) remotePlayers[rp.id] = rp;
          }
          _emit(OnlineEventType.roomJoined, {'code': roomCode, 'players': remotePlayers});
          break;

        case 'player_joined':
          if (msg['player'] != null) {
            final rp = RemotePlayer.fromJson(msg['player'] as Map<String, dynamic>);
            if (rp.id != localPlayerId) {
              remotePlayers[rp.id] = rp;
              _emit(OnlineEventType.playerJoined, {'player': rp});
            }
          }
          break;

        case 'player_left':
          final id = msg['playerId'] as String;
          remotePlayers.remove(id);
          _emit(OnlineEventType.playerLeft, {'playerId': id, 'username': msg['username']});
          break;

        case 'player_died':
          final id = msg['playerId'] as String;
          remotePlayers[id]?.alive = false;
          _emit(OnlineEventType.playerDied, {'playerId': id, 'score': msg['score']});
          break;

        case 'state':
          final players = msg['data']?['players'] as List? ?? [];
          for (final p in players) {
            final map = p as Map<String, dynamic>;
            final id  = map['id'] as String;
            if (id == localPlayerId) continue;
            if (remotePlayers.containsKey(id)) {
              remotePlayers[id]!.updateFrom(map);
            } else {
              remotePlayers[id] = RemotePlayer.fromJson(map);
            }
          }
          _emit(OnlineEventType.stateUpdate, {});
          break;

        case 'leaderboard':
          leaderboard = (msg['rows'] as List)
              .map((r) => LeaderboardEntry.fromJson(r as Map<String, dynamic>))
              .toList();
          _emit(OnlineEventType.leaderboard, {'rows': leaderboard});
          break;

        case 'error':
          _emit(OnlineEventType.error, {'message': msg['message']});
          break;
      }
    } catch (e) {
      debugPrint('[Online] Erro ao processar msg: $e');
    }
  }

  void _onDisconnected() {
    _channel = null;
    remotePlayers.clear();
    _emit(OnlineEventType.disconnected, {});
  }

  void _send(Map<String, dynamic> msg) {
    try {
      _channel?.sink.add(jsonEncode(msg));
    } catch (e) {
      debugPrint('[Online] Erro ao enviar: $e');
    }
  }

  void _emit(OnlineEventType type, Map<String, dynamic> data) {
    _eventController.add(OnlineEvent(type, data: data));
  }
}
