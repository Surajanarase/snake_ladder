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
      return SizedBox(
        width: boardSize,
        height: boardSize,
        child: Stack(
          children: [
            // Grid
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10, crossAxisSpacing: 4, mainAxisSpacing: 4),
              itemCount: 100,
              itemBuilder: (context, index) {
                final cellNumber = 100 - index;
                final isSnakeStart = game.snakes.containsKey(cellNumber);
                final isSnakeEnd = game.snakes.values.any((v) => v['end'] == cellNumber);
                final isLadderStart = game.ladders.containsKey(cellNumber);
                final isLadderEnd = game.ladders.values.any((v) => v['end'] == cellNumber);

                Color bg = Colors.white;
                if (isSnakeStart) bg = Colors.red.shade400;
                if (isSnakeEnd) bg = Colors.red.shade50;
                if (isLadderStart) bg = Colors.green.shade600;
                if (isLadderEnd) bg = Colors.green.shade50;

                return GestureDetector(
                  onTap: () {
                    if (isSnakeStart) _showCellInfo(context, cellNumber, game.snakes[cellNumber]!['message'], game.snakes[cellNumber]!['icon']);
                    if (isLadderStart) _showCellInfo(context, cellNumber, game.ladders[cellNumber]!['message'], game.ladders[cellNumber]!['icon']);
                  },
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: bg),
                    child: Stack(
                      children: [
                        Positioned(top: 4, left: 6, child: Text('$cellNumber', style: TextStyle(fontSize: 10, color: Colors.grey.shade700))),
                        Center(child: Text(isSnakeStart ? '🐍' : isLadderStart ? '🪜' : isSnakeEnd ? '⬇️' : isLadderEnd ? '⬆️' : '', style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Connections painter
            Positioned.fill(child: CustomPaint(painter: _ConnectionsPainter(game))),

            // Tokens - animated positioned based on grid cell size
            Positioned.fill(
              child: LayoutBuilder(builder: (context, box) {
                final cellWidth = box.maxWidth / 10;
                final cellHeight = box.maxHeight / 10;

                Widget tokenFor(int position, bool human) {
                  if (position <= 0 || position > 100) return const SizedBox.shrink();
                  final rc = _cellToRowCol(position);
                  final left = rc['col']! * cellWidth + (cellWidth - 30) / 2;
                  final top = rc['row']! * cellHeight + (cellHeight - 30) / 2;

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    left: left,
                    top: top,
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: human ? const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]) : const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)]),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [BoxShadow(blurRadius: 4, offset: Offset(0, 2), color: Colors.black26)],
                      ),
                      alignment: Alignment.center,
                      child: Text(human ? '👤' : '🤖'),
                    ),
                  );
                }

                return Stack(children: [tokenFor(game.humanPosition, true), tokenFor(game.aiPosition, false)]);
              }),
            ),
          ],
        ),
      );
    });
  }

  void _showCellInfo(BuildContext context, int cellNumber, String message, String icon) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(icon),
          content: Text('$message (Cell $cellNumber)'),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
        );
      },
    );
  }

  // Convert cell number (1..100) to top-based row/col for grid layout
  Map<String, int> _cellToRowCol(int cellNumber) {
    final index = cellNumber - 1;
    final rowFromBottom = index ~/ 10; // 0..9
    final row = 9 - rowFromBottom; // top-based
    final offsetInRow = index % 10;
    final rowIsReversed = rowFromBottom % 2 == 1;
    final col = rowIsReversed ? 9 - offsetInRow : offsetInRow;
    return {'row': row, 'col': col};
  }
}

// Painter draws straight/curved connections from start->end
class _ConnectionsPainter extends CustomPainter {
  final GameService game;
  _ConnectionsPainter(this.game);

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / 10;
    final cellHeight = size.height / 10;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 3;

    // helper to get center of a cell
    Offset centerOf(int cell) {
      final index = cell - 1;
      final rowFromBottom = index ~/ 10;
      final row = 9 - rowFromBottom;
      final offsetInRow = index % 10;
      final rowIsReversed = rowFromBottom % 2 == 1;
      final col = rowIsReversed ? 9 - offsetInRow : offsetInRow;
      final dx = col * cellWidth + cellWidth / 2;
      final dy = row * cellHeight + cellHeight / 2;
      return Offset(dx, dy);
    }

    // Draw snakes
    for (var e in game.snakes.entries) {
      final start = centerOf(e.key);
      final end = centerOf(e.value['end'] as int);
      paint.color = const Color.fromRGBO(244, 67, 54, 0.7);

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
      paint.color = const Color.fromRGBO(76, 175, 80, 0.8);

      final path = Path()..moveTo(start.dx, start.dy)..lineTo(end.dx, end.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionsPainter old) => true;
}
