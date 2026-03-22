// src/handler.js
// Tipos de mensagem cliente → servidor:
//   join_matchmaking  { username, skinId }
//   create_room       { username, skinId }
//   join_room         { username, skinId, code }
//   player_update     { x, y, dirX, dirY, score, length, kills, alive }
//   player_died       { score, length, kills }
//   get_leaderboard   {}
//   leave_room        {}
//
// Tipos servidor → cliente:
//   room_joined       { code, playerId, players[] }
//   player_joined     { player }
//   player_left       { playerId, username }
//   state             { players[] }
//   leaderboard       { rows[] }
//   error             { message }

const { Database } = require('./database');

class MessageHandler {
  constructor(rooms) {
    this.rooms = rooms;
  }

  handle(ws, msg) {
    switch (msg.type) {
      case 'join_matchmaking': return this._joinMatchmaking(ws, msg);
      case 'create_room':      return this._createRoom(ws, msg);
      case 'join_room':        return this._joinRoom(ws, msg);
      case 'player_update':    return this._playerUpdate(ws, msg);
      case 'player_died':      return this._playerDied(ws, msg);
      case 'get_leaderboard':  return this._getLeaderboard(ws);
      case 'leave_room':       return this.handleDisconnect(ws);
      default:
        ws.send(JSON.stringify({ type: 'error', message: `Tipo desconhecido: ${msg.type}` }));
    }
  }

  _joinMatchmaking(ws, msg) {
    const room = this.rooms.findOrCreatePublic();
    this._enterRoom(ws, room, msg.username, msg.skinId);
  }

  _createRoom(ws, msg) {
    const room = this.rooms.createRoom(true); // privada
    this._enterRoom(ws, room, msg.username, msg.skinId);
  }

  _joinRoom(ws, msg) {
    const room = this.rooms.getRoom(msg.code);
    if (!room) {
      ws.send(JSON.stringify({ type: 'error', message: 'Sala não encontrada.' }));
      return;
    }
    if (room.isFull) {
      ws.send(JSON.stringify({ type: 'error', message: 'Sala cheia.' }));
      return;
    }
    this._enterRoom(ws, room, msg.username, msg.skinId);
  }

  _enterRoom(ws, room, username, skinId) {
    // Remove de sala anterior se houver
    if (ws.roomCode) this._leaveRoom(ws);

    ws.username = username || `Jogador${Math.floor(Math.random()*9999)}`;
    ws.roomCode = room.code;
    room.addPlayer(ws, ws.username);
    room.updatePlayer(ws.id, { skinId: skinId || 'classic' });

    // Confirma entrada com estado atual da sala
    ws.send(JSON.stringify({
      type:     'room_joined',
      code:     room.code,
      playerId: ws.id,
      players:  room.getState().players,
    }));

    // Avisa outros jogadores
    room.broadcast({
      type:   'player_joined',
      player: room.players.get(ws.id) ? {
        id:       ws.id,
        username: ws.username,
        skinId:   skinId || 'classic',
        x: room.players.get(ws.id)?.x,
        y: room.players.get(ws.id)?.y,
        alive: true,
        score: 0,
        length: 3,
      } : null,
    }, ws.id);

    console.log(`[Room ${room.code}] ${ws.username} entrou. Total: ${room.playerCount}`);
  }

  _playerUpdate(ws, msg) {
    if (!ws.roomCode) return;
    const room = this.rooms.getRoom(ws.roomCode);
    if (!room) return;
    room.updatePlayer(ws.id, msg.data || msg);
    // O estado é enviado pelo tick da sala — não precisa broadcast aqui
  }

  async _playerDied(ws, msg) {
    if (!ws.roomCode) return;
    const room = this.rooms.getRoom(ws.roomCode);
    if (room) {
      room.updatePlayer(ws.id, { alive: false, ...msg });
      room.broadcast({ type: 'player_died', playerId: ws.id, score: msg.score }, ws.id);
    }
    // Salva score no banco
    if (ws.username) {
      try {
        await Database.saveScore({
          username: ws.username,
          score:    msg.score  || 0,
          length:   msg.length || 0,
          kills:    msg.kills  || 0,
          roomCode: ws.roomCode,
        });
      } catch (e) {
        console.error('[DB] Erro ao salvar score:', e.message);
      }
    }
  }

  async _getLeaderboard(ws) {
    try {
      const rows = await Database.getLeaderboard();
      ws.send(JSON.stringify({ type: 'leaderboard', rows }));
    } catch (e) {
      ws.send(JSON.stringify({ type: 'error', message: 'Erro ao buscar placar.' }));
    }
  }

  handleDisconnect(ws) {
    if (!ws.roomCode) return;
    this._leaveRoom(ws);
  }

  _leaveRoom(ws) {
    const room = this.rooms.getRoom(ws.roomCode);
    if (!room) return;
    room.removePlayer(ws.id);
    room.broadcast({ type: 'player_left', playerId: ws.id, username: ws.username });
    console.log(`[Room ${ws.roomCode}] ${ws.username} saiu. Total: ${room.playerCount}`);
    if (room.isEmpty) this.rooms.deleteRoom(ws.roomCode);
    ws.roomCode = null;
  }
}

module.exports = { MessageHandler };
