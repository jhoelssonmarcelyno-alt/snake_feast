import 'dart:math';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../game/skins/skin_rarity.dart';
import '../painters/snake_preview_painter.dart';

class SkinGridSelector extends StatefulWidget {
  final int selectedSkin;
  final ValueChanged<int> onSelect;
  final double scale;

  const SkinGridSelector({
    super.key,
    required this.selectedSkin,
    required this.onSelect,
    required this.scale,
  });

  @override
  State<SkinGridSelector> createState() => _SkinGridSelectorState();
}

class _SkinGridSelectorState extends State<SkinGridSelector> {
  int _currentPage = 0;
  final int _itemsPerPage = 30;

  final List<String> _emojiThemes = [
    '🐍', '🐉', '🐲', '🦎', '🐸', '🐢', '🐊', '🐙', '🦑', '🐬',
    '🦈', '🐋', '🐟', '🐠', '🐡', '🦭', '🐧', '🦅', '🦉', '🐺',
    '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮', '🐷', '🐵', '🙈',
  ];

  String _getEmojiByPowerWithVariation(SnakeSkin skin, int skinId) {
    final power = skin.power;
    final variation = skinId % 5;

    if (power <= 30) {
      const emojis = ['🐍', '🐉', '🦎', '🐸', '🐢'];
      return emojis[variation % emojis.length];
    }
    if (power <= 60) {
      const emojis = ['🐲', '🐊', '🐙', '🦑', '🐬'];
      return emojis[variation % emojis.length];
    }
    if (power <= 90) {
      const emojis = ['🦈', '🐋', '🐟', '🐠', '🐡'];
      return emojis[variation % emojis.length];
    }
    if (power <= 120) {
      const emojis = ['🦅', '🦉', '🐺', '🦊', '🐻'];
      return emojis[variation % emojis.length];
    }
    if (power <= 150) {
      const emojis = ['🐼', '🐨', '🐯', '🦁', '🐮'];
      return emojis[variation % emojis.length];
    }
    if (power <= 180) {
      const emojis = ['⚡', '🔥', '💧', '❄️', '💨'];
      return emojis[variation % emojis.length];
    }
    if (power <= 210) {
      const emojis = ['🌊', '🌈', '🌙', '☀️', '🌍'];
      return emojis[variation % emojis.length];
    }
    return '🐉';
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (kPlayerSkins.length / _itemsPerPage).ceil();

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemCount: totalPages,
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * _itemsPerPage;
              final endIndex = (startIndex + _itemsPerPage).clamp(0, kPlayerSkins.length);
              final pageSkins = kPlayerSkins.sublist(startIndex, endIndex);

              return GridView.builder(
                padding: EdgeInsets.all(8 * widget.scale),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 6 * widget.scale,
                  mainAxisSpacing: 6 * widget.scale,
                  childAspectRatio: 0.85,
                ),
                itemCount: pageSkins.length,
                itemBuilder: (context, index) {
                  final skin = pageSkins[index];
                  final globalIndex = startIndex + index;
                  final isSelected = globalIndex == widget.selectedSkin;
                  final isUnlocked = skin.isUnlocked;
                  final rarityColor = skin.rarity.color;

                  return GestureDetector(
                    onTap: () {
                      if (isUnlocked) {
                        widget.onSelect(globalIndex);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Desbloqueie esta skin completando níveis!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: isUnlocked
                            ? LinearGradient(
                                colors: [skin.bodyColor, skin.bodyColorDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [Colors.grey.shade700, Colors.grey.shade900],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(10 * widget.scale),
                        border: Border.all(
                          color: isSelected
                              ? skin.accentColor
                              : rarityColor.withOpacity(0.5),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: skin.accentColor.withOpacity(0.4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isUnlocked)
                            RepaintBoundary(
                              child: CustomPaint(
                                painter: SnakePreviewPainter(
                                  skin: skin,
                                  t: 0,
                                ),
                                size: Size(45 * widget.scale, 28 * widget.scale),
                              ),
                            )
                          else
                            Column(
                              children: [
                                Icon(
                                  Icons.lock,
                                  color: Colors.white70,
                                  size: 24 * widget.scale,
                                ),
                                SizedBox(height: 4 * widget.scale),
                                Text(
                                  '???',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10 * widget.scale,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 4 * widget.scale),
                          Text(
                            isUnlocked ? skin.name : '???',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 8 * widget.scale,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isUnlocked ? 'Poder ${skin.power}' : '???',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 7 * widget.scale,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (i) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 3),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == i
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
