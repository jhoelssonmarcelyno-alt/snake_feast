// src/rooms.js
const MAX_PLAYERS = parseInt(process.env.MAX_PLAYERS_PER_ROOM) || 20;
const TICK_MS     = 1000 / (parseInt(process.env.TICK_RATE) || 20); // 50ms = 20 ticks/s

class Room {
  constructor(code, isPrivate = false) {
    this.code      = code;
    this.isPrivate = isPrivate;
    this.players   = new Map(); // ws.id → PlayerState
    this.foods     = [];
    this.tickTimer = null;
    this.createdAt = Date.now();
  }

  get playerCount() { return this.players.size; }
  get isFull()      { return this.players.size >= MAX_PLAYERS; }
  get isEmpty()     { return this.players.size === 0; }

  addPlayer(ws, username) {
    this.players.set(ws.id, {
      id:       ws.id,
      username,
      ws,
      x: 1000 + Math.random() * 4000,
      y: 1000 + Math.random() * 4000,
      dirX:  1,
      dirY:  0,
      score: 0,
      kills: 0,
      length: 3,
      alive: true,
      skinId: 'classic',
    });
    if (this.players.size === 1) this._startTick();
  }

  removePlayer(wsId) {
    this.players.delete(wsId);
    if (this.isEmpty) this._stopTick();
  }

  updatePlayer(wsId, data) {
    const p = this.players.get(wsId);
    if (!p) return;
    if (data.dirX !== undefined) p.dirX = data.dirX;
    if (data.dirY !== undefined) p.dirY = data.dirY;
    if (data.score  !== undefined) p.score  = data.score;
    if (data.length !== undefined) p.length = data.length;
    if (data.kills  !== undefined) p.kills  = data.kills;
    if (data.alive  !== undefined) p.alive  = data.alive;
    if (data.x      !== undefined) p.x      = data.x;
    if (data.y      !== undefined) p.y      = data.y;
    if (data.skinId !== undefined) p.skinId = data.skinId;
  }

  broadcast(msg, excludeId = null) {
    const raw = JSON.stringify(msg);
    this.players.forEach(({ ws }, id) => {
      if (id !== excludeId && ws.readyState === 1) {
        ws.send(raw);
      }
    });
  }

  broadcastAll(msg) {
    this.broadcast(msg, null);
  }

  getState() {
    const players = [];
    this.players.forEach((p) => {
      players.push({
        id:       p.id,
        username: p.username,
        x:        p.x,
        y:        p.y,
        dirX:     p.dirX,
        dirY:     p.dirY,
        score:    p.score,
        kills:    p.kills,
        length:   p.length,
        alive:    p.alive,
        skinId:   p.skinId,
      });
    });
    return { players };
  }

  // Tick: envia estado de todos para todos a 20fps
  _startTick() {
    this.tickTimer = setInterval(() => {
      if (this.isEmpty) { this._stopTick(); return; }
      this.broadcastAll({ type: 'state', data: this.getState() });
    }, TICK_MS);
  }

  _stopTick() {
    if (this.tickTimer) {
      clearInterval(this.tickTimer);
      this.tickTimer = null;
    }
  }
}

class RoomManager {
  constructor() {
    this.rooms = new Map(); // code → Room
    // Limpa salas vazias a cada 2 minutos
    setInterval(() => this._cleanup(), 120000);
  }

  createRoom(isPrivate = false) {
    const code = this._genCode();
    const room = new Room(code, isPrivate);
    this.rooms.set(code, room);
    return room;
  }

  getRoom(code) {
    return this.rooms.get(code.toUpperCase()) || null;
  }

  // Encontra sala pública com vagas ou cria uma nova
  findOrCreatePublic() {
    for (const room of this.rooms.values()) {
      if (!room.isPrivate && !room.isFull) return room;
    }
    return this.createRoom(false);
  }

  deleteRoom(code) {
    const room = this.rooms.get(code);
    if (room) room._stopTick();
    this.rooms.delete(code);
  }

  _genCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    let code;
    do {
      code = Array.from({ length: 6 }, () => chars[Math.floor(Math.random() * chars.length)]).join('');
    } while (this.rooms.has(code));
    return code;
  }

  _cleanup() {
    for (const [code, room] of this.rooms.entries()) {
      if (room.isEmpty) {
        room._stopTick();
        this.rooms.delete(code);
        console.log(`[Room] Sala vazia removida: ${code}`);
      }
    }
  }
}

module.exports = { RoomManager, Room };
