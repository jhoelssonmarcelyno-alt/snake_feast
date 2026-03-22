// lib/overlays/ranking_overlay.dart
import 'package:flutter/material.dart';
import '../game/snake_engine.dart';
import '../services/score_service.dart';
import '../utils/constants.dart';

class RankingOverlay extends StatefulWidget {
  final SnakeEngine engine;
  const RankingOverlay({super.key, required this.engine});

  @override
  State<RankingOverlay> createState() => _RankingOverlayState();
}

class _RankingOverlayState extends State<RankingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late List<Map<String, dynamic>> _local;

  @override
  void initState() {
    super.initState();
    _local = ScoreService.instance.getLocalRanking();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _close() => widget.engine.overlays.remove(kOverlayRanking);

  String _medal(int pos) {
    if (pos == 1) return '🥇';
    if (pos == 2) return '🥈';
    if (pos == 3) return '🥉';
    return '';
  }

  Color _posColor(int pos) {
    if (pos == 1) return const Color(0xFFFFD700);
    if (pos == 2) return const Color(0xFFB0BEC5);
    if (pos == 3) return const Color(0xFFFF8A65);
    return Colors.white38;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final myName = ScoreService.instance.playerName.toLowerCase();

    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: const TextStyle(
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
            decorationThickness: 0),
        child: Container(
          color: Colors.black.withOpacity(0.82),
          child: SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Container(
                    width: mq.size.width * 0.90,
                    constraints: BoxConstraints(
                      maxWidth: 440,
                      maxHeight: mq.size.height * 0.86,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: const Color(0xFF0D1B2A),
                      border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.5),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.10),
                            blurRadius: 30,
                            spreadRadius: 4)
                      ],
                    ),
                    child: Column(children: [
                      // ── Cabeçalho ────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                        decoration: const BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24)),
                          gradient: LinearGradient(
                            colors: [Color(0xFF2A1E00), Color(0xFF0D1B2A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(children: [
                          const Text('🏆',
                              style: TextStyle(
                                  fontSize: 24,
                                  decoration: TextDecoration.none)),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('HALL DA FAMA',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFFFD700),
                                        letterSpacing: 3,
                                        decoration: TextDecoration.none)),
                                Text('Melhores recordes neste dispositivo',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white38,
                                        decoration: TextDecoration.none)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _close,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.07)),
                              child: const Icon(Icons.close_rounded,
                                  color: Colors.white38, size: 17),
                            ),
                          ),
                        ]),
                      ),

                      // ── Lista ─────────────────────────────────
                      Flexible(
                        child: _local.isEmpty
                            ? _buildEmpty()
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                itemCount: _local.length,
                                itemBuilder: (_, i) {
                                  final e = _local[i];
                                  final pos = i + 1;
                                  final name = e['name'] as String;
                                  final score = e['score'] as int;
                                  final isMe = name.toLowerCase() == myName;
                                  final isTop3 = pos <= 3;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 3),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 11),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: isMe
                                          ? const Color(0xFFFFD700)
                                              .withOpacity(0.07)
                                          : isTop3
                                              ? Colors.white.withOpacity(0.03)
                                              : Colors.transparent,
                                      border: isMe
                                          ? Border.all(
                                              color: const Color(0xFFFFD700)
                                                  .withOpacity(0.35),
                                              width: 1.2)
                                          : isTop3
                                              ? Border.all(
                                                  color: _posColor(pos)
                                                      .withOpacity(0.18),
                                                  width: 1)
                                              : null,
                                    ),
                                    child: Row(children: [
                                      // Medalha / número
                                      SizedBox(
                                        width: 40,
                                        child: isTop3
                                            ? Text(_medal(pos),
                                                style: const TextStyle(
                                                    fontSize: 22,
                                                    decoration:
                                                        TextDecoration.none))
                                            : Text('$pos',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: _posColor(pos),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    decoration:
                                                        TextDecoration.none)),
                                      ),
                                      // Nome
                                      Expanded(
                                        child: Row(children: [
                                          Flexible(
                                            child: Text(name,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: isMe
                                                      ? const Color(0xFFFFD700)
                                                      : Colors.white,
                                                  fontSize:
                                                      isMe || isTop3 ? 14 : 13,
                                                  fontWeight: isMe || isTop3
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  decoration:
                                                      TextDecoration.none,
                                                )),
                                          ),
                                          if (isMe) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                color: const Color(0xFFFFD700)
                                                    .withOpacity(0.15),
                                              ),
                                              child: const Text('VOCÊ',
                                                  style: TextStyle(
                                                      color: Color(0xFFFFD700),
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 1,
                                                      decoration:
                                                          TextDecoration.none)),
                                            ),
                                          ],
                                        ]),
                                      ),
                                      // Score
                                      Text('$score',
                                          style: TextStyle(
                                              color: isMe
                                                  ? const Color(0xFFFFD700)
                                                  : const Color(0xFF00E5FF),
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.none)),
                                    ]),
                                  );
                                },
                              ),
                      ),

                      // ── Botão fechar ──────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                        child: GestureDetector(
                          onTap: _close,
                          child: Container(
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white.withOpacity(0.04),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.10)),
                            ),
                            child: const Center(
                                child: Text('FECHAR',
                                    style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                        decoration: TextDecoration.none))),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('🎮',
            style: TextStyle(fontSize: 44, decoration: TextDecoration.none)),
        SizedBox(height: 14),
        Text('Nenhum recorde ainda!',
            style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none)),
        SizedBox(height: 8),
        Text('Jogue uma partida para\naparecer aqui',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white24,
                fontSize: 12,
                decoration: TextDecoration.none)),
      ]),
    );
  }
}
