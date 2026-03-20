// lib/overlays/shop_overlay.dart
import 'package:flutter/material.dart';
import '../game/snake_engine.dart';
import '../services/score_service.dart';
import '../utils/constants.dart';

class ShopOverlay extends StatefulWidget {
  final SnakeEngine engine;
  const ShopOverlay({super.key, required this.engine});

  @override
  State<ShopOverlay> createState() => _ShopOverlayState();
}

class _ShopOverlayState extends State<ShopOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  String? _feedback;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _close() {
    widget.engine.overlays.remove(kOverlayShop);
  }

  void _showFeedback(String msg) {
    setState(() => _feedback = msg);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _feedback = null);
    });
  }

  Future<void> _buy({
    required String label,
    required int coinCost,
    required int diamondCost,
    required Future<bool> Function() action,
  }) async {
    final ok = await action();
    if (ok) {
      _showFeedback('✔ $label comprado!');
      setState(() {});
    } else {
      final need = coinCost > 0
          ? 'Precisa de $coinCost moedas'
          : 'Precisa de $diamondCost diamantes';
      _showFeedback('✘ $need');
    }
  }

  @override
  Widget build(BuildContext context) {
    final coins = ScoreService.instance.coins;
    final diamonds = ScoreService.instance.diamonds;
    final boosts = ScoreService.instance.extraBoosts;
    final mq = MediaQuery.of(context);

    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: const TextStyle(
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
          decorationThickness: 0,
        ),
        child: Container(
          color: Colors.black.withOpacity(0.82),
          child: SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Container(
                    width: mq.size.width * 0.88,
                    constraints: BoxConstraints(
                      maxWidth: 440,
                      maxHeight: mq.size.height * 0.88,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: const Color(0xFF0D1B2A),
                      border: Border.all(
                          color: const Color(0xFF1E3A5F), width: 1),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 30)
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Cabeçalho ─────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24)),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF1A3A5C),
                                const Color(0xFF0D1B2A),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.store_rounded,
                                  color: Color(0xFFFFD600), size: 22),
                              const SizedBox(width: 10),
                              const Text(
                                'LOJA',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 4,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const Spacer(),
                              // Saldo
                              _BalancePill(
                                  icon: Icons.monetization_on_rounded,
                                  color: const Color(0xFFFFD600),
                                  value: '$coins'),
                              const SizedBox(width: 8),
                              _BalancePill(
                                  icon: Icons.diamond_rounded,
                                  color: const Color(0xFF00E5FF),
                                  value: '$diamonds'),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: _close,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                  child: const Icon(Icons.close_rounded,
                                      color: Colors.white54, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Feedback ──────────────────────────
                        if (_feedback != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 20),
                            color: _feedback!.startsWith('✔')
                                ? const Color(0xFF1B5E20)
                                : const Color(0xFF7F0000),
                            child: Text(
                              _feedback!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),

                        // ── Itens ─────────────────────────────
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Seção moedas
                                _SectionLabel(
                                    label: 'COM MOEDAS',
                                    icon: Icons.monetization_on_rounded,
                                    color: const Color(0xFFFFD600)),
                                const SizedBox(height: 10),

                                _ShopItem(
                                  icon: '⚡',
                                  iconBg: const Color(0xFF1A3A1A),
                                  title: 'Boost Extra',
                                  subtitle: 'Você tem $boosts boost(s)',
                                  coinCost: 5,
                                  onBuy: () => _buy(
                                    label: 'Boost Extra',
                                    coinCost: 5,
                                    diamondCost: 0,
                                    action: () async {
                                      final ok = await ScoreService
                                          .instance
                                          .spendCoins(5);
                                      if (ok) {
                                        await ScoreService.instance
                                            .addExtraBoosts(1);
                                      }
                                      return ok;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),

                                _ShopItem(
                                  icon: '💊',
                                  iconBg: const Color(0xFF1A1A3A),
                                  title: 'Reviver x1',
                                  subtitle: 'Revive ao morrer (1 uso)',
                                  coinCost: 10,
                                  onBuy: () => _buy(
                                    label: 'Reviver',
                                    coinCost: 10,
                                    diamondCost: 0,
                                    action: () async {
                                      final ok = await ScoreService
                                          .instance
                                          .spendCoins(10);
                                      if (ok) {
                                        final cur = ScoreService
                                            .instance.revives;
                                        await ScoreService.instance
                                            .setRevives(cur + 1);
                                      }
                                      return ok;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),

                                _ShopItem(
                                  icon: '🎨',
                                  iconBg: const Color(0xFF3A1A1A),
                                  title: 'Skin HOT',
                                  subtitle: ScoreService.instance
                                          .isSkinUnlocked('hot')
                                      ? '✔ Desbloqueada'
                                      : 'Cobra de fogo',
                                  coinCost: 30,
                                  locked: ScoreService.instance
                                      .isSkinUnlocked('hot'),
                                  onBuy: () => _buy(
                                    label: 'Skin HOT',
                                    coinCost: 30,
                                    diamondCost: 0,
                                    action: () async {
                                      if (ScoreService.instance
                                          .isSkinUnlocked('hot')) {
                                        return false;
                                      }
                                      final ok = await ScoreService
                                          .instance
                                          .spendCoins(30);
                                      if (ok) {
                                        await ScoreService.instance
                                            .unlockSkin('hot');
                                      }
                                      return ok;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),

                                _ShopItem(
                                  icon: '👾',
                                  iconBg: const Color(0xFF1A3A2A),
                                  title: 'Skin ALIEN',
                                  subtitle: ScoreService.instance
                                          .isSkinUnlocked('alien')
                                      ? '✔ Desbloqueada'
                                      : 'Extraterrestre',
                                  coinCost: 30,
                                  locked: ScoreService.instance
                                      .isSkinUnlocked('alien'),
                                  onBuy: () => _buy(
                                    label: 'Skin ALIEN',
                                    coinCost: 30,
                                    diamondCost: 0,
                                    action: () async {
                                      if (ScoreService.instance
                                          .isSkinUnlocked('alien')) {
                                        return false;
                                      }
                                      final ok = await ScoreService
                                          .instance
                                          .spendCoins(30);
                                      if (ok) {
                                        await ScoreService.instance
                                            .unlockSkin('alien');
                                      }
                                      return ok;
                                    },
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // Seção diamantes
                                _SectionLabel(
                                    label: 'COM DIAMANTES',
                                    icon: Icons.diamond_rounded,
                                    color: const Color(0xFF00E5FF)),
                                const SizedBox(height: 10),

                                _ShopItem(
                                  icon: '👑',
                                  iconBg: const Color(0xFF2A1A00),
                                  title: 'Skin PIRANHA',
                                  subtitle: ScoreService.instance
                                          .isSkinUnlocked('piranha')
                                      ? '✔ Desbloqueada'
                                      : 'Rara exclusiva',
                                  diamondCost: 1,
                                  locked: ScoreService.instance
                                      .isSkinUnlocked('piranha'),
                                  onBuy: () => _buy(
                                    label: 'Skin PIRANHA',
                                    coinCost: 0,
                                    diamondCost: 1,
                                    action: () async {
                                      if (ScoreService.instance
                                          .isSkinUnlocked('piranha')) {
                                        return false;
                                      }
                                      final ok = await ScoreService
                                          .instance
                                          .spendDiamonds(1);
                                      if (ok) {
                                        await ScoreService.instance
                                            .unlockSkin('piranha');
                                      }
                                      return ok;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),

                                _ShopItem(
                                  icon: '🐍',
                                  iconBg: const Color(0xFF1A0A00),
                                  title: 'Skin SERPENTE',
                                  subtitle: ScoreService.instance
                                          .isSkinUnlocked('serpente')
                                      ? '✔ Desbloqueada'
                                      : 'Lendária',
                                  diamondCost: 2,
                                  locked: ScoreService.instance
                                      .isSkinUnlocked('serpente'),
                                  onBuy: () => _buy(
                                    label: 'Skin SERPENTE',
                                    coinCost: 0,
                                    diamondCost: 2,
                                    action: () async {
                                      if (ScoreService.instance
                                          .isSkinUnlocked('serpente')) {
                                        return false;
                                      }
                                      final ok = await ScoreService
                                          .instance
                                          .spendDiamonds(2);
                                      if (ok) {
                                        await ScoreService.instance
                                            .unlockSkin('serpente');
                                      }
                                      return ok;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),

                                _ShopItem(
                                  icon: '💎',
                                  iconBg: const Color(0xFF001A2A),
                                  title: '100 Moedas',
                                  subtitle: 'Troca diamante por moedas',
                                  diamondCost: 1,
                                  onBuy: () => _buy(
                                    label: '100 Moedas',
                                    coinCost: 0,
                                    diamondCost: 1,
                                    action: () async {
                                      final ok = await ScoreService
                                          .instance
                                          .spendDiamonds(1);
                                      if (ok) {
                                        await ScoreService.instance
                                            .addCoins(100);
                                      }
                                      return ok;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _SectionLabel(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 6),
      Text(label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            decoration: TextDecoration.none,
          )),
      const SizedBox(width: 8),
      Expanded(
          child: Container(height: 1, color: color.withOpacity(0.2))),
    ]);
  }
}

class _BalancePill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  const _BalancePill(
      {required this.icon, required this.color, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            )),
      ]),
    );
  }
}

class _ShopItem extends StatelessWidget {
  final String icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final int coinCost;
  final int diamondCost;
  final bool locked;
  final VoidCallback onBuy;

  const _ShopItem({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.coinCost = 0,
    this.diamondCost = 0,
    this.locked = false,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.04),
        border:
            Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Row(children: [
        // Ícone
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: iconBg),
          child: Center(
              child: Text(icon,
                  style: const TextStyle(
                      fontSize: 22, decoration: TextDecoration.none))),
        ),
        const SizedBox(width: 12),
        // Info
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 11,
                      decoration: TextDecoration.none,
                    )),
              ]),
        ),
        const SizedBox(width: 10),
        // Botão comprar
        locked
            ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(0.06),
                ),
                child: const Text('OK',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    )),
              )
            : GestureDetector(
                onTap: onBuy,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: diamondCost > 0
                          ? [
                              const Color(0xFF00B4D8),
                              const Color(0xFF0077B6)
                            ]
                          : [
                              const Color(0xFFFFAA00),
                              const Color(0xFFFF6B00)
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (diamondCost > 0
                                ? const Color(0xFF00E5FF)
                                : const Color(0xFFFFD600))
                            .withOpacity(0.35),
                        blurRadius: 8,
                      )
                    ],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      diamondCost > 0
                          ? Icons.diamond_rounded
                          : Icons.monetization_on_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${diamondCost > 0 ? diamondCost : coinCost}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ]),
                ),
              ),
      ]),
    );
  }
}
