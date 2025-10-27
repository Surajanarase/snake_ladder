// lib/widgets/board_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';

class BoardWidget extends StatefulWidget {
  const BoardWidget({super.key});

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameService>(context);
    return LayoutBuilder(builder: (context, constraints) {
      final boardSize = constraints.maxWidth;
      return Container(
        width: boardSize,
        height: boardSize,
        decoration: BoxDecoration(
          color: const Color(0xFFf8f9fa),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFe0e0e0),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(2),
          child: Stack(
            children: [
              // Grid
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: 100,
                itemBuilder: (context, index) {
                  // Calculate cell number in snake pattern (bottom to top)
                  final row = index ~/ 10;
                  final col = index % 10;
                  final rowFromBottom = 9 - row;
                  final actualCol = rowFromBottom % 2 == 1 ? 9 - col : col;
                  final cellNumber = rowFromBottom * 10 + actualCol + 1;

                  final isSnakeStart = game.snakes.containsKey(cellNumber);
                  final isSnakeEnd = game.snakes.values.any((v) => v['end'] == cellNumber);
                  final isLadderStart = game.ladders.containsKey(cellNumber);
                  final isLadderEnd = game.ladders.values.any((v) => v['end'] == cellNumber);

                  Color bg = Colors.white;
                  BoxBorder? border;
                  List<BoxShadow>? shadows;
                  
                  if (isSnakeStart) {
                    bg = const Color(0xFFf44336);
                    shadows = [
                      BoxShadow(
                        color: const Color(0xFFf44336).withValues(alpha: 0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      )
                    ];
                  } else if (isSnakeEnd) {
                    bg = const Color(0xFFFFEBEE);
                    border = Border.all(color: const Color(0xFFf44336), width: 2);
                  } else if (isLadderStart) {
                    bg = const Color(0xFF4CAF50);
                    shadows = [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      )
                    ];
                  } else if (isLadderEnd) {
                    bg = const Color(0xFFE8F5E9);
                    border = Border.all(color: const Color(0xFF4CAF50), width: 2);
                  }

                  return GestureDetector(
                    onTap: () {
                      if (isSnakeStart) {
                        _showCellInfo(
                          context,
                          cellNumber,
                          game.snakes[cellNumber]!['message'],
                          game.snakes[cellNumber]!['icon'],
                          'snake',
                          game.snakes[cellNumber]!['end'],
                        );
                      }
                      if (isLadderStart) {
                        _showCellInfo(
                          context,
                          cellNumber,
                          game.ladders[cellNumber]!['message'],
                          game.ladders[cellNumber]!['icon'],
                          'ladder',
                          game.ladders[cellNumber]!['end'],
                          tip: game.ladders[cellNumber]!['tip'],
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: bg,
                        border: border,
                        boxShadow: shadows,
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 2,
                            left: 2,
                            child: Text(
                              '$cellNumber',
                              style: TextStyle(
                                fontSize: 9,
                                color: isSnakeStart || isLadderStart
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              isSnakeStart
                                  ? '🐍'
                                  : isLadderStart
                                      ? '🪜'
                                      : isSnakeEnd
                                          ? '⬇️'
                                          : isLadderEnd
                                              ? '⬆️'
                                              : '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Connections painter
              Positioned.fill(
                child: CustomPaint(
                  painter: _ConnectionsPainter(game),
                ),
              ),

              // Tokens - animated positioned based on grid cell size
              Positioned.fill(
                child: LayoutBuilder(builder: (context, box) {
                  final cellWidth = (box.maxWidth - 2) / 10;
                  final cellHeight = (box.maxHeight - 2) / 10;

                  Widget tokenFor(int position, bool human) {
                    if (position <= 0 || position > 100) {
                      return const SizedBox.shrink();
                    }
                    final rc = _cellToRowCol(position);
                    final left = 2 + rc['col']! * cellWidth + (cellWidth - 25) / 2;
                    final top = 2 + rc['row']! * cellHeight + (cellHeight - 25) / 2;

                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      left: left,
                      top: top,
                      width: 25,
                      height: 25,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: human
                              ? const LinearGradient(
                                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)])
                              : const LinearGradient(
                                  colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)]),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 5,
                              offset: Offset(0, 2),
                              color: Colors.black26,
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          human ? '👤' : '🤖',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      tokenFor(game.humanPosition, true),
                      tokenFor(game.aiPosition, false),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showCellInfo(
    BuildContext context,
    int cellNumber,
    String message,
    String icon,
    String type,
    int endCell, {
    String? tip,
  }) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  type == 'snake' ? 'Health Warning!' : 'Health Boost!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$message ${tip ?? ''} This will ${type == 'snake' ? 'move you back' : 'advance you'} to square $endCell${type == 'snake' ? '.' : '!'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Got it!'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Convert cell number (1..100) to row/col for grid layout
  Map<String, int> _cellToRowCol(int cellNumber) {
    final index = cellNumber - 1;
    final rowFromBottom = index ~/ 10;
    final row = 9 - rowFromBottom;
    final offsetInRow = index % 10;
    final rowIsReversed = rowFromBottom % 2 == 1;
    final col = rowIsReversed ? 9 - offsetInRow : offsetInRow;
    return {'row': row, 'col': col};
  }
}

// Painter draws connections from start->end
class _ConnectionsPainter extends CustomPainter {
  final GameService game;
  _ConnectionsPainter(this.game);

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = (size.width - 2) / 10;
    final cellHeight = (size.height - 2) / 10;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Helper to get center of a cell
    Offset centerOf(int cell) {
      final index = cell - 1;
      final rowFromBottom = index ~/ 10;
      final row = 9 - rowFromBottom;
      final offsetInRow = index % 10;
      final rowIsReversed = rowFromBottom % 2 == 1;
      final col = rowIsReversed ? 9 - offsetInRow : offsetInRow;
      final dx = 2 + col * cellWidth + cellWidth / 2;
      final dy = 2 + row * cellHeight + cellHeight / 2;
      return Offset(dx, dy);
    }

    // Draw snakes with curved paths
    for (var e in game.snakes.entries) {
      final start = centerOf(e.key);
      final end = centerOf(e.value['end'] as int);
      paint.color = const Color(0xFFf44336).withValues(alpha: 0.6);

      final path = Path();
      final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
      path.moveTo(start.dx, start.dy);
      path.quadraticBezierTo(mid.dx + 20, mid.dy, end.dx, end.dy);
      canvas.drawPath(path, paint);
    }

    // Draw ladders as straight lines
    for (var e in game.ladders.entries) {
      final start = centerOf(e.key);
      final end = centerOf(e.value['end'] as int);
      paint.color = const Color(0xFF4CAF50).withValues(alpha: 0.6);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(end.dx, end.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionsPainter old) => true;
}