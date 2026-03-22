// src/index.js
require('dotenv').config();
const { WebSocketServer } = require('ws');
const { RoomManager }     = require('./rooms');
const { Database }        = require('./database');
const { MessageHandler }  = require('./handler');

const PORT = process.env.PORT || 8080;

async function main() {
  await Database.connect();
  console.log('[DB] PostgreSQL conectado');

  const wss     = new WebSocketServer({ port: PORT });
  const rooms   = new RoomManager();
  const handler = new MessageHandler(rooms);

  wss.on('connection', (ws) => {
    ws.id       = require('uuid').v4();
    ws.isAlive  = true;
    ws.username = null;
    ws.roomCode = null;

    console.log(`[WS] Conexão: ${ws.id}`);

    ws.on('pong', () => { ws.isAlive = true; });

    ws.on('message', (raw) => {
      try {
        const msg = JSON.parse(raw.toString());
        handler.handle(ws, msg);
      } catch (e) {
        console.error('[WS] Mensagem inválida:', e.message);
      }
    });

    ws.on('close', () => {
      handler.handleDisconnect(ws);
      console.log(`[WS] Desconectado: ${ws.id}`);
    });

    ws.on('error', (err) => console.error('[WS] Erro:', err.message));
  });

  // Ping/pong para detectar conexões mortas
  setInterval(() => {
    wss.clients.forEach((ws) => {
      if (!ws.isAlive) { ws.terminate(); return; }
      ws.isAlive = false;
      ws.ping();
    });
  }, 15000);

  console.log(`[WS] Servidor rodando na porta ${PORT}`);
}

main().catch(console.error);
