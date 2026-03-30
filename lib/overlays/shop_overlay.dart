// lib/overlays/shop_overlay.dart
import 'package:flutter/material.dart';
import '../game/snake_engine.dart';
import '../game/skins/skin_manager.dart';
import '../game/skins/skin_rarity.dart';
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
  late final TabController _tab;
  String? _feedback;
  bool _feedbackOk = true;
  late SkinManager _skinManager;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _skinManager = SkinManager();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _close() => widget.engine.overlays.remove(kOverlayShop);

  void _showFeedback(String msg, bool ok) {
    setState(() {
      _feedback = msg;
      _feedbackOk = ok;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _feedback = null);
    });
  }

  Future<void> _buySkin(SnakeSkin skin) async {
    final skinId = kPlayerSkins.indexOf(skin);

    if (_skinManager.isSkinUnlocked(skinId)) {
      _equipSkin(skin);
      return;
    }

    final price = _skinPrice(skin);
    final isDiamond = skin.rarity == SkinRarity.legendary ||
        skin.rarity == SkinRarity.epic ||
        skin.rarity == SkinRarity.mythical;

    final ok = isDiamond
        ? await ScoreService.instance.spendDiamonds(price)
        : await ScoreService.instance.spendCoins(price);

    if (ok) {
      await _skinManager.unlockSkin(skinId);
      _equipSkin(skin);
      _showFeedback('✔ ${skin.name} desbloqueada!', true);
    } else {
      _showFeedback(
          '✘ Precisa de $price ${isDiamond ? 'diamantes' : 'moedas'}', false);
    }
    setState(() {});
  }

  void _equipSkin(SnakeSkin skin) {
    final idx = kPlayerSkins.indexWhere((s) => s.id == skin.id);
    if (idx < 0) return;
    _skinManager.selectSkin(idx);
    widget.engine.setSkin(idx);
    _showFeedback('✔ ${skin.name} equipada!', true);
    setState(() {});
  }

  int _skinPrice(SnakeSkin skin) {
    switch (skin.rarity) {
      case SkinRarity.uncommon:
        return 30;
      case SkinRarity.rare:
        return 50;
      case SkinRarity.epic:
        return 80;
      case SkinRarity.legendary:
        return 3;
      case SkinRarity.mythical:
        return 5;
      default:
        return 0;
    }
  }

  Color _rarityColor(SkinRarity rarity) {
    switch (rarity) {
      case SkinRarity.uncommon:
        return const Color(0xFF69F0AE);
      case SkinRarity.rare:
        return const Color(0xFF29CFFF);
      case SkinRarity.epic:
        return const Color(0xFF9B59B6);
      case SkinRarity.legendary:
        return const Color(0xFFFFD700);
      case SkinRarity.mythical:
        return const Color(0xFFFF4444);
      default:
        return Colors.white54;
    }
  }

  String _rarityLabel(SkinRarity rarity) {
    switch (rarity) {
      case SkinRarity.uncommon:
        return 'INCOMUM';
      case SkinRarity.rare:
        return 'RARA';
      case SkinRarity.epic:
        return 'ÉPICA';
      case SkinRarity.legendary:
        return '★ LENDÁRIA';
      case SkinRarity.mythical:
        return '⚡ MÍTICA';
      default:
        return 'COMUM';
    }
  }

  @override
  Widget build(BuildContext context) {
    final coins = ScoreService.instance.coins;
    final diamonds = ScoreService.instance.diamonds;
    final revives = ScoreService.instance.revives;
    final revivePrice = ScoreService.instance.revivePrice;
    final mq = MediaQuery.of(context);
    final equippedId = _skinManager.selectedSkinId;

    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: const TextStyle(
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
            decorationThickness: 0),
        child: Container(
          color: Colors.black.withValues(alpha: 0.85),
          child: SafeArea(
            child: Center(
              child: Container(
                width: mq.size.width * 0.92,
                height: mq.size.height * 0.88,
                constraints: const BoxConstraints(maxWidth: 480),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: const Color(0xFF0D1B2A),
                  border: Border.all(color: const Color(0xFF1E3A5F)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 30)
                  ],
                ),
                child: Column(children: [
                  // ── Cabeçalho ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                      color: Color(0xFF0A1420),
                    ),
                    child: Column(children: [
                      Row(children: [
                        const Icon(Icons.store_rounded,
                            color: Color(0xFFFFD600), size: 20),
                        const SizedBox(width: 8),
                        const Text('LOJA',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 4,
                                decoration: TextDecoration.none)),
                        const Spacer(),
                        _Pill(
                            icon: Icons.monetization_on_rounded,
                            color: const Color(0xFFFFD600),
                            value: '$coins'),
                        const SizedBox(width: 6),
                        _Pill(
                            icon: Icons.diamond_rounded,
                            color: const Color(0xFF00E5FF),
                            value: '$diamonds'),
                        const SizedBox(width: 6),
                        _Pill(
                            icon: Icons.favorite_rounded,
                            color: const Color(0xFF2ECC71),
                            value: '$revives'),
                        const SizedBox(width: 10),
                        GestureDetector(
                            onTap: _close,
                            child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        Colors.white.withValues(alpha: 0.08)),
                                child: const Icon(Icons.close_rounded,
                                    color: Colors.white54, size: 16))),
                      ]),
                      const SizedBox(height: 10),
                      TabBar(
                        controller: _tab,
                        indicatorColor: const Color(0xFFFFD600),
                        labelColor: const Color(0xFFFFD600),
                        unselectedLabelColor: Colors.white38,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelStyle: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            decoration: TextDecoration.none),
                        tabs: const [
                          Tab(text: 'SKINS'),
                          Tab(text: 'ITENS'),
                          Tab(text: 'VISUAL'),
                        ],
                      ),
                    ]),
                  ),

                  // ── Feedback ──────────────────────────────
                  if (_feedback != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 7, horizontal: 16),
                      color: _feedbackOk
                          ? const Color(0xFF1B5E20)
                          : const Color(0xFF7F0000),
                      child: Text(_feedback!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none)),
                    ),

                  // ── Conteúdo ──────────────────────────────
                  Expanded(
                    child: TabBarView(
                      controller: _tab,
                      children: [
                        // ── ABA SKINS ─────────────────────────
                        GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.55,
                          ),
                          itemCount: kPlayerSkins.length,
                          itemBuilder: (_, i) {
                            final skin = kPlayerSkins[i];
                            final unlocked = _skinManager.isSkinUnlocked(i);
                            final isEquipped = equippedId == i;
                            final price = _skinPrice(skin);
                            final rarityColor = _rarityColor(skin.rarity);
                            final isDiamond =
                                skin.rarity == SkinRarity.legendary ||
                                    skin.rarity == SkinRarity.mythical ||
                                    skin.rarity == SkinRarity.epic;

                            return GestureDetector(
                              onTap: () => _buySkin(skin),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: isEquipped
                                      ? skin.bodyColor.withValues(alpha: 0.18)
                                      : Colors.white.withValues(alpha: 0.04),
                                  border: Border.all(
                                    color: isEquipped
                                        ? skin.accentColor
                                        : rarityColor.withValues(alpha: 0.3),
                                    width: isEquipped ? 2 : 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(colors: [
                                            skin.bodyColor,
                                            skin.bodyColorDark,
                                          ]),
                                          boxShadow: [
                                            BoxShadow(
                                                color: skin.accentColor
                                                    .withValues(alpha: 0.5),
                                                blurRadius: 6)
                                          ],
                                        ),
                                        child: unlocked
                                            ? null
                                            : const Icon(Icons.lock_rounded,
                                                color: Colors.white54,
                                                size: 14),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(skin.name,
                                              style: TextStyle(
                                                  color: unlocked
                                                      ? Colors.white
                                                      : Colors.white54,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  decoration:
                                                      TextDecoration.none)),
                                          Text(_rarityLabel(skin.rarity),
                                              style: TextStyle(
                                                  color: rarityColor,
                                                  fontSize: 8,
                                                  letterSpacing: 1.5,
                                                  decoration:
                                                      TextDecoration.none)),
                                        ],
                                      )),
                                    ]),
                                    const Spacer(),
                                    Container(
                                      width: double.infinity,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: isEquipped
                                            ? skin.accentColor
                                                .withValues(alpha: 0.25)
                                            : unlocked
                                                ? const Color(0xFF1E3A5F)
                                                : (isDiamond
                                                        ? const Color(
                                                            0xFF00B4D8)
                                                        : const Color(
                                                            0xFFFF9500))
                                                    .withValues(alpha: 0.9),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: isEquipped
                                            ? [
                                                const Icon(Icons.check_rounded,
                                                    color: Colors.white,
                                                    size: 13),
                                                const SizedBox(width: 4),
                                                const Text('EQUIPADA',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        decoration:
                                                            TextDecoration
                                                                .none))
                                              ]
                                            : unlocked
                                                ? [
                                                    const Text('EQUIPAR',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: 9,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            decoration:
                                                                TextDecoration
                                                                    .none))
                                                  ]
                                                : [
                                                    Icon(
                                                        isDiamond
                                                            ? Icons
                                                                .diamond_rounded
                                                            : Icons
                                                                .monetization_on_rounded,
                                                        color: Colors.white,
                                                        size: 12),
                                                    const SizedBox(width: 3),
                                                    Text('$price',
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            decoration:
                                                                TextDecoration
                                                                    .none))
                                                  ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // ── ABA ITENS ─────────────────────────
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(14),
                          child: Column(children: [
                            _ItemTile(
                              icon: '💊',
                              bg: const Color(0xFF1A2A1A),
                              title: 'Pílula de Reviver',
                              subtitle:
                                  'Você tem $revives  •  Próxima: $revivePrice 🪙',
                              coinCost: revivePrice,
                              onBuy: () async {
                                final ok =
                                    await ScoreService.instance.buyRevive();
                                _showFeedback(
                                    ok
                                        ? '✔ Pílula comprada! Próxima custará ${ScoreService.instance.revivePrice} moedas'
                                        : '✘ Precisa de $revivePrice moedas',
                                    ok);
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 10),
                            _ItemTile(
                              icon: '⚡',
                              bg: const Color(0xFF1A3A1A),
                              title: 'Boost Extra',
                              subtitle:
                                  'Você tem ${ScoreService.instance.extraBoosts}',
                              coinCost: 5,
                              onBuy: () async {
                                final ok =
                                    await ScoreService.instance.spendCoins(5);
                                if (ok) {
                                  await ScoreService.instance.addExtraBoosts(1);
                                }
                                _showFeedback(
                                    ok
                                        ? '✔ Boost comprado!'
                                        : '✘ Moedas insuficientes',
                                    ok);
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 10),
                            _ItemTile(
                              icon: '💎',
                              bg: const Color(0xFF001A2A),
                              title: '100 Moedas',
                              subtitle: 'Troca 1 diamante por moedas',
                              diamondCost: 1,
                              onBuy: () async {
                                final ok = await ScoreService.instance
                                    .spendDiamonds(1);
                                if (ok) {
                                  await ScoreService.instance.addCoins(100);
                                }
                                _showFeedback(
                                    ok
                                        ? '✔ +100 moedas!'
                                        : '✘ Diamantes insuficientes',
                                    ok);
                                setState(() {});
                              },
                            ),
                          ]),
                        ),

                        // ── ABA VISUAL ────────────────────────
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel(
                                label: 'TRILHA DE BOOST',
                                icon: Icons.auto_awesome_rounded,
                                color: const Color(0xFFFF9500),
                              ),
                              const SizedBox(height: 10),
                              _ItemTile(
                                icon: '🔥',
                                bg: const Color(0xFF3A1A00),
                                title: 'Trilha de Fogo',
                                subtitle: 'Partículas de fogo ao dar boost',
                                coinCost: 50,
                                onBuy: () async {
                                  final ok = await ScoreService.instance
                                      .spendCoins(50);
                                  _showFeedback(
                                      ok
                                          ? '✔ Trilha de Fogo ativada!'
                                          : '✘ 50 moedas necessárias',
                                      ok);
                                  if (ok) {
                                    await ScoreService.instance
                                        .unlockCosmetic('trail_fire');
                                  }
                                  setState(() {});
                                },
                                locked: ScoreService.instance
                                    .isCosmeticUnlocked('trail_fire'),
                              ),
                              const SizedBox(height: 10),
                              _ItemTile(
                                icon: '❄️',
                                bg: const Color(0xFF001A3A),
                                title: 'Trilha de Gelo',
                                subtitle: 'Partículas geladas ao dar boost',
                                coinCost: 50,
                                onBuy: () async {
                                  final ok = await ScoreService.instance
                                      .spendCoins(50);
                                  _showFeedback(
                                      ok
                                          ? '✔ Trilha de Gelo ativada!'
                                          : '✘ 50 moedas necessárias',
                                      ok);
                                  if (ok) {
                                    await ScoreService.instance
                                        .unlockCosmetic('trail_ice');
                                  }
                                  setState(() {});
                                },
                                locked: ScoreService.instance
                                    .isCosmeticUnlocked('trail_ice'),
                              ),
                              const SizedBox(height: 10),
                              _ItemTile(
                                icon: '⚡',
                                bg: const Color(0xFF1A1A00),
                                title: 'Trilha Elétrica',
                                subtitle: 'Faíscas elétricas ao dar boost',
                                coinCost: 50,
                                onBuy: () async {
                                  final ok = await ScoreService.instance
                                      .spendCoins(50);
                                  _showFeedback(
                                      ok
                                          ? '✔ Trilha Elétrica ativada!'
                                          : '✘ 50 moedas necessárias',
                                      ok);
                                  if (ok) {
                                    await ScoreService.instance
                                        .unlockCosmetic('trail_electric');
                                  }
                                  setState(() {});
                                },
                                locked: ScoreService.instance
                                    .isCosmeticUnlocked('trail_electric'),
                              ),
                              const SizedBox(height: 18),
                              _SectionLabel(
                                label: 'ACESSÓRIOS',
                                icon: Icons.emoji_events_rounded,
                                color: const Color(0xFFFFD600),
                              ),
                              const SizedBox(height: 10),
                              _ItemTile(
                                icon: '👑',
                                bg: const Color(0xFF2A1A00),
                                title: 'Coroa Dourada',
                                subtitle: 'Aparece na cabeça da cobra',
                                diamondCost: 1,
                                onBuy: () async {
                                  final ok = await ScoreService.instance
                                      .spendDiamonds(1);
                                  _showFeedback(
                                      ok
                                          ? '✔ Coroa equipada!'
                                          : '✘ 1 diamante necessário',
                                      ok);
                                  if (ok) {
                                    await ScoreService.instance
                                        .unlockCosmetic('crown');
                                  }
                                  setState(() {});
                                },
                                locked: ScoreService.instance
                                    .isCosmeticUnlocked('crown'),
                              ),
                              const SizedBox(height: 10),
                              _ItemTile(
                                icon: '🎩',
                                bg: const Color(0xFF1A1A1A),
                                title: 'Cartola',
                                subtitle: 'Chapéu elegante na cabeça',
                                coinCost: 80,
                                onBuy: () async {
                                  final ok = await ScoreService.instance
                                      .spendCoins(80);
                                  _showFeedback(
                                      ok
                                          ? '✔ Cartola equipada!'
                                          : '✘ 80 moedas necessárias',
                                      ok);
                                  if (ok) {
                                    await ScoreService.instance
                                        .unlockCosmetic('hat');
                                  }
                                  setState(() {});
                                },
                                locked: ScoreService.instance
                                    .isCosmeticUnlocked('hat'),
                              ),
                              const SizedBox(height: 10),
                              _ItemTile(
                                icon: '😎',
                                bg: const Color(0xFF0A0A0A),
                                title: 'Óculos Escuros',
                                subtitle: 'Fica estilosa com óculos',
                                coinCost: 60,
                                onBuy: () async {
                                  final ok = await ScoreService.instance
                                      .spendCoins(60);
                                  _showFeedback(
                                      ok
                                          ? '✔ Óculos equipados!'
                                          : '✘ 60 moedas necessárias',
                                      ok);
                                  if (ok) {
                                    await ScoreService.instance
                                        .unlockCosmetic('glasses');
                                  }
                                  setState(() {});
                                },
                                locked: ScoreService.instance
                                    .isCosmeticUnlocked('glasses'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  const _Pill({required this.icon, required this.color, required this.value});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color.withValues(alpha: 0.12),
            border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none)),
        ]),
      );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _SectionLabel(
      {required this.label, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                decoration: TextDecoration.none)),
        const SizedBox(width: 8),
        Expanded(
            child: Container(height: 1, color: color.withValues(alpha: 0.2))),
      ]);
}

class _ItemTile extends StatelessWidget {
  final String icon, title, subtitle;
  final Color bg;
  final int coinCost, diamondCost;
  final bool locked;
  final VoidCallback onBuy;
  const _ItemTile({
    required this.icon,
    required this.bg,
    required this.title,
    required this.subtitle,
    this.coinCost = 0,
    this.diamondCost = 0,
    this.locked = false,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final isDiamond = diamondCost > 0;
    final cost = isDiamond ? diamondCost : coinCost;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
      child: Row(children: [
        Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), color: bg),
            child: Center(
                child: Text(icon,
                    style: const TextStyle(
                        fontSize: 22, decoration: TextDecoration.none)))),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none)),
          Text(subtitle,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 11,
                  decoration: TextDecoration.none)),
        ])),
        const SizedBox(width: 10),
        locked
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withValues(alpha: 0.06)),
                child: const Text('OK',
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none)))
            : GestureDetector(
                onTap: onBuy,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                        colors: isDiamond
                            ? [const Color(0xFF00B4D8), const Color(0xFF0077B6)]
                            : [
                                const Color(0xFFFFAA00),
                                const Color(0xFFFF6B00)
                              ]),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                        isDiamond
                            ? Icons.diamond_rounded
                            : Icons.monetization_on_rounded,
                        color: Colors.white,
                        size: 13),
                    const SizedBox(width: 4),
                    Text('$cost',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none)),
                  ]),
                ),
              ),
      ]),
    );
  }
}
