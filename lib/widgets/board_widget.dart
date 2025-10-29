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
      final availableWidth = constraints.maxWidth;
      final availableHeight = MediaQuery.of(context).size.height * 0.55;
      final boardSize = math.min(availableWidth, availableHeight);

      return Center(
        child: Container(
          width: boardSize,
          height: boardSize,
          decoration: BoxDecoration(
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

            // Check if any player is on this cell
            bool hasPlayer = false;
            Color? occupyingColor;
            for (var entry in game.playerPositions.entries) {
              if (entry.value == cellNumber && entry.value > 0) {
                final playerIndex = int.parse(entry.key.replaceAll('player', ''));
                if (playerIndex <= game.numberOfPlayers) {
                  hasPlayer = true;
                  // take the first player's color if multiple players are present
                  occupyingColor ??= game.playerColors[entry.key];
                }
              }
            }

            const Color lightCell = Color(0xFFFFFFFF);
            const Color altCell = Color(0xFFF8F8F8);
            final bool isAlt = (row + col) % 2 == 0;
            final Color bg = hasPlayer
                ? (occupyingColor ?? const Color(0xFFFFF9E6))
                : (isAlt ? altCell : lightCell);

            // Special cells
            final bool isSnake = game.snakes.containsKey(cellNumber);
            final bool isLadder = game.ladders.containsKey(cellNumber);

            // Determine number text color for contrast
            Color numberColor;
            try {
              // compute contrast: if background is light -> dark text, else white text
              final luminance = bg.computeLuminance();
              numberColor = luminance > 0.6 ? const Color(0xFF222222) : Colors.white;
            } catch (e) {
              numberColor = const Color(0xFF333333);
            }

            return Container(
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(
                  color: hasPlayer
                      ? (occupyingColor != null ? occupyingColor.withAlpha(200) : const Color(0xFFFFB300))
                      : const Color(0xFFDDDDDD),
                  width: hasPlayer ? 2.0 : 0.5,
                ),
              ),
              child: Stack(
                children: [
                  // Cell number - always visible and contrast aware
                  Center(
                    child: Text(
                      '$cellNumber',
                      style: TextStyle(
                        fontSize: (boardSize / 300) * 11,
                        color: numberColor,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: bg.computeLuminance() > 0.6 ? Colors.white.withAlpha(180) : Colors.black.withAlpha(120),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Special cell indicator
                  if (isSnake || isLadder)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: boardSize / 50,
                        height: boardSize / 50,
                        decoration: BoxDecoration(
                          color: isLadder
                              ? Colors.green.withAlpha(179)
                              : Colors.red.withAlpha(179),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        // CustomPaint for snakes and ladders - more visible
        Positioned.fill(
          child: CustomPaint(
            painter: _BoardConnectionsPainter(game, boardSize),
          ),
        ),

        // Player tokens - smaller and with cell number visible
        Positioned.fill(
          child: LayoutBuilder(builder: (context, box) {
            final cellSize = box.maxWidth / 10;
            final tokenSize = cellSize * 0.28;

            List<Widget> tokens = [];

            for (var entry in game.playerPositions.entries) {
              final playerIndex = int.parse(entry.key.replaceAll('player', ''));
              if (playerIndex <= game.numberOfPlayers && entry.value > 0) {
                tokens.add(_buildToken(
                  entry.value,
                  game.playerColors[entry.key]!,
                  playerIndex,
                  cellSize,
                  tokenSize,
                  game.numberOfPlayers,
                ));
              }
            }

            return Stack(children: tokens);
          }),
        ),
      ],
    );
  }

  Widget _buildToken(int pos, Color color, int playerIndex, double cellSize, double tokenSize, int totalPlayers) {
    if (pos <= 0 || pos > 100) return const SizedBox.shrink();

    final rc = _cellToRowCol(pos);

    // Position tokens at top-left corner to keep numbers visible
    double offsetX = 2;
    double offsetY = 2;

    if (totalPlayers == 2) {
      offsetX = playerIndex == 1 ? 2 : cellSize - tokenSize - 2;
    } else if (totalPlayers == 3) {
      if (playerIndex == 1) {
        offsetX = 2;
      } else if (playerIndex == 2) {
        offsetX = cellSize - tokenSize - 2;
      } else {
        offsetX = (cellSize - tokenSize) / 2;
        offsetY = cellSize - tokenSize - 2;
      }
    }

    final left = rc['col']! * cellSize + offsetX;
    final top = rc['row']! * cellSize + offsetY;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      left: left,
      top: top,
      width: tokenSize,
      height: tokenSize,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: 0.8, end: 1.0),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(127),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                playerIndex == 3 ? '🤖' : 'P$playerIndex',
                style: TextStyle(
                  fontSize: tokenSize * 0.35,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
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

    // Draw ladders - MORE VISIBLE
    for (var e in game.ladders.entries) {
      final start = centerOf(e.key);
      final end = centerOf((e.value['end'] ?? e.value) as int);
      _drawVisibleLadder(canvas, start, end, cellSize, e.key);
    }

    // Draw snakes - MORE VISIBLE
    for (var e in game.snakes.entries) {
      final head = centerOf(e.key);
      final tail = centerOf((e.value['end'] ?? e.value) as int);
      _drawVisibleSnake(canvas, head, tail, cellSize, e.key);
    }
  }

  void _drawVisibleLadder(Canvas canvas, Offset start, Offset end, double cellSize, int startPos) {
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFF95E1D3),
      const Color(0xFFFF9FF3),
      const Color(0xFFFECA57),
      const Color(0xFF48DBFB),
      const Color(0xFF00D2D3),
    ];

    final colorIndex = startPos % colors.length;
    final ladderColor = colors[colorIndex].withAlpha(204); // 80% opacity - MORE VISIBLE

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = math.sqrt(dx * dx + dy * dy);

    if (len == 0) return;

    final ux = dx / len;
    final uy = dy / len;
    final railWidth = cellSize * 0.12;
    final perp = Offset(-uy, ux) * railWidth;

    // Side rails
    final railPaint = Paint()
      ..color = ladderColor
      ..strokeWidth = cellSize * 0.09
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start + perp, end + perp, railPaint);
    canvas.drawLine(start - perp, end - perp, railPaint);

    // Rungs
    final rungCount = math.max(3, (len / (cellSize * 0.7)).round());
    final rungPaint = Paint()
      ..color = ladderColor.withAlpha(179) // 70% opacity
      ..strokeWidth = cellSize * 0.07
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i <= rungCount; i++) {
      final t = i / rungCount;
      final center = Offset(start.dx + dx * t, start.dy + dy * t);
      canvas.drawLine(center - perp * 0.95, center + perp * 0.95, rungPaint);
    }
  }

  void _drawVisibleSnake(Canvas canvas, Offset head, Offset tail, double cellSize, int startPos) {
    final snakeColors = [
      const Color(0xFF6BCB77),
      const Color(0xFFFFC93C),
      const Color(0xFFFF6B9D),
      const Color(0xFF9B72AA),
      const Color(0xFFFF8364),
      const Color(0xFF00D9FF),
      const Color(0xFFB4E197),
      const Color(0xFFFFB5DA),
    ];

    final colorIndex = startPos % snakeColors.length;
    final snakeColor = snakeColors[colorIndex].withAlpha(191); // 75% opacity - MORE VISIBLE
    final darkSnakeColor = Color.lerp(snakeColor, Colors.black, 0.2)!;

    final distance = (head - tail).distance;
    if (distance == 0) return;

    final segments = math.max(20, (distance / (cellSize * 0.3)).round());
    final List<Offset> points = [];

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = head.dx + (tail.dx - head.dx) * t;
      final y = head.dy + (tail.dy - head.dy) * t;

      final wave = math.sin(t * math.pi * 2.5) * (cellSize * 0.18);
      final perpX = -(tail.dy - head.dy) / distance;
      final perpY = (tail.dx - head.dx) / distance;

      points.add(Offset(x + perpX * wave, y + perpY * wave));
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Main body
    final bodyPaint = Paint()
      ..color = snakeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = cellSize * 0.16;
    canvas.drawPath(path, bodyPaint);

    // Snake head
    final headSize = cellSize * 0.15;
    canvas.drawCircle(head, headSize, Paint()..color = snakeColor);
    canvas.drawCircle(head, headSize, Paint()
      ..color = darkSnakeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.025);

    // Eyes
    final eyeSize = cellSize * 0.035;
    canvas.drawCircle(head + Offset(-headSize * 0.35, -headSize * 0.35), eyeSize, Paint()..color = Colors.white);
    canvas.drawCircle(head + Offset(headSize * 0.35, -headSize * 0.35), eyeSize, Paint()..color = Colors.white);

    final pupilSize = eyeSize * 0.6;
    canvas.drawCircle(head + Offset(-headSize * 0.35, -headSize * 0.35), pupilSize, Paint()..color = Colors.black);
    canvas.drawCircle(head + Offset(headSize * 0.35, -headSize * 0.35), pupilSize, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant _BoardConnectionsPainter old) => true;
}
