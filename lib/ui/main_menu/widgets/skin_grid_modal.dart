import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../game/skins/skin_rarity.dart';
import '../painters/snake_preview_painter.dart';

class SkinGridModal extends StatefulWidget {
  final int selectedSkin;
  final ValueChanged<int> onSelect;
  final double scale;

  const SkinGridModal({
    super.key,
    required this.selectedSkin,
    required this.onSelect,
    required this.scale,
  });

  @override
  State<SkinGridModal> createState() => _SkinGridModalState();
}

class _SkinGridModalState extends State<SkinGridModal> {
  int _currentPage = 0;
  final int _itemsPerPage = 20;

  @override
  Widget build(BuildContext context) {
    final totalPages = (kPlayerSkins.length / _itemsPerPage).ceil();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0D1B2A),
                Color(0xFF1B2A3A),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TODAS AS SKINS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16 * widget.scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${kPlayerSkins.length} skins disponíveis',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10 * widget.scale,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(6 * widget.scale),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 18 * widget.scale,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemCount: totalPages,
                  itemBuilder: (context, pageIndex) {
                    final startIndex = pageIndex * _itemsPerPage;
                    final endIndex = (startIndex + _itemsPerPage).clamp(0, kPlayerSkins.length);
                    final pageSkins = kPlayerSkins.sublist(startIndex, endIndex);

                    return GridView.builder(
                      controller: scrollCtrl,
                      padding: EdgeInsets.all(12 * widget.scale),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8 * widget.scale,
                        mainAxisSpacing: 8 * widget.scale,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: pageSkins.length,
                      itemBuilder: (context, index) {
                        final skin = pageSkins[index];
                        final globalIndex = startIndex + index;
                        final isSelected = globalIndex == widget.selectedSkin;
                        final isUnlocked = skin.isUnlocked;

                        return GestureDetector(
                          onTap: () {
                            if (isUnlocked) {
                              widget.onSelect(globalIndex);
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Desbloqueie esta skin completando níveis!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Container(
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
                              borderRadius: BorderRadius.circular(12 * widget.scale),
                              border: Border.all(
                                color: isSelected
                                    ? skin.accentColor
                                    : Colors.white.withOpacity(0.2),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: skin.accentColor.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isUnlocked)
                                  ClipRect(
                                    child: SizedBox(
                                      height: 50 * widget.scale,
                                      child: RepaintBoundary(
                                        child: CustomPaint(
                                          painter: SnakePreviewPainter(
                                            skin: skin,
                                            t: 0,
                                          ),
                                          size: Size(60 * widget.scale, 35 * widget.scale),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Column(
                                    children: [
                                      Icon(
                                        Icons.lock,
                                        color: Colors.white70,
                                        size: 28 * widget.scale,
                                      ),
                                      SizedBox(height: 4 * widget.scale),
                                      Text(
                                        'Bloqueado',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 8 * widget.scale,
                                        ),
                                      ),
                                    ],
                                  ),
                                SizedBox(height: 4 * widget.scale),
                                Text(
                                  isUnlocked 
                                      ? (skin.name.length > 12 ? '${skin.name.substring(0, 10)}...' : skin.name)
                                      : '???',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9 * widget.scale,
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
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalPages, (i) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 6,
                      height: 6,
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
          ),
        );
      },
    );
  }
}
