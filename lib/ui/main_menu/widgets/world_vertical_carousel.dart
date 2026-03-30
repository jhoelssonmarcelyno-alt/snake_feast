import 'package:flutter/material.dart';
import '../models/world_model.dart';
import '../../../services/world_progress_service.dart';
import 'world_progress_bar.dart';

class WorldVerticalCarousel extends StatefulWidget {
  final List<WorldModel> worlds;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final double scale;

  const WorldVerticalCarousel({
    super.key,
    required this.worlds,
    required this.selectedIndex,
    required this.onSelect,
    required this.scale,
  });

  @override
  State<WorldVerticalCarousel> createState() => _WorldVerticalCarouselState();
}

class _WorldVerticalCarouselState extends State<WorldVerticalCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.selectedIndex;
    _pageController = PageController(
      initialPage: widget.selectedIndex,
      viewportFraction: 0.45,
    );
  }

  @override
  void didUpdateWidget(WorldVerticalCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != _currentPage) {
      _currentPage = widget.selectedIndex;
      _pageController.animateToPage(
        widget.selectedIndex,
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
      // Só permite selecionar se o mundo está desbloqueado
      if (WorldProgressService().isWorldUnlocked(page)) {
        widget.onSelect(page);
      } else {
        // Se não estiver desbloqueado, volta para o selecionado anterior
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100 * widget.scale,
      height: 320 * widget.scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Carrossel vertical
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            scrollDirection: Axis.vertical,
            itemCount: widget.worlds.length,
            itemBuilder: (context, index) {
              final world = widget.worlds[index];
              final isCenter = index == _currentPage;
              final isUnlocked = WorldProgressService().isWorldUnlocked(index);
              
              double scale = isCenter ? 1.0 : 0.6;
              
              return GestureDetector(
                onTap: () {
                  // Só permite selecionar se o mundo está desbloqueado
                  if (isUnlocked) {
                    widget.onSelect(index);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(vertical: 4 * widget.scale),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [world.primary, world.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12 * widget.scale * scale),
                    border: Border.all(
                      color: isCenter 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.2),
                      width: isCenter ? 2 : 1,
                    ),
                    boxShadow: isCenter && isUnlocked
                        ? [
                            BoxShadow(
                              color: world.secondary.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Transform.scale(
                    scale: scale,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          world.emoji,
                          style: TextStyle(
                            fontSize: 28 * widget.scale * scale,
                          ),
                        ),
                        SizedBox(height: 4 * widget.scale * scale),
                        Text(
                          '${world.number}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12 * widget.scale * scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isCenter)
                          Padding(
                            padding: EdgeInsets.only(top: 4 * widget.scale),
                            child: Text(
                              world.name.length > 10
                                  ? '${world.name.substring(0, 8)}...'
                                  : world.name,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 8 * widget.scale,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        SizedBox(height: 4 * widget.scale),
                        // Barra de progresso
                        WorldProgressBar(
                          worldIndex: index,
                          scale: widget.scale,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Setas de navegação
          Positioned(
            top: 0,
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
                width: 40 * widget.scale,
                height: 28 * widget.scale,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12 * widget.scale),
                  ),
                ),
                child: Icon(
                  Icons.arrow_upward,
                  color: Colors.white70,
                  size: 16 * widget.scale,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                if (_currentPage < widget.worlds.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Container(
                width: 40 * widget.scale,
                height: 28 * widget.scale,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12 * widget.scale),
                  ),
                ),
                child: Icon(
                  Icons.arrow_downward,
                  color: Colors.white70,
                  size: 16 * widget.scale,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
