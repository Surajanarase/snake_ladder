// lib/widgets/board_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import 'dart:math' as math;

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
      // Make board perfectly square and fit in available space
      final availableWidth = constraints.maxWidth;
      final availableHeight = MediaQuery.of(context).size.height * 0.55;
      final boardSize = math.min(availableWidth, availableHeight);

      return Center(
        child: Container(
          width: boardSize,
          height: boardSize,
          decoration: BoxDecoration(
            // Brown wooden frame like in the reference image
            color: const Color(0xFF8B6F47),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 10),
              )
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              // Light cream/beige background
              color: const Color(0xFFF5F5DC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF654321), width: 2),
            ),
            padding: const EdgeInsets.all(6),
            child: _buildBoardContents(boardSize, game),
          ),
        ),
      );
    });
  }

  Widget _buildBoardContents(double boardSize, GameService game) {
    return Stack(
      children: [
        // Grid of cells
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 10,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          itemCount: 100,
          itemBuilder: (context, index) {
            final row = index ~/ 10;
            final col = index % 10;
            final rowFromBottom = 9 - row;
            final isRowReversed = rowFromBottom % 2 == 1;
            final actualCol = isRowReversed ? 9 - col : col;
            final cellNumber = rowFromBottom * 10 + actualCol + 1;

            // Light gray cells with subtle alternation
            const Color lightCell = Color(0xFFFFFFFF);
            const Color altCell = Color(0xFFF8F8F8);
            final bool isAlt = (row + col) % 2 == 0;
            final Color bg = isAlt ? altCell : lightCell;

            return Container(
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(
                  color: const Color(0xFFDDDDDD),
                  width: 0.5,
                ),
              ),
              child: Stack(
                children: [
                  // Cell number - centered and clear
                  Center(
                    child: Text(
                      '$cellNumber',
                      style: TextStyle(
                        fontSize: (boardSize / 300) * 12,
                        color: const Color(0xFF333333),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // CustomPaint for snakes and ladders
        Positioned.fill(
          child: CustomPaint(
            painter: _BoardConnectionsPainter(game, boardSize),
          ),
        ),

        // Player tokens
        Positioned.fill(
          child: LayoutBuilder(builder: (context, box) {
            final cellSize = box.maxWidth / 10;
            final tokenSize = cellSize * 0.45;

            Widget buildToken(int pos, bool human) {
              if (pos <= 0 || pos > 100) return const SizedBox.shrink();
              final rc = _cellToRowCol(pos);
              final left = rc['col']! * cellSize + (cellSize - tokenSize) / 2;
              final top = rc['row']! * cellSize + (cellSize - tokenSize) / 2;

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                left: left,
                top: top,
                width: tokenSize,
                height: tokenSize,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: human ? const Color(0xFF4A90E2) : const Color(0xFFE74C3C),
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    human ? '👤' : '🤖',
                    style: TextStyle(fontSize: tokenSize * 0.5),
                  ),
                ),
              );
            }

            return Stack(children: [
              buildToken(game.humanPosition, true),
              buildToken(game.aiPosition, false),
            ]);
          }),
        ),
      ],
    );
  }

  Map<String, int> _cellToRowCol(int cellNumber) {
    final idx = cellNumber - 1;
    final rowFromBottom = idx ~/ 10;
    final row = 9 - rowFromBottom;
    final offset = idx % 10;
    final reversed = rowFromBottom % 2 == 1;
    final col = reversed ? 9 - offset : offset;
    return {'row': row, 'col': col};
  }
}

class _BoardConnectionsPainter extends CustomPainter {
  final GameService game;
  final double boardSize;
  
  _BoardConnectionsPainter(this.game, this.boardSize);

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 10;

    Offset centerOf(int cell) {
      final idx = cell - 1;
      final rowFromBottom = idx ~/ 10;
      final row = 9 - rowFromBottom;
      final offset = idx % 10;
      final reversed = rowFromBottom % 2 == 1;
      final col = reversed ? 9 - offset : offset;
      return Offset(col * cellSize + cellSize / 2, row * cellSize + cellSize / 2);
    }

    // Draw ladders FIRST
    for (var e in game.ladders.entries) {
      final start = centerOf(e.key);
      final end = centerOf((e.value['end'] ?? e.value) as int);
      _drawColorfulLadder(canvas, start, end, cellSize, e.key);
    }

    // Draw snakes SECOND
    for (var e in game.snakes.entries) {
      final head = centerOf(e.key);
      final tail = centerOf((e.value['end'] ?? e.value) as int);
      _drawColorfulSnake(canvas, head, tail, cellSize, e.key);
    }
  }

  void _drawColorfulLadder(Canvas canvas, Offset start, Offset end, double cellSize, int startPos) {
    // Different colors for different ladders
    final colors = [
      const Color(0xFFFF6B6B), // Red
      const Color(0xFF4ECDC4), // Cyan
      const Color(0xFFFFE66D), // Yellow
      const Color(0xFF95E1D3), // Mint
      const Color(0xFFFF9FF3), // Pink
      const Color(0xFFFECA57), // Orange
      const Color(0xFF48DBFB), // Light Blue
      const Color(0xFF00D2D3), // Turquoise
    ];
    
    final colorIndex = startPos % colors.length;
    final ladderColor = colors[colorIndex];

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    
    if (len == 0) return;
    
    final ux = dx / len;
    final uy = dy / len;
    final railWidth = cellSize * 0.10;
    final perp = Offset(-uy, ux) * railWidth;

    // Draw ladder shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = cellSize * 0.12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start + perp + const Offset(2, 2), end + perp + const Offset(2, 2), shadowPaint);
    canvas.drawLine(start - perp + const Offset(2, 2), end - perp + const Offset(2, 2), shadowPaint);

    // Side rails
    final railPaint = Paint()
      ..color = ladderColor
      ..strokeWidth = cellSize * 0.10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start + perp, end + perp, railPaint);
    canvas.drawLine(start - perp, end - perp, railPaint);

    // Rungs
    final rungCount = math.max(3, (len / (cellSize * 0.7)).round());
    final rungPaint = Paint()
      ..color = ladderColor.withValues(alpha: 0.9)
      ..strokeWidth = cellSize * 0.08
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i <= rungCount; i++) {
      final t = i / rungCount;
      final center = Offset(start.dx + dx * t, start.dy + dy * t);
      canvas.drawLine(center - perp * 0.95, center + perp * 0.95, rungPaint);
    }
  }

  void _drawColorfulSnake(Canvas canvas, Offset head, Offset tail, double cellSize, int startPos) {
    // Different colors for different snakes
    final snakeColors = [
      const Color(0xFF6BCB77), // Green
      const Color(0xFFFFC93C), // Yellow
      const Color(0xFFFF6B9D), // Pink
      const Color(0xFF9B72AA), // Purple
      const Color(0xFFFF8364), // Orange
      const Color(0xFF00D9FF), // Cyan
      const Color(0xFFB4E197), // Light Green
      const Color(0xFFFFB5DA), // Light Pink
    ];
    
    final colorIndex = startPos % snakeColors.length;
    final snakeColor = snakeColors[colorIndex];
    final darkSnakeColor = Color.lerp(snakeColor, Colors.black, 0.3)!;

    final distance = (head - tail).distance;
    if (distance == 0) return;

    // Create smooth curved snake body
    final segments = math.max(20, (distance / (cellSize * 0.3)).round());
    final List<Offset> points = [];
    
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = head.dx + (tail.dx - head.dx) * t;
      final y = head.dy + (tail.dy - head.dy) * t;
      
      // Smooth wave effect
      final wave = math.sin(t * math.pi * 2.5) * (cellSize * 0.20);
      final perpX = -(tail.dy - head.dy) / distance;
      final perpY = (tail.dx - head.dx) / distance;
      
      points.add(Offset(x + perpX * wave, y + perpY * wave));
    }

    // Draw snake body path
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Shadow
    final shadowPath = Path();
    shadowPath.moveTo(points[0].dx + 2, points[0].dy + 2);
    for (int i = 1; i < points.length; i++) {
      shadowPath.lineTo(points[i].dx + 2, points[i].dy + 2);
    }
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = cellSize * 0.20;
    canvas.drawPath(shadowPath, shadowPaint);

    // Main body
    final bodyPaint = Paint()
      ..color = snakeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = cellSize * 0.18;
    canvas.drawPath(path, bodyPaint);

    // Outline
    final outlinePaint = Paint()
      ..color = darkSnakeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = cellSize * 0.20;
    canvas.drawPath(path, outlinePaint);
    canvas.drawPath(path, bodyPaint);

    // Snake head
    final headSize = cellSize * 0.18;
    
    // Head shadow
    canvas.drawCircle(head + const Offset(2, 2), headSize, Paint()..color = Colors.black.withValues(alpha: 0.25));
    
    // Head fill
    canvas.drawCircle(head, headSize, Paint()..color = snakeColor);
    
    // Head outline
    canvas.drawCircle(head, headSize, Paint()
      ..color = darkSnakeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.03);

    // Eyes
    final eyeSize = cellSize * 0.04;
    canvas.drawCircle(head + Offset(-headSize * 0.35, -headSize * 0.35), eyeSize, Paint()..color = Colors.white);
    canvas.drawCircle(head + Offset(headSize * 0.35, -headSize * 0.35), eyeSize, Paint()..color = Colors.white);
    
    final pupilSize = eyeSize * 0.55;
    canvas.drawCircle(head + Offset(-headSize * 0.35, -headSize * 0.35), pupilSize, Paint()..color = Colors.black);
    canvas.drawCircle(head + Offset(headSize * 0.35, -headSize * 0.35), pupilSize, Paint()..color = Colors.black);

    // Tongue
    final tonguePath = Path();
    tonguePath.moveTo(head.dx, head.dy + headSize * 0.5);
    tonguePath.lineTo(head.dx - headSize * 0.25, head.dy + headSize * 0.9);
    tonguePath.moveTo(head.dx, head.dy + headSize * 0.5);
    tonguePath.lineTo(head.dx + headSize * 0.25, head.dy + headSize * 0.9);
    canvas.drawPath(tonguePath, Paint()
      ..color = const Color(0xFFE74C3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.02
      ..strokeCap = StrokeCap.round);

    // Tail
    final tailSize = cellSize * 0.10;
    canvas.drawCircle(tail, tailSize, Paint()..color = darkSnakeColor);
  }

  @override
  bool shouldRepaint(covariant _BoardConnectionsPainter old) => true;
}