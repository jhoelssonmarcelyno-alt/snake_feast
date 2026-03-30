import 'package:flutter/material.dart';
import '../models/world_model.dart';
import '../../../utils/constants.dart';

class WorldGridSelector extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final double scale;

  const WorldGridSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.scale,
  });

  @override
  State<WorldGridSelector> createState() => _WorldGridSelectorState();
}

class _WorldGridSelectorState extends State<WorldGridSelector> {
  int _currentPage = 0;
  final int _itemsPerPage = 20;

  @override
  Widget build(BuildContext context) {
    final totalPages = (kWorlds.length / _itemsPerPage).ceil();

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
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Título
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TODOS OS MUNDOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16 * widget.scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${kWorlds.length} mundos disponíveis',
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
              const Divider(color: Colors.white24, height: 1),
              // Grid
              Expanded(
                child: GridView.builder(
                  controller: scrollCtrl,
                  padding: EdgeInsets.all(12 * widget.scale),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8 * widget.scale,
                    mainAxisSpacing: 8 * widget.scale,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _getCurrentPageItems().length,
                  itemBuilder: (context, index) {
                    final world = _getCurrentPageItems()[index];
                    final worldIndex = kWorlds.indexOf(world);
                    final isSelected = worldIndex == widget.selectedIndex;

                    return GestureDetector(
                      onTap: () {
                        widget.onSelect(worldIndex);
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [world.primary, world.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12 * widget.scale),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.white24,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: world.secondary.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    world.emoji,
                                    style: TextStyle(
                                      fontSize: 28 * widget.scale,
                                    ),
                                  ),
                                  SizedBox(height: 6 * widget.scale),
                                  Text(
                                    '${world.number}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12 * widget.scale,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2 * widget.scale),
                                  Text(
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
                                ],
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 4 * widget.scale,
                                right: 4 * widget.scale,
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 16 * widget.scale,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Paginação
              if (totalPages > 1)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12 * widget.scale),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, size: 20 * widget.scale),
                        onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                        color: Colors.white70,
                      ),
                      Text(
                        '${_currentPage + 1} / $totalPages',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12 * widget.scale,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, size: 20 * widget.scale),
                        onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<WorldModel> _getCurrentPageItems() {
    final start = _currentPage * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, kWorlds.length);
    return kWorlds.sublist(start, end);
  }
}
