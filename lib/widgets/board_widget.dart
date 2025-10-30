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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8B6F47),
                Color(0xFF654321),
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 10),
              )
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFAF0),
                  Color(0xFFF5F5DC),
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
              border: Border(
                top: BorderSide(color: Color(0xFF654321), width: 2),
                bottom: BorderSide(color: Color(0xFF654321), width: 2),
                left: BorderSide(color: Color(0xFF654321), width: 2),
                right: BorderSide(color: Color(0xFF654321), width: 2),
              ),
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
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
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
                  occupyingColor ??= game.playerColors[entry.key];
                }
              }
            }

            // Alternating pastel colors for a more playful look
            final bool isLightRow = rowFromBottom % 2 == 0;
            final bool isLightCol = actualCol % 2 == 0;
            Color cellColor;
            
            if (hasPlayer) {
              cellColor = Color.alphaBlend(
                occupyingColor!.withAlpha(38),
                Colors.white,
              );
            } else {
              if (isLightRow == isLightCol) {
                cellColor = const Color(0xFFFFFFFF);
              } else {
                cellColor = const Color(0xFFFFF9E6);
              }
            }

            // Special cells
            final bool isSnake = game.snakes.containsKey(cellNumber);
            final bool isLadder = game.ladders.containsKey(cellNumber);

            // Special cell highlights
            if (isSnake && !hasPlayer) {
              cellColor = const Color(0xFFFFEBEE); // Light red tint
            } else if (isLadder && !hasPlayer) {
              cellColor = const Color(0xFFE8F5E9); // Light green tint
            }

            // Start and end cell special styling
            if (cellNumber == 1) {
              cellColor = const Color(0xFFE3F2FD); // Light blue for start
            } else if (cellNumber == 100) {
              cellColor = const Color(0xFFFFF9C4); // Light yellow for finish
            }

            Color numberColor = const Color(0xFF424242);
            if (hasPlayer) {
              numberColor = occupyingColor!;
            } else if (cellNumber == 1 || cellNumber == 100) {
              numberColor = const Color(0xFF1976D2);
            }

            return Container(
              decoration: BoxDecoration(
                color: cellColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: hasPlayer
                      ? Color.alphaBlend(occupyingColor!.withAlpha(127), Colors.white)
                      : (cellNumber == 1 || cellNumber == 100)
                          ? const Color(0xFF1976D2).withAlpha(76)
                          : const Color(0xFFE0E0E0),
                  width: hasPlayer ? 2.0 : 1.0,
                ),
                boxShadow: hasPlayer ? [
                  BoxShadow(
                    color: occupyingColor!.withAlpha(76),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ] : null,
              ),
              child: Stack(
                children: [
                  // Cell number
                  Center(
                    child: Text(
                      '$cellNumber',
                      style: TextStyle(
                        fontSize: (boardSize / 300) * 12,
                        color: numberColor,
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(
                            color: Color(0x80FFFFFF),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Special cell indicator (larger and more visible)
                  if (isSnake || isLadder)
                    Positioned(
                      top: 1,
                      right: 1,
                      child: Container(
                        width: boardSize / 40,
                        height: boardSize / 40,
                        decoration: BoxDecoration(
                          color: isLadder
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFF44336),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isLadder ? Colors.green : Colors.red).withAlpha(102),
                              blurRadius: 2,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Start/End markers
                  if (cellNumber == 1)
                    const Positioned(
                      bottom: 2,
                      left: 2,
                      child: Text('🎯', style: TextStyle(fontSize: 10)),
                    ),
                  if (cellNumber == 100)
                    const Positioned(
                      bottom: 2,
                      right: 2,
                      child: Text('🏆', style: TextStyle(fontSize: 10)),
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
            final tokenSize = cellSize * 0.32;

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

    // Smart positioning for multiple players
    double offsetX = cellSize * 0.5 - tokenSize * 0.5;
    double offsetY = cellSize * 0.5 - tokenSize * 0.5;

    if (totalPlayers == 2) {
      offsetX = playerIndex == 1 
          ? cellSize * 0.25 - tokenSize * 0.5
          : cellSize * 0.75 - tokenSize * 0.5;
    } else if (totalPlayers == 3) {
      if (playerIndex == 1) {
        offsetX = cellSize * 0.25 - tokenSize * 0.5;
        offsetY = cellSize * 0.35 - tokenSize * 0.5;
      } else if (playerIndex == 2) {
        offsetX = cellSize * 0.75 - tokenSize * 0.5;
        offsetY = cellSize * 0.35 - tokenSize * 0.5;
      } else {
        offsetX = cellSize * 0.5 - tokenSize * 0.5;
        offsetY = cellSize * 0.7 - tokenSize * 0.5;
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
                gradient: RadialGradient(
                  colors: [
                    color.withAlpha(229),
                    color,
                  ],
                  center: Alignment.topLeft,
                  radius: 1.0,
                ),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(127),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                playerIndex == 3 ? '🤖' : 'P$playerIndex',
                style: TextStyle(
                  fontSize: tokenSize * 0.4,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Color(0x4D000000),
                      blurRadius: 2,
                    ),
                  ],
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

    // Draw ladders
    for (var e in game.ladders.entries) {
      final start = centerOf(e.key);
      final end = centerOf((e.value['end'] ?? e.value) as int);
      _drawStylishLadder(canvas, start, end, cellSize);
    }

    // Draw snakes
    for (var e in game.snakes.entries) {
      final head = centerOf(e.key);
      final tail = centerOf((e.value['end'] ?? e.value) as int);
      _drawStylishSnake(canvas, head, tail, cellSize);
    }
  }

  void _drawStylishLadder(Canvas canvas, Offset start, Offset end, double cellSize) {
    // Beautiful gradient ladder with 3D effect
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = math.sqrt(dx * dx + dy * dy);

    if (len == 0) return;

    final ux = dx / len;
    final uy = dy / len;
    final railWidth = cellSize * 0.14;
    final perp = Offset(-uy, ux) * railWidth;

    // Shadow for 3D effect
    final shadowPaint = Paint()
      ..color = const Color(0x26000000)
      ..strokeWidth = cellSize * 0.11
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start + perp + const Offset(2, 2), end + perp + const Offset(2, 2), shadowPaint);
    canvas.drawLine(start - perp + const Offset(2, 2), end - perp + const Offset(2, 2), shadowPaint);

    // Main rails with gradient effect
    final railPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF8B4513),
          Color(0xFFD2691E),
        ],
      ).createShader(Rect.fromPoints(start, end))
      ..strokeWidth = cellSize * 0.10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start + perp, end + perp, railPaint);
    canvas.drawLine(start - perp, end - perp, railPaint);

    // Highlight on rails
    final highlightPaint = Paint()
      ..color = const Color(0x99DEB887)
      ..strokeWidth = cellSize * 0.04
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start + perp * 0.7, end + perp * 0.7, highlightPaint);
    canvas.drawLine(start - perp * 0.7, end - perp * 0.7, highlightPaint);

    // Rungs with shadow
    final rungCount = math.max(3, (len / (cellSize * 0.7)).round());
    
    for (int i = 0; i <= rungCount; i++) {
      final t = i / rungCount;
      final center = Offset(start.dx + dx * t, start.dy + dy * t);
      
      // Rung shadow
      final rungShadowPaint = Paint()
        ..color = const Color(0x26000000)
        ..strokeWidth = cellSize * 0.08
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(center - perp * 0.95 + const Offset(1, 1), center + perp * 0.95 + const Offset(1, 1), rungShadowPaint);
      
      // Main rung
      final rungPaint = Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF8B4513),
            Color(0xFFD2691E),
          ],
        ).createShader(Rect.fromPoints(center - perp, center + perp))
        ..strokeWidth = cellSize * 0.08
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(center - perp * 0.95, center + perp * 0.95, rungPaint);
    }
  }

  void _drawStylishSnake(Canvas canvas, Offset head, Offset tail, double cellSize) {
    final distance = (head - tail).distance;
    if (distance == 0) return;

    final segments = math.max(25, (distance / (cellSize * 0.25)).round());
    final List<Offset> points = [];

    // Create wavy snake body
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = head.dx + (tail.dx - head.dx) * t;
      final y = head.dy + (tail.dy - head.dy) * t;

      final wave = math.sin(t * math.pi * 3) * (cellSize * 0.2);
      final perpX = -(tail.dy - head.dy) / distance;
      final perpY = (tail.dx - head.dx) / distance;

      points.add(Offset(x + perpX * wave, y + perpY * wave));
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Shadow
    final shadowPaint = Paint()
      ..color = const Color(0x33000000)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = cellSize * 0.19;
    
    canvas.save();
    canvas.translate(2, 2);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Outer body (darker)
    final outerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF2E7D32),
          Color(0xFF66BB6A),
        ],
      ).createShader(Rect.fromPoints(head, tail))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = cellSize * 0.18;
    canvas.drawPath(path, outerPaint);

    // Inner body (lighter)
    final innerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF4CAF50),
          Color(0xFF81C784),
        ],
      ).createShader(Rect.fromPoints(head, tail))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = cellSize * 0.13;
    canvas.drawPath(path, innerPaint);

    // Pattern on snake body
    for (int i = 0; i < points.length; i += 3) {
      final patternPaint = Paint()
        ..color = const Color(0x4D1B5E20)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(points[i], cellSize * 0.03, patternPaint);
    }

    // Snake head with shadow
    final headSize = cellSize * 0.18;
    
    // Head shadow
    canvas.drawCircle(head + const Offset(2, 2), headSize, Paint()
      ..color = const Color(0x33000000));
    
    // Head gradient
    final headPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF66BB6A),
          Color(0xFF2E7D32),
        ],
      ).createShader(Rect.fromCircle(center: head, radius: headSize));
    canvas.drawCircle(head, headSize, headPaint);

    // Head outline
    canvas.drawCircle(head, headSize, Paint()
      ..color = const Color(0xFF1B5E20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.03);

    // Eyes with white background
    final eyeSize = cellSize * 0.045;
    final eyeWhite = Paint()..color = Colors.white;
    canvas.drawCircle(head + Offset(-headSize * 0.35, -headSize * 0.4), eyeSize, eyeWhite);
    canvas.drawCircle(head + Offset(headSize * 0.35, -headSize * 0.4), eyeSize, eyeWhite);

    // Pupils
    final pupilSize = eyeSize * 0.65;
    final pupilPaint = Paint()..color = const Color(0xFF1B5E20);
    canvas.drawCircle(head + Offset(-headSize * 0.35, -headSize * 0.4), pupilSize, pupilPaint);
    canvas.drawCircle(head + Offset(headSize * 0.35, -headSize * 0.4), pupilSize, pupilPaint);

    // Tongue
    final tonguePaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..strokeWidth = cellSize * 0.02
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      head + Offset(0, headSize * 0.6),
      head + Offset(0, headSize * 0.9),
      tonguePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BoardConnectionsPainter old) => true;
}