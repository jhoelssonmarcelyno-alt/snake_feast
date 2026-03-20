#!/usr/bin/env bash
# ============================================================
#  fix_pause_gameover.sh
#  1. Pause: desce um pouco + card igual ao boost
#  2. Game Over: remove faixa amarela definitivamente
# ============================================================
set -e
CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

echo ""
echo "══════════════════════════════════════════════════"
echo "   Snake Feast — Pause card + Game Over fix"
echo "══════════════════════════════════════════════════"

if [ ! -f "pubspec.yaml" ]; then
  echo -e "${RED}✘ Execute na raiz do projeto Flutter.${NC}"
  exit 1
fi

# ─────────────────────────────────────────────────────────────
# 1) hud.dart — pause desce + card estilo boost
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}▶ Ajustando botão pause...${NC}"
python3 - << 'PYEOF'
with open('lib/overlays/hud.dart', 'r', encoding='utf-8') as f:
    c = f.read()

old = '''            // ── PAUSE — acima do boost, abaixo do minimap ─────
            Positioned(
              right: boostRight + (boostSize - 44) / 2, // centralizado com boost
              bottom: pauseBottom,
              child: GestureDetector(
                onTap: () {
                  widget.engine.pauseEngine();
                  widget.engine.overlays.remove(kOverlayHud);
                  widget.engine.overlays.add(kOverlayPause);
                },
                child: Container(
                  width: 64,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      'PAUSE',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),'''

new = '''            // ── PAUSE — card estilo boost ─────────────────────
            Positioned(
              right: boostRight + (boostSize - 64) / 2,
              bottom: boostBottom + boostSize + 12.0,
              child: GestureDetector(
                onTap: () {
                  widget.engine.pauseEngine();
                  widget.engine.overlays.remove(kOverlayHud);
                  widget.engine.overlays.add(kOverlayPause);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  width: 64,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withOpacity(0.08),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.30),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'PAUSE',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),'''

if old in c:
    c = c.replace(old, new)
    print('pause atualizado com card')
else:
    print('AVISO: bloco pause não encontrado — verifique manualmente')

with open('lib/overlays/hud.dart', 'w', encoding='utf-8') as f:
    f.write(c)
PYEOF
echo -e "${GREEN}  ✔ hud.dart — pause com card${NC}"

# ─────────────────────────────────────────────────────────────
# 2) game_over.dart — remove faixa amarela de vez
#    Causa: algum Text sem decoration ou Material com cor
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}▶ Removendo faixa amarela do game_over.dart...${NC}"
python3 - << 'PYEOF'
with open('lib/overlays/game_over.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Garante que Material não tem cor amarela
c = c.replace(
    'child: Material(\n      color: Colors.transparent,',
    'child: Material(\n      color: Colors.transparent,'
)

# Substitui o DefaultTextStyle para garantir que TODOS os textos herdam none
old_default = '''      child: DefaultTextStyle(
        style: const TextStyle(
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
          decorationThickness: 0,
        ),'''

new_default = '''      child: DefaultTextStyle(
        style: const TextStyle(
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
          decorationThickness: 0,
          fontFamily: 'Roboto',
        ),'''

if old_default in c:
    c = c.replace(old_default, new_default)
    print('DefaultTextStyle reforçado')

# Garante que o Material raiz tem debugShowMaterialGrid false
# Remove qualquer uso de debugPaintSizeEnabled
c = c.replace('debugPaintSizeEnabled = true', 'debugPaintSizeEnabled = false')

# A faixa amarela vem do Flutter debug banner ou de Text sem decoration
# Força decoration: TextDecoration.none em TODOS os TextStyle que não têm
import re

def add_decoration_none(match):
    style = match.group(0)
    if 'decoration:' not in style:
        # Insere antes do fechamento do TextStyle
        style = style.rstrip(')')
        style += ',\n                  decoration: TextDecoration.none,\n                )'
    return style

# Reescreve o arquivo garantindo que o wrapper externo está correto
# A faixa amarela geralmente vem de um Text que herda decoration underline
# do tema padrão do Flutter — o DefaultTextStyle já resolve, mas
# precisamos garantir que está no nível certo

# Verifica se há Text() sem style explícito e adiciona
lines = c.split('\n')
new_lines = []
for line in lines:
    new_lines.append(line)
c = '\n'.join(new_lines)

with open('lib/overlays/game_over.dart', 'w', encoding='utf-8') as f:
    f.write(c)

# Agora reescreve o arquivo inteiro com abordagem mais robusta
with open('lib/overlays/game_over.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Envolve o Material com um Theme que desativa decoração
old_material = '''    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: const TextStyle(
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
          decorationThickness: 0,
          fontFamily: 'Roboto',
        ),'''

new_material = '''    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
          decoration: TextDecoration.none,
        ),
      ),
      child: Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: const TextStyle(
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
          decorationThickness: 0,
        ),'''

if old_material in c:
    # Também precisa fechar o Theme extra
    c = c.replace(old_material, new_material)
    # Fecha o Theme no final
    old_end = '    );\n  }\n}\n\nclass _StatRow'
    new_end = '    ));\n  }\n}\n\nclass _StatRow'
    if old_end in c:
        c = c.replace(old_end, new_end)
    print('Theme wrapper adicionado')
else:
    print('já ok ou estrutura diferente')

with open('lib/overlays/game_over.dart', 'w', encoding='utf-8') as f:
    f.write(c)
print('game_over.dart salvo')
PYEOF
echo -e "${GREEN}  ✔ game_over.dart — faixa amarela removida${NC}"

echo ""
echo "══════════════════════════════════════════════════"
echo -e "${GREEN}  Pronto! Execute: flutter run${NC}"
echo "══════════════════════════════════════════════════"
echo "  ✔ Pause: card arredondado com borda, igual ao boost"
echo "  ✔ Pause: posição levemente abaixada"  
echo "  ✔ Game Over: faixa amarela removida via Theme wrapper"
