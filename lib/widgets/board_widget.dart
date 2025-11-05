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

class _BoardWidgetState extends State<BoardWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameService>(context);

    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        textScaler: const TextScaler.linear(0.85),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
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
      }),
    );
  }

  Widget _buildBoardContents(double boardSize, GameService game) {
    return Stack(
      children: [
        // Base grid
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
              child: Center(
                child: Text(
                  '$cellNumber',
                  style: TextStyle(
                    fontSize: (boardSize / 300) * 12,
                    color: const Color(0xFF333333),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),

        // START and FINISH blocks overlay
        Positioned.fill(
          child: CustomPaint(
            painter: _StartFinishPainter(boardSize),
          ),
        ),

        // Occupied cells overlay
        Positioned.fill(
          child: CustomPaint(
            painter: _OccupiedCellsPainter(game),
          ),
        ),

        // Snakes & Ladders
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: _BoardConnectionsPainter(
                  game,
                  boardSize,
                  _animationController.value,
                ),
              );
            },
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

  Widget _buildToken(
    int pos,
    Color color,
    int playerIndex,
    double cellSize,
    double tokenSize,
    int totalPlayers,
  ) {
    if (pos <= 0 || pos > 100) return const SizedBox.shrink();

    final rc = _cellToRowCol(pos);

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

// NEW: Painter for START (cell 1) and FINISH (cell 100) blocks
class _StartFinishPainter extends CustomPainter {
  final double boardSize;
  _StartFinishPainter(this.boardSize);

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / 10;

    // START block at cell 1 (bottom-left corner)
    _drawStartBlock(canvas, cellSize, 1);

    // FINISH block at cell 100 (top-left corner)
    _drawFinishBlock(canvas, cellSize, 100);
  }

  void _drawStartBlock(Canvas canvas, double cellSize, int cellNumber) {
    final rc = _cellToRowCol(cellNumber);
    final rect = Rect.fromLTWH(
      rc['col']! * cellSize + 1,
      rc['row']! * cellSize + 1,
      cellSize - 2,
      cellSize - 2,
    );

    // Gradient background for START
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF4CAF50).withValues(alpha: 0.3),
        const Color(0xFF66BB6A).withValues(alpha: 0.2),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rrect, paint);

    // Border
    final borderPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, borderPaint);

    // "START" text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'START',
        style: TextStyle(
          color: const Color(0xFF2E7D32),
          fontSize: cellSize * 0.20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.center.dx - textPainter.width / 2,
        rect.center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawFinishBlock(Canvas canvas, double cellSize, int cellNumber) {
    final rc = _cellToRowCol(cellNumber);
    final rect = Rect.fromLTWH(
      rc['col']! * cellSize + 1,
      rc['row']! * cellSize + 1,
      cellSize - 2,
      cellSize - 2,
    );

    // Gradient background for FINISH
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFFFD700).withValues(alpha: 0.4),
        const Color(0xFFFFA500).withValues(alpha: 0.3),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rrect, paint);

    // Border with gold shimmer effect
    final borderPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, borderPaint);

    // "FINISH" text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'FINISH',
        style: TextStyle(
          color: const Color(0xFFFF8C00),
          fontSize: cellSize * 0.18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.center.dx - textPainter.width / 2,
        rect.center.dy - textPainter.height / 2,
      ),
    );

    // Trophy icon above text
    final iconPainter = TextPainter(
      text: const TextSpan(
        text: '🏆',
        style: TextStyle(fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        rect.center.dx - iconPainter.width / 2,
        rect.top + cellSize * 0.15,
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

  @override
  bool shouldRepaint(covariant _StartFinishPainter oldDelegate) => false;
}

// Occupied cells painter
class _OccupiedCellsPainter extends CustomPainter {
  final GameService game;
  _OccupiedCellsPainter(this.game);

  @override
  void paint(Canvas canvas, Size size) {
    final double cell = size.width / 10;
    const double inset = 0.8;

    RRect rrectForCell(int cellNum) {
      final idx = cellNum - 1;
      final rowFromBottom = idx ~/ 10;
      final row = 9 - rowFromBottom;
      final offset = idx % 10;
      final reversed = rowFromBottom % 2 == 1;
      final col = reversed ? 9 - offset : offset;

      final rect = Rect.fromLTWH(
        col * cell + inset,
        row * cell + inset,
        cell - inset * 2,
        cell - inset * 2,
      );
      return RRect.fromRectAndRadius(rect, const Radius.circular(2.5));
    }

    for (final entry in game.playerPositions.entries) {
      final playerIndex = int.tryParse(entry.key.replaceAll('player', '')) ?? 0;
      final pos = entry.value;
      if (playerIndex < 1 || playerIndex > game.numberOfPlayers) continue;
      if (pos <= 0 || pos > 100) continue;

      final Color? base = game.playerColors[entry.key];
      if (base == null) continue;

      final Color fill = base.withValues(alpha: 0.55);

      final paint = Paint()
        ..color = fill
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrectForCell(pos), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OccupiedCellsPainter oldDelegate) => true;
}

// Board connections painter (snakes & ladders)
class _BoardConnectionsPainter extends CustomPainter {
  final GameService game;
  final double boardSize;
  final double animationValue;

  _BoardConnectionsPainter(this.game, this.boardSize, this.animationValue);

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

    for (final e in game.ladders.entries) {
      final start = centerOf(e.key);
      final int endCell = _endCellOf(e.value);
      final end = centerOf(endCell);
      _drawColorfulLadder(canvas, start, end, cellSize, e.key);
    }

    for (final e in game.snakes.entries) {
      final head = centerOf(e.key);
      final int endCell = _endCellOf(e.value);
      final tail = centerOf(endCell);
      _drawColorfulSnake(canvas, head, tail, cellSize, e.key);
    }
  }

  int _endCellOf(dynamic v) {
    if (v is int) return v;
    if (v is Map && v['end'] is int) return v['end'] as int;
    throw StateError('Invalid snake/ladder value: $v');
  }

  void _drawColorfulLadder(Canvas canvas, Offset start, Offset end, double cellSize, int startPos) {
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
    final ladderColor = colors[colorIndex];

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;

    final ux = dx / len;
    final uy = dy / len;
    final railWidth = cellSize * 0.10;
    final perp = Offset(-uy, ux) * railWidth;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = cellSize * 0.12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start + perp + const Offset(2, 2), end + perp + const Offset(2, 2), shadowPaint);
    canvas.drawLine(start - perp + const Offset(2, 2), end - perp + const Offset(2, 2), shadowPaint);

    final railPaint = Paint()
      ..color = ladderColor
      ..strokeWidth = cellSize * 0.10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start + perp, end + perp, railPaint);
    canvas.drawLine(start - perp, end - perp, railPaint);

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
    final snakeColor = snakeColors[colorIndex];
    final darkSnakeColor = Color.lerp(snakeColor, Colors.black, 0.3)!;

    final distance = (head - tail).distance;
    if (distance == 0) return;

    final segments = math.max(20, (distance / (cellSize * 0.3)).round());
    final List<Offset> points = [];
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = head.dx + (tail.dx - head.dx) * t;
      final y = head.dy + (tail.dy - head.dy) * t;

      final perpX = -(tail.dy - head.dy) / distance;
      final perpY = (tail.dx - head.dx) / distance;
      final wave = math.sin(t * math.pi * 2.5) * (cellSize * 0.20);

      points.add(Offset(x + perpX * wave, y + perpY * wave));
    }

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final shadowPath = Path()..moveTo(points[0].dx + 2, points[0].dy + 2);
    for (int i = 1; i < points.length; i++) {
      shadowPath.lineTo(points[i].dx + 2, points[i].dy + 2);
    }
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = cellSize * 0.20;
    canvas.drawPath(shadowPath, shadowPaint);

    final bodyPaint = Paint()
      ..color = snakeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = cellSize * 0.18;
    final outlinePaint = Paint()
      ..color = darkSnakeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = cellSize * 0.20;

    canvas.drawPath(path, outlinePaint);
    canvas.drawPath(path, bodyPaint);

    final headSize = cellSize * 0.18;
    canvas.drawCircle(head + const Offset(2, 2), headSize, Paint()..color = Colors.black.withValues(alpha: 0.25));
    canvas.drawCircle(head, headSize, Paint()..color = snakeColor);
    canvas.drawCircle(head, headSize, Paint()
      ..color = darkSnakeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.03);

    final eyeSize = cellSize * 0.04;
    canvas.drawCircle(head + Offset(-headSize * 0.35, -headSize * 0.35), eyeSize, Paint()..color = Colors.white);
    canvas.drawCircle(head + Offset(headSize * 0.35, -headSize * 0.35), eyeSize, Paint()..color = Colors.white);
    final pupilSize = eyeSize * 0.55;
    canvas.drawCircle(head + Offset(-headSize * 0.35, -headSize * 0.35), pupilSize, Paint()..color = Colors.black);
    canvas.drawCircle(head + Offset(headSize * 0.35, -headSize * 0.35), pupilSize, Paint()..color = Colors.black);

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

    final tailSize = cellSize * 0.10;
    canvas.drawCircle(tail, tailSize, Paint()..color = darkSnakeColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}