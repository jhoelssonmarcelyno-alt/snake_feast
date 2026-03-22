# Serpent Strike — Modo Online

## Estrutura

```
server/          ← Servidor Node.js (deploy no Render)
  src/
    index.js     ← Entry point WebSocket
    rooms.js     ← Gerenciamento de salas
    handler.js   ← Lógica de mensagens
    database.js  ← PostgreSQL
  schema.sql     ← Execute no banco antes de iniciar
  package.json
  .env.example   ← Copie para .env

flutter/
  online_service.dart  → lib/services/
  online_lobby.dart    → lib/overlays/
```

---

## 1. Configurar o banco (PostgreSQL)

Execute o `schema.sql` no seu banco:
```bash
psql $DATABASE_URL -f server/schema.sql
```

---

## 2. Deploy no Render

1. Crie um novo **Web Service** no Render
2. Repositório: aponte para a pasta `server/`
3. Build command: `npm install`
4. Start command: `npm start`
5. Adicione as variáveis de ambiente:
   - `DATABASE_URL` = sua connection string do PostgreSQL
   - `PORT` = 8080 (o Render define automaticamente)
   - `MAX_PLAYERS_PER_ROOM` = 20
   - `TICK_RATE` = 20

---

## 3. Flutter — dependência necessária

Adicione no `pubspec.yaml`:
```yaml
dependencies:
  web_socket_channel: ^2.4.0
```

---

## 4. Flutter — configurar URL do servidor

Em `online_service.dart`, troque:
```dart
static const String _serverUrl = 'wss://seu-servidor.onrender.com';
```
pela URL real do seu Web Service no Render.

---

## 5. Flutter — adicionar ao menu principal

No seu menu, adicione um botão que abre `OnlineLobbyOverlay`:
```dart
// No overlayBuilderMap do GameWidget:
kOverlayOnlineLobby: (context, game) =>
    OnlineLobbyOverlay(onClose: () => game.overlays.remove(kOverlayOnlineLobby)),
```

---

## 6. Integrar com o engine (próximo passo)

O `online_lobby.dart` chama `_startGame()` ao clicar em JOGAR.
Integre com o `SnakeEngine` passando `OnlineService.instance`:
- `OnlineService.instance.remotePlayers` → renderize os jogadores remotos
- Chame `OnlineService.instance.sendPlayerUpdate(...)` a cada frame no `update()`
- Chame `OnlineService.instance.sendPlayerDied(...)` no `die()`

---

## Protocolo de mensagens

| Cliente → Servidor | Campos |
|---|---|
| `join_matchmaking` | `username`, `skinId` |
| `create_room` | `username`, `skinId` |
| `join_room` | `code`, `username`, `skinId` |
| `player_update` | `data: {x,y,dirX,dirY,score,length,kills,alive}` |
| `player_died` | `score`, `length`, `kills` |
| `get_leaderboard` | — |
| `leave_room` | — |

| Servidor → Cliente | Campos |
|---|---|
| `room_joined` | `code`, `playerId`, `players[]` |
| `player_joined` | `player` |
| `player_left` | `playerId`, `username` |
| `state` | `data.players[]` (20fps) |
| `leaderboard` | `rows[]` |
| `error` | `message` |
