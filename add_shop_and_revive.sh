#!/usr/bin/env bash
# ============================================================
#  add_shop_and_revive.sh
#  1. Loja no menu (moedas + diamantes)
#  2. Overlay de reviver ao morrer (10 moedas, até 3x)
# ============================================================
set -e
CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

echo ""
echo "══════════════════════════════════════════════════"
echo "   Snake Feast — Loja + Sistema de Reviver"
echo "══════════════════════════════════════════════════"

if [ ! -f "pubspec.yaml" ]; then
  echo -e "${RED}✘ Execute na raiz do projeto Flutter.${NC}"
  exit 1
fi

# ─────────────────────────────────────────────────────────────
# 1) constants.dart — adiciona overlays e prefs
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}▶ Adicionando constantes...${NC}"
python3 - << 'PYEOF'
with open('lib/utils/constants.dart', 'r', encoding='utf-8') as f:
    c = f.read()

adds = [
    ("const String kOverlayPause = 'Pause';",
     "const String kOverlayPause = 'Pause';\nconst String kOverlayShop = 'Shop';\nconst String kOverlayRevive = 'Revive';"),
    ("const String kPrefSelectedSkin = 'selected_skin';",
     "const String kPrefSelectedSkin = 'selected_skin';\nconst String kPrefBoostCount = 'boost_count';"),
]
for old, new in adds:
    if old in c and new.split('\n')[1] not in c:
        c = c.replace(old, new)
        print(f'  adicionado: {new.split(chr(10))[1].strip()}')

with open('lib/utils/constants.dart', 'w', encoding='utf-8') as f:
    f.write(c)
print('constants.dart atualizado')
PYEOF
echo -e "${GREEN}  ✔ constants.dart${NC}"

# ─────────────────────────────────────────────────────────────
# 2) score_service.dart — adiciona boosts e itens de loja
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}▶ Atualizando score_service.dart...${NC}"
python3 - << 'PYEOF'
with open('lib/services/score_service.dart', 'r', encoding='utf-8') as f:
    c = f.read()

extra = '''
  // ─── Boost extra (comprado na loja) ──────────────────────────
  int get extraBoosts => _prefs.getInt('extra_boosts') ?? 0;

  Future<void> addExtraBoosts(int amount) async {
    await _prefs.setInt('extra_boosts', extraBoosts + amount);
  }

  Future<bool> spendExtraBoost() async {
    if (extraBoosts <= 0) return false;
    await _prefs.setInt('extra_boosts', extraBoosts - 1);
    return true;
  }

  // ─── Skin desbloqueada via loja ───────────────────────────────
  List<String> get unlockedSkins {
    return _prefs.getStringList('unlocked_skins') ?? ['classic'];
  }

  Future<void> unlockSkin(String id) async {
    final list = unlockedSkins;
    if (!list.contains(id)) {
      list.add(id);
      await _prefs.setStringList('unlocked_skins', list);
    }
  }

  bool isSkinUnlocked(String id) {
    if (id == 'classic') return true; // grátis
    return unlockedSkins.contains(id);
  }

  // ─── Gastar moedas ────────────────────────────────────────────
  Future<bool> spendCoins(int amount) async {
    if (coins < amount) return false;
    await _prefs.setInt('coins', coins - amount);
    return true;
  }

  // ─── Gastar diamantes ─────────────────────────────────────────
  Future<bool> spendDiamonds(int amount) async {
    if (diamonds < amount) return false;
    await _prefs.setInt('diamonds', diamonds - amount);
    return true;
  }
'''

if 'spendCoins' not in c:
    # insere antes do último }
    c = c.rstrip()
    if c.endswith('}'):
        c = c[:-1] + extra + '\n}\n'
    with open('lib/services/score_service.dart', 'w', encoding='utf-8') as f:
        f.write(c)
    print('score_service.dart atualizado')
else:
    print('score_service.dart já tem spendCoins')
PYEOF
echo -e "${GREEN}  ✔ score_service.dart${NC}"

# ─────────────────────────────────────────────────────────────
# 3) shop_overlay.dart — tela da loja
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}▶ Criando lib/overlays/shop_overlay.dart...${NC}"
cat > "lib/overlays/shop_overlay.dart" << 'DART'
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
DART
echo -e "${GREEN}  ✔ shop_overlay.dart${NC}"

# ─────────────────────────────────────────────────────────────
# 4) revive_overlay.dart — tela de reviver
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}▶ Criando lib/overlays/revive_overlay.dart...${NC}"
cat > "lib/overlays/revive_overlay.dart" << 'DART'
// lib/overlays/revive_overlay.dart
// Aparece ao morrer — oferece reviver por 10 moedas (até 3x por partida)
import 'package:flutter/material.dart';
import '../game/snake_engine.dart';
import '../services/score_service.dart';
import '../utils/constants.dart';

class ReviveOverlay extends StatefulWidget {
  final SnakeEngine engine;
  const ReviveOverlay({super.key, required this.engine});

  @override
  State<ReviveOverlay> createState() => _ReviveOverlayState();
}

class _ReviveOverlayState extends State<ReviveOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  // Contador regressivo de 10s para aceitar automaticamente
  int _seconds = 10;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = 10; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _seconds = i);
      if (i == 0) _decline();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _revive() async {
    if (_busy) return;
    setState(() => _busy = true);

    final ok = await ScoreService.instance.spendCoins(10);
    if (!mounted) return;

    if (ok) {
      widget.engine.revivePlayer();
    } else {
      // sem moedas → vai pro game over
      _decline();
    }
  }

  void _decline() {
    if (!mounted) return;
    widget.engine.overlays.remove(kOverlayRevive);
    widget.engine.overlays.add(kOverlayGameOver);
  }

  @override
  Widget build(BuildContext context) {
    final coins = ScoreService.instance.coins;
    final canAfford = coins >= 10;
    final revivesLeft = widget.engine.revivesUsed;

    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: const TextStyle(
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
          decorationThickness: 0,
        ),
        child: Container(
          color: Colors.black.withOpacity(0.78),
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: const Color(0xFF0D1B2A),
                    border: Border.all(
                        color: const Color(0xFF2ECC71).withOpacity(0.4),
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2ECC71).withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícone coração
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2ECC71).withOpacity(0.12),
                              border: Border.all(
                                  color: const Color(0xFF2ECC71)
                                      .withOpacity(0.5)),
                            ),
                          ),
                          const Icon(Icons.favorite_rounded,
                              color: Color(0xFF2ECC71), size: 30),
                        ],
                      ),
                      const SizedBox(height: 14),

                      const Text(
                        'CONTINUAR?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 4,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Reviver custa 10 moedas',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tentativas restantes: ${3 - revivesLeft}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 11,
                          decoration: TextDecoration.none,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Contador + moedas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Contador regressivo circular
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: _seconds / 10.0,
                                  strokeWidth: 3,
                                  color: const Color(0xFF2ECC71),
                                  backgroundColor:
                                      Colors.white.withOpacity(0.1),
                                ),
                                Text(
                                  '$_seconds',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Saldo
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFFFD600).withOpacity(0.1),
                              border: Border.all(
                                  color:
                                      const Color(0xFFFFD600).withOpacity(0.3)),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.monetization_on_rounded,
                                      color: Color(0xFFFFD600), size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$coins',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD600),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ]),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Botão reviver
                      GestureDetector(
                        onTap: canAfford && !_busy ? _revive : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: canAfford
                                ? const LinearGradient(
                                    colors: [
                                        Color(0xFF2ECC71),
                                        Color(0xFF27AE60)
                                      ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight)
                                : null,
                            color: canAfford
                                ? null
                                : Colors.white.withOpacity(0.06),
                            boxShadow: canAfford
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF2ECC71)
                                          .withOpacity(0.4),
                                      blurRadius: 16,
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_rounded,
                                  color: canAfford
                                      ? Colors.white
                                      : Colors.white30,
                                  size: 18),
                              const SizedBox(width: 8),
                              Text(
                                canAfford
                                    ? 'REVIVER  -10 🪙'
                                    : 'MOEDAS INSUFICIENTES',
                                style: TextStyle(
                                  color: canAfford
                                      ? Colors.white
                                      : Colors.white30,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Botão recusar
                      GestureDetector(
                        onTap: _decline,
                        child: Container(
                          width: double.infinity,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.15)),
                          ),
                          child: Center(
                            child: Text(
                              'DESISTIR',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                decoration: TextDecoration.none,
                              ),
                            ),
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
    );
  }
}
DART
echo -e "${GREEN}  ✔ revive_overlay.dart${NC}"

# ─────────────────────────────────────────────────────────────
# 5) score_service.dart — adiciona revives
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}▶ Adicionando revives ao score_service.dart...${NC}"
python3 - << 'PYEOF'
with open('lib/services/score_service.dart', 'r', encoding='utf-8') as f:
    c = f.read()

if 'revives' not in c:
    extra = '''
  // ─── Revives comprados (persistidos) ─────────────────────────
  int get revives => _prefs.getInt('revives') ?? 0;

  Future<void> setRevives(int v) async {
    await _prefs.setInt('revives', v);
  }
'''
    c = c.rstrip()
    if c.endswith('}'):
        c = c[:-1] + extra + '\n}\n'
    print('revives adicionado')
else:
    print('revives já existe')

with open('lib/services/score_service.dart', 'w', encoding='utf-8') as f:
    f.write(c)
PYEOF
echo -e "${GREEN}  ✔ score_service.dart — revives${NC}"

# ─────────────────────────────────────────────────────────────
# 6) snake_engine.dart — revivesUsed + revivePlayer()
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}▶ Adicionando revivePlayer() ao snake_engine.dart...${NC}"
python3 - << 'PYEOF'
with open('lib/game/snake_engine.dart', 'r', encoding='utf-8') as f:
    c = f.read()

if 'revivesUsed' not in c:
    # Adiciona campo após 'final Random rng'
    c = c.replace(
        'final Random rng = Random();',
        'final Random rng = Random();\n\n  // ─── Sistema de reviver ─────────────────────────────────\n  int revivesUsed = 0;\n  static const int kMaxRevives = 3;'
    )
    print('revivesUsed adicionado')

if 'revivePlayer' not in c:
    revive_method = '''
  /// Revive o player no centro do mapa com segmentos iniciais.
  void revivePlayer() {
    revivesUsed++;
    player.revive(worldSize / 2);
    overlays.remove(kOverlayRevive);
    overlays.add(kOverlayHud);
    resumeEngine();
  }
'''
    # Insere antes de handlePlayerDeath
    c = c.replace(
        '  void handlePlayerDeath()',
        revive_method + '  void handlePlayerDeath()'
    )
    print('revivePlayer() adicionado')

# Modifica handlePlayerDeath para mostrar revive se possível
old_death = '''  void handlePlayerDeath() {
    if (!player.isAlive) return;
    player.die();
    ScoreService.instance.submitScore(player.score);
    overlays.remove(kOverlayHud);
    overlays.add(kOverlayGameOver);
  }'''

new_death = '''  void handlePlayerDeath() {
    if (!player.isAlive) return;
    player.die();
    ScoreService.instance.submitScore(player.score);
    overlays.remove(kOverlayHud);
    // Oferece reviver se ainda tem tentativas
    if (revivesUsed < kMaxRevives) {
      overlays.add(kOverlayRevive);
    } else {
      overlays.add(kOverlayGameOver);
    }
  }'''

if old_death in c:
    c = c.replace(old_death, new_death)
    print('handlePlayerDeath atualizado')
else:
    print('AVISO: handlePlayerDeath não encontrado — verifique')

# Reset revivesUsed no startGame
old_start = '  void startGame() {\n    ScoreService.instance.resetRewardsFlag();'
new_start = '  void startGame() {\n    ScoreService.instance.resetRewardsFlag();\n    revivesUsed = 0;'
if old_start in c:
    c = c.replace(old_start, new_start)
    print('revivesUsed resetado no startGame')

with open('lib/game/snake_engine.dart', 'w', encoding='utf-8') as f:
    f.write(c)
print('snake_engine.dart atualizado')
PYEOF
echo -e "${GREEN}  ✔ snake_engine.dart${NC}"

# ─────────────────────────────────────────────────────────────
# 7) snake_player.dart — adiciona revive()
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}▶ Adicionando revive() ao snake_player.dart...${NC}"
python3 - << 'PYEOF'
with open('lib/components/snake_player.dart', 'r', encoding='utf-8') as f:
    c = f.read()

if 'void revive(' not in c:
    revive = '''
  /// Revive o player na posição dada.
  void revive(Vector2 pos) {
    _segments.clear();
    _direction = _targetDirection = Vector2(1, 0);
    // Mantém score e foodEaten — não reseta
    _isBoosting = false;
    _boostDrainAccum = 0;
    _tongueTimer = 0;
    _isAlive = true;
    for (int i = 0; i < kPlayerInitialSegments + 4; i++) {
      _segments.add(pos - Vector2(kPlayerSegmentSpacing * i, 0));
    }
  }
'''
    c = c.replace(
        '  void die() {',
        revive + '  void die() {'
    )
    print('revive() adicionado')
else:
    print('revive() já existe')

with open('lib/components/snake_player.dart', 'w', encoding='utf-8') as f:
    f.write(c)
PYEOF
echo -e "${GREEN}  ✔ snake_player.dart${NC}"

# ─────────────────────────────────────────────────────────────
# 8) main.dart — registra ShopOverlay e ReviveOverlay
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}▶ Registrando overlays no main.dart...${NC}"
python3 - << 'PYEOF'
with open('lib/main.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Imports
for imp in [
    "import 'overlays/shop_overlay.dart';",
    "import 'overlays/revive_overlay.dart';",
]:
    if imp not in c:
        c = c.replace(
            "import 'overlays/pause_overlay.dart';",
            f"import 'overlays/pause_overlay.dart';\n{imp}"
        )
        print(f'import adicionado: {imp}')

# Overlays
if 'kOverlayShop' not in c:
    c = c.replace(
        "kOverlayPause: (context, game) => PauseOverlay(engine: game),",
        "kOverlayPause: (context, game) => PauseOverlay(engine: game),\n        kOverlayShop: (context, game) => ShopOverlay(engine: game),\n        kOverlayRevive: (context, game) => ReviveOverlay(engine: game),"
    )
    print('Shop e Revive registrados')

with open('lib/main.dart', 'w', encoding='utf-8') as f:
    f.write(c)
print('main.dart atualizado')
PYEOF
echo -e "${GREEN}  ✔ main.dart${NC}"

# ─────────────────────────────────────────────────────────────
# 9) main_menu.dart — botão loja ao lado do config
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}▶ Adicionando botão loja no menu...${NC}"
python3 - << 'PYEOF'
with open('lib/ui/main_menu/main_menu.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Adiciona método abrir loja
if '_openShop' not in c:
    c = c.replace(
        '  void _openSettings() => widget.engine.overlays.add(kOverlaySettings);',
        '  void _openSettings() => widget.engine.overlays.add(kOverlaySettings);\n  void _openShop() => widget.engine.overlays.add(kOverlayShop);'
    )
    print('_openShop adicionado')

# Adiciona botão loja ao lado do config
old_btn = '''            // ── Botão ⚙ ──────────────────────────────────────
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 12),
                  child: FadeTransition(
                    opacity: _btnFade,
                    child: GlowIconButton(
                      onTap: _openSettings,
                      color: const Color(0xFF29CFFF),
                      icon: Icons.settings_rounded,
                    ),
                  ),
                ),
              ),
            ),'''

new_btn = '''            // ── Botões topo direito ──────────────────────────
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 12),
                  child: FadeTransition(
                    opacity: _btnFade,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      GlowIconButton(
                        onTap: _openShop,
                        color: const Color(0xFFFFD600),
                        icon: Icons.store_rounded,
                      ),
                      const SizedBox(width: 8),
                      GlowIconButton(
                        onTap: _openSettings,
                        color: const Color(0xFF29CFFF),
                        icon: Icons.settings_rounded,
                      ),
                    ]),
                  ),
                ),
              ),
            ),'''

if old_btn in c:
    c = c.replace(old_btn, new_btn)
    print('botão loja adicionado')
else:
    print('AVISO: bloco do botão config não encontrado')

with open('lib/ui/main_menu/main_menu.dart', 'w', encoding='utf-8') as f:
    f.write(c)
PYEOF
echo -e "${GREEN}  ✔ main_menu.dart — botão loja adicionado${NC}"

echo ""
echo "══════════════════════════════════════════════════"
echo -e "${GREEN}  Loja + Reviver criados com sucesso!${NC}"
echo "══════════════════════════════════════════════════"
echo ""
echo "  LOJA (botão 🛒 no menu):"
echo "  • Boost Extra — 5 moedas"
echo "  • Reviver x1 — 10 moedas"
echo "  • Skin HOT — 30 moedas"
echo "  • Skin ALIEN — 30 moedas"
echo "  • Skin PIRANHA — 1 diamante"
echo "  • Skin SERPENTE — 2 diamantes"
echo "  • 100 Moedas — 1 diamante"
echo ""
echo "  REVIVER:"
echo "  • Ao morrer aparece tela de reviver"
echo "  • Custa 10 moedas"
echo "  • Máximo 3 vezes por partida"
echo "  • Contador regressivo de 10s"
echo "  • Score e comidas são mantidos"
echo ""
echo "Execute: flutter run"
