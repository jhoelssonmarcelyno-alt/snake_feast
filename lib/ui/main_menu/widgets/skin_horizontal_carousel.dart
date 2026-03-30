import 'dart:math';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../painters/snake_preview_painter.dart';

class SkinHorizontalCarousel extends StatefulWidget {
  final int selectedSkin;
  final ValueChanged<int> onSelect;
  final double scale;
  final AnimationController snakeCtrl;

  const SkinHorizontalCarousel({
    super.key,
    required this.selectedSkin,
    required this.onSelect,
    required this.scale,
    required this.snakeCtrl,
  });

  @override
  State<SkinHorizontalCarousel> createState() => _SkinHorizontalCarouselState();
}

class _SkinHorizontalCarouselState extends State<SkinHorizontalCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.selectedSkin;
    _pageController = PageController(
      initialPage: widget.selectedSkin,
      viewportFraction: 0.5,
    );
  }

  @override
  void didUpdateWidget(SkinHorizontalCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedSkin != _currentPage) {
      _currentPage = widget.selectedSkin;
      _pageController.animateToPage(
        widget.selectedSkin,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    if (page != _currentPage) {
      _currentPage = page;
      widget.onSelect(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90 * widget.scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            scrollDirection: Axis.horizontal,
            itemCount: kPlayerSkins.length,
            itemBuilder: (context, index) {
              final skin = kPlayerSkins[index];
              final isCenter = index == _currentPage;
              final isUnlocked = skin.isUnlocked;

              if (!isUnlocked) {
                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Desbloqueie esta skin completando níveis!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: 4 * widget.scale),
                    width: 130 * widget.scale * 0.85,
                    height: 80 * widget.scale * 0.85,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade700, Colors.grey.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12 * widget.scale * 0.85),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, color: Colors.white70, size: 24 * widget.scale),
                          SizedBox(height: 4 * widget.scale),
                          Text(
                            'Bloqueado',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10 * widget.scale,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return GestureDetector(
                onTap: () {
                  widget.onSelect(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: 4 * widget.scale),
                  width: 130 * widget.scale,
                  height: 80 * widget.scale,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [skin.bodyColor, skin.bodyColorDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12 * widget.scale),
                    border: Border.all(
                      color: isCenter
                          ? skin.accentColor
                          : Colors.white.withOpacity(0.2),
                      width: isCenter ? 2 : 1,
                    ),
                    boxShadow: isCenter
                        ? [
                            BoxShadow(
                              color: skin.accentColor.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: widget.snakeCtrl,
                        builder: (_, __) => CustomPaint(
                          painter: SnakePreviewPainter(
                            skin: skin,
                            t: widget.snakeCtrl.value * pi * 2,
                          ),
                          size: Size(80 * widget.scale, 45 * widget.scale),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () {
                if (_currentPage > 0) {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Container(
                width: 28 * widget.scale,
                height: 28 * widget.scale,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white24,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.chevron_left,
                  color: Colors.white70,
                  size: 18 * widget.scale,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: () {
                if (_currentPage < kPlayerSkins.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Container(
                width: 28 * widget.scale,
                height: 28 * widget.scale,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white24,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white70,
                  size: 18 * widget.scale,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
