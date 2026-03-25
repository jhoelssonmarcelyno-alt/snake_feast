// lib/overlays/online_lobby.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/online_service.dart';
import '../services/score_service.dart';
import '../utils/constants.dart';

const String kOverlayOnlineLobby = 'OnlineLobby';

class OnlineLobbyOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final dynamic engine; // SnakeEngine
  const OnlineLobbyOverlay({super.key, required this.onClose, this.engine});

  @override
  State<OnlineLobbyOverlay> createState() => _OnlineLobbyOverlayState();
}

class _OnlineLobbyOverlayState extends State<OnlineLobbyOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  final _online = OnlineService.instance;
  final _codeCtrl = TextEditingController();

  _Screen _screen = _Screen.main;
  bool _loading = false;
  String _status = '';
  String _roomCode = '';

  StreamSubscription? _eventSub;

  static const _cyan = Color(0xFF00E5FF);
  static const _green = Color(0xFF2ECC71);
  static const _bg = Color(0xFF0A1520);
  static const _noLine = TextStyle(decoration: TextDecoration.none);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _eventSub = _online.onEvent.listen(_onEvent);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _codeCtrl.dispose();
    _eventSub?.cancel();
    super.dispose();
  }

  void _onEvent(OnlineEvent event) {
    if (!mounted) return;
    switch (event.type) {
      case OnlineEventType.roomJoined:
        setState(() {
          _screen = _Screen.room;
          _loading = false;
          _roomCode = event.data['code'] as String? ?? '';
          _status = 'Conectado! Sala: $_roomCode';
        });
        break;
      case OnlineEventType.playerJoined:
        setState(() => _status =
            '${(event.data['player'] as RemotePlayer?)?.username ?? 'Jogador'} entrou!');
        break;
      case OnlineEventType.playerLeft:
        setState(
            () => _status = '${event.data['username'] ?? 'Jogador'} saiu.');
        break;
      case OnlineEventType.error:
        setState(() {
          _loading = false;
          _status = event.data['message'] as String? ?? 'Erro desconhecido';
        });
        break;
      case OnlineEventType.disconnected:
        setState(() {
          _screen = _Screen.main;
          _loading = false;
          _status = 'Desconectado do servidor.';
        });
        break;
      default:
        break;
    }
  }

  Future<void> _joinMatchmaking() async {
    setState(() {
      _loading = true;
      _status = 'Buscando partida...';
    });

    final name = ScoreService.instance.playerName;
    // ✅ Corrigido: usando .selectedSkin.id do novo ScoreService
    final skinId = ScoreService.instance.selectedSkin.id;

    final ok = await _online.joinMatchmaking(name, skinId);

    if (!ok && mounted) {
      setState(() {
        _loading = false;
        _status = 'Sem conexão com o servidor.';
      });
    }
  }

  Future<void> _createRoom() async {
    setState(() {
      _loading = true;
      _status = 'Criando sala...';
    });

    final name = ScoreService.instance.playerName;
    // ✅ Corrigido: usando .selectedSkin.id do novo ScoreService
    final skinId = ScoreService.instance.selectedSkin.id;

    final ok = await _online.createRoom(name, skinId);

    if (!ok && mounted) {
      setState(() {
        _loading = false;
        _status = 'Sem conexão com o servidor.';
      });
    }
  }

  Future<void> _joinWithCode() async {
    final code = _codeCtrl.text.trim().toUpperCase();

    // ✅ Validação de código com chaves e lógica corrigida
    if (code.length != 6) {
      setState(() => _status = 'Código deve ter 6 caracteres.');
      return; // Agora o return está dentro do if, permitindo que o código abaixo execute
    }

    setState(() {
      _loading = true;
      _status = 'Entrando na sala...';
    });

    final name = ScoreService.instance.playerName;
    // ✅ Corrigido: usando .selectedSkin.id para o Jhoelsson Studio
    final skinId = ScoreService.instance.selectedSkin.id;

    final ok = await _online.joinRoom(code, name, skinId);

    if (!ok && mounted) {
      setState(() {
        _loading = false;
        _status = 'Sem conexão com o servidor.';
      });
    }
  }

  void _leave() {
    _online.leaveRoom();
    setState(() {
      _screen = _Screen.main;
      _status = '';
      _roomCode = '';
    });
  }

  void _startGame() {
    // TODO: integrar com SnakeEngine para modo online
    // engine.startOnlineGame(_online.roomCode, _online.remotePlayers);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final maxH = (mq.size.height - mq.padding.top - mq.padding.bottom) * 0.92;

    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: _noLine,
        child: GestureDetector(
          onTap: widget.onClose,
          child: Container(
            color: Colors.black.withValues(alpha: 0.88),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: mq.size.width * 0.92,
                      constraints:
                          BoxConstraints(maxWidth: 440, maxHeight: maxH),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: _bg,
                        border: Border.all(
                            color: _cyan.withValues(alpha: 0.25), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: _cyan.withValues(alpha: 0.08),
                              blurRadius: 40,
                              spreadRadius: 2)
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          if (_status.isNotEmpty) _buildStatus(),
                          Flexible(child: _buildBody()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = {
      _Screen.main: 'ONLINE',
      _Screen.joinCode: 'ENTRAR COM CÓDIGO',
      _Screen.room: 'SALA ONLINE',
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border:
            Border(bottom: BorderSide(color: _cyan.withValues(alpha: 0.12))),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: _cyan.withValues(alpha: 0.12)),
          child: const Icon(Icons.public_rounded, color: _cyan, size: 20),
        ),
        const SizedBox(width: 12),
        Text(titles[_screen] ?? 'ONLINE',
            style: const TextStyle(
                color: _cyan,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                decoration: TextDecoration.none)),
        const Spacer(),
        GestureDetector(
          onTap: _screen == _Screen.main
              ? widget.onClose
              : () {
                  if (_screen == _Screen.room) _leave();
                  setState(() {
                    _screen = _Screen.main;
                    _status = '';
                  });
                },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05)),
            child: Icon(
                _screen == _Screen.main
                    ? Icons.close_rounded
                    : Icons.arrow_back_rounded,
                color: Colors.white54,
                size: 16),
          ),
        ),
      ]),
    );
  }

  Widget _buildStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: _cyan.withValues(alpha: 0.07),
      child: Text(_status,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: _cyan.withValues(alpha: 0.8),
              fontSize: 11,
              decoration: TextDecoration.none)),
    );
  }

  Widget _buildBody() {
    if (_loading)
      return const Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator(color: _cyan)));
    switch (_screen) {
      case _Screen.main:
        return _buildMain();
      case _Screen.joinCode:
        return _buildJoinCode();
      case _Screen.room:
        return _buildRoom();
    }
  }

  Widget _buildMain() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: _cyan.withValues(alpha: 0.3), width: 2)),
          child: const Icon(Icons.public_rounded, color: _cyan, size: 36),
        ),
        const SizedBox(height: 12),
        Text('Jogue contra pessoas do mundo todo!',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
                height: 1.5,
                decoration: TextDecoration.none)),
        const SizedBox(height: 24),
        _OnlineButton(
          icon: Icons.shuffle_rounded,
          label: 'PARTIDA RÁPIDA',
          subtitle: 'Entra numa sala aleatória',
          color: _cyan,
          onTap:
              _joinMatchmaking, // ✅ Corrigido para o nome da função que existe
        ),
        const SizedBox(height: 10),
        _OnlineButton(
            icon: Icons.add_circle_outline_rounded,
            label: 'CRIAR SALA',
            subtitle: 'Cria sala privada e convida amigos',
            color: _green,
            onTap: _createRoom),
        const SizedBox(height: 10),
        _OnlineButton(
            icon: Icons.vpn_key_rounded,
            label: 'ENTRAR COM CÓDIGO',
            subtitle: 'Tem um código de sala? Entre aqui',
            color: const Color(0xFFFFAB40),
            onTap: () => setState(() => _screen = _Screen.joinCode)),
        const SizedBox(height: 10),
        _OnlineButton(
            icon: Icons.leaderboard_rounded,
            label: 'PLACAR GLOBAL',
            subtitle: 'Veja os melhores jogadores',
            color: const Color(0xFFE040FB),
            onTap: () => widget.engine.overlays.add(kOverlayRanking)),
      ]),
    );
  }

  Widget _buildJoinCode() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 16),
        Text('Digite o código da sala',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
                decoration: TextDecoration.none)),
        const SizedBox(height: 16),
        TextField(
          controller: _codeCtrl,
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              decoration: TextDecoration.none),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _cyan.withValues(alpha: 0.3))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _cyan.withValues(alpha: 0.3))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _cyan, width: 2)),
            hintText: 'ABC123',
            hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.2),
                fontSize: 28,
                letterSpacing: 8),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))
          ],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _joinWithCode,
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFFFAB40)),
            child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login_rounded, color: Colors.black, size: 18),
                  SizedBox(width: 8),
                  Text('ENTRAR',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          decoration: TextDecoration.none)),
                ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildRoom() {
    final players = _online.remotePlayers.values.toList();
    return Column(mainAxisSize: MainAxisSize.min, children: [
      // Código da sala com botão de copiar
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Row(children: [
          const Icon(Icons.meeting_room_rounded,
              color: Colors.white38, size: 14),
          const SizedBox(width: 6),
          Text('Código: ',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  decoration: TextDecoration.none)),
          Text(_roomCode,
              style: const TextStyle(
                  color: _cyan,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  decoration: TextDecoration.none)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: _roomCode));
              setState(() => _status = 'Código copiado!');
            },
            child:
                const Icon(Icons.copy_rounded, color: Colors.white38, size: 14),
          ),
          const Spacer(),
          Text('${players.length + 1}/20',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                  decoration: TextDecoration.none)),
        ]),
      ),

      // Lista de jogadores
      Flexible(
        child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            shrinkWrap: true,
            children: [
              // Jogador local
              _PlayerTile(
                  username: ScoreService.instance.playerName, isLocal: true),
              // Jogadores remotos
              for (final p in players)
                _PlayerTile(
                    username: p.username, isLocal: false, skinId: p.skinId),
            ]),
      ),

      // Botão iniciar
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: GestureDetector(
          onTap: _startGame,
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), color: _green),
            child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.black, size: 22),
                  SizedBox(width: 8),
                  Text('JOGAR',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          decoration: TextDecoration.none)),
                ]),
          ),
        ),
      ),
    ]);
  }
}

enum _Screen { main, joinCode, room }

class _OnlineButton extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _OnlineButton(
      {required this.icon,
      required this.label,
      required this.subtitle,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: color.withValues(alpha: 0.15)),
              child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        decoration: TextDecoration.none)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11,
                        decoration: TextDecoration.none)),
              ])),
          Icon(Icons.chevron_right_rounded,
              color: color.withValues(alpha: 0.5), size: 20),
        ]),
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final String username;
  final bool isLocal;
  final String skinId;
  const _PlayerTile(
      {required this.username, required this.isLocal, this.skinId = 'classic'});

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00E5FF);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isLocal
            ? cyan.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.03),
        border: Border.all(
            color: isLocal
                ? cyan.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: cyan.withValues(alpha: 0.12)),
          child: Icon(Icons.person_rounded,
              color: isLocal ? cyan : Colors.white54, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(username,
              style: TextStyle(
                  color: isLocal ? Colors.white : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none)),
          Text(isLocal ? 'Você' : skinId,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 10,
                  decoration: TextDecoration.none)),
        ])),
        if (isLocal)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: cyan.withValues(alpha: 0.15),
                border: Border.all(color: cyan.withValues(alpha: 0.4))),
            child: const Text('VOCÊ',
                style: TextStyle(
                    color: cyan,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    decoration: TextDecoration.none)),
          ),
      ]),
    );
  }
}
