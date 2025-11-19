// lib/widgets/board_widget.dart - ENHANCED VERSION
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import 'dart:math' as math;
import 'dart:math' show cos, sin, pi;

class BoardWidget extends StatefulWidget {
  const BoardWidget({super.key});

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shimmerController.dispose();
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
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B6F47), Color(0xFF6B5437)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(76),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: Colors.black.withAlpha(38),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFAF0),
                    Color(0xFFF5F5DC),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF654321), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
        // Base grid with subtle gradient
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

            final bool isAlt = (row + col) % 2 == 0;
            
            final cellDecoration = isAlt 
                ? const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFFFFF), Color(0xFFFFFDFA)],
                    ),
                    border: Border(
                      top: BorderSide(color: Color(0xFFE8E8E8), width: 0.5),
                      left: BorderSide(color: Color(0xFFE8E8E8), width: 0.5),
                      right: BorderSide(color: Color(0xFFE8E8E8), width: 0.5),
                      bottom: BorderSide(color: Color(0xFFE8E8E8), width: 0.5),
                    ),
                  )
                : const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFFAF5), Color(0xFFF8F8F8)],
                    ),
                    border: Border(
                      top: BorderSide(color: Color(0xFFE8E8E8), width: 0.5),
                      left: BorderSide(color: Color(0xFFE8E8E8), width: 0.5),
                      right: BorderSide(color: Color(0xFFE8E8E8), width: 0.5),
                      bottom: BorderSide(color: Color(0xFFE8E8E8), width: 0.5),
                    ),
                  );
            
            return Container(
              decoration: cellDecoration,
              child: Center(
                child: Text(
                  '$cellNumber',
                  style: TextStyle(
                    fontSize: (boardSize / 300) * 12,
                    color: const Color(0xFF444444),
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: Colors.white.withAlpha(127),
                        offset: const Offset(0, 0.5),
                      ),
                    ],
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

        // Advice Square tiles overlay
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return CustomPaint(
                painter: _AdviceSquarePainter(game, _shimmerController.value),
              );
            },
          ),
        ),

        // Player position borders overlay - NEW
        Positioned.fill(
          child: CustomPaint(
            painter: _PlayerBordersPainter(game),
          ),
        ),

        // Occupied cells overlay
        Positioned.fill(
          child: CustomPaint(
            painter: _OccupiedCellsPainter(game),
          ),
        ),

        // Snakes & Ladders with animations
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: _EnhancedBoardConnectionsPainter(
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
                    color.withAlpha(240),
                    color,
                    Color.lerp(color, Colors.black, 0.2)!,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                  center: const Alignment(-0.3, -0.3),
                ),
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(140),
                    blurRadius: 12,
                    spreadRadius: 3,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                playerIndex == 3 ? '🤖' : 'P$playerIndex',
                style: TextStyle(
                  fontSize: tokenSize * 0.4,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Color(0x80000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
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

// NEW: Player borders painter
class _PlayerBordersPainter extends CustomPainter {
  final GameService game;
  _PlayerBordersPainter(this.game);

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / 10;

    for (var entry in game.playerPositions.entries) {
      final playerIndex = int.tryParse(entry.key.replaceAll('player', '')) ?? 0;
      final pos = entry.value;
      
      if (playerIndex < 1 || playerIndex > game.numberOfPlayers) continue;
      if (pos <= 0 || pos > 100) continue;

      final Color? playerColor = game.playerColors[entry.key];
      if (playerColor == null) continue;

      final rc = _cellToRowCol(pos);
      final rect = Rect.fromLTWH(
        rc['col']! * cellSize + 1,
        rc['row']! * cellSize + 1,
        cellSize - 2,
        cellSize - 2,
      );

      // Draw colored border for the player's current position
      final borderPaint = Paint()
        ..color = playerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;

      canvas.drawRect(rect, borderPaint);
    }
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
  bool shouldRepaint(covariant _PlayerBordersPainter oldDelegate) => true;
}

// Enhanced START and FINISH blocks painter
class _StartFinishPainter extends CustomPainter {
  final double boardSize;
  _StartFinishPainter(this.boardSize);

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / 10;
    _drawStartBlock(canvas, cellSize, 1);
    _drawFinishBlock(canvas, cellSize, 100);
  }

  void _drawStartBlock(Canvas canvas, double cellSize, int cellNumber) {
    final rc = _cellToRowCol(cellNumber);
    final rect = Rect.fromLTWH(
      rc['col']! * cellSize + 2,
      rc['row']! * cellSize + 2,
      cellSize - 4,
      cellSize - 4,
    );

    // Gradient background
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A), Color(0xFF388E3C)],
      stops: [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cellSize * 0.18));
    
    // Shadow
    canvas.drawRRect(
      rrect.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withAlpha(38)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    
    canvas.drawRRect(rrect, paint);

    // Border with shine effect
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, borderPaint);

    // Inner glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withAlpha(76),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: rect.topLeft + Offset(cellSize * 0.3, cellSize * 0.3), radius: cellSize * 0.4));
    canvas.drawRRect(rrect, glowPaint);

    // Decorative stars
    _drawStar(canvas, Offset(rect.left + cellSize * 0.2, rect.top + cellSize * 0.2), cellSize * 0.08, Colors.white.withAlpha(178));
    _drawStar(canvas, Offset(rect.right - cellSize * 0.2, rect.top + cellSize * 0.2), cellSize * 0.08, Colors.white.withAlpha(178));

    // Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'START',
        style: TextStyle(
          color: Colors.white,
          fontSize: cellSize * 0.22,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          shadows: const [
            Shadow(color: Color(0xCC000000), blurRadius: 4, offset: Offset(0, 2)),
            Shadow(color: Color(0x80000000), blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.center.dx - textPainter.width / 2,
        rect.center.dy - textPainter.height / 2 + cellSize * 0.08,
      ),
    );

    // Icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: '🚩',
        style: TextStyle(fontSize: cellSize * 0.32),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        rect.center.dx - iconPainter.width / 2,
        rect.top + cellSize * 0.08,
      ),
    );
  }

  void _drawFinishBlock(Canvas canvas, double cellSize, int cellNumber) {
    final rc = _cellToRowCol(cellNumber);
    final rect = Rect.fromLTWH(
      rc['col']! * cellSize + 2,
      rc['row']! * cellSize + 2,
      cellSize - 4,
      cellSize - 4,
    );

    // Animated gradient
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFF8C00)],
      stops: [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cellSize * 0.18));
    
    // Shadow
    canvas.drawRRect(
      rrect.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withAlpha(51)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    
    canvas.drawRRect(rrect, paint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, borderPaint);

    // Inner glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withAlpha(102),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: rect.topLeft + Offset(cellSize * 0.3, cellSize * 0.3), radius: cellSize * 0.5));
    canvas.drawRRect(rrect, glowPaint);

    // Decorative stars
    _drawStar(canvas, Offset(rect.left + cellSize * 0.15, rect.top + cellSize * 0.15), cellSize * 0.1, Colors.white.withAlpha(204));
    _drawStar(canvas, Offset(rect.right - cellSize * 0.15, rect.top + cellSize * 0.15), cellSize * 0.1, Colors.white.withAlpha(204));
    _drawStar(canvas, Offset(rect.center.dx, rect.bottom - cellSize * 0.15), cellSize * 0.08, Colors.white.withAlpha(153));

    // Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'FINISH',
        style: TextStyle(
          color: Colors.white,
          fontSize: cellSize * 0.20,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          shadows: const [
            Shadow(color: Color(0xCC000000), blurRadius: 4, offset: Offset(0, 2)),
            Shadow(color: Color(0x80000000), blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.center.dx - textPainter.width / 2,
        rect.center.dy - textPainter.height / 2 + cellSize * 0.10,
      ),
    );

    // Icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: '🏆',
        style: TextStyle(fontSize: cellSize * 0.36),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        rect.center.dx - iconPainter.width / 2,
        rect.top + cellSize * 0.05,
      ),
    );
  }

  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    final path = Path();
    const numberOfPoints = 5;
    const angle = (pi * 2) / numberOfPoints;
    
    for (int i = 0; i < numberOfPoints * 2; i++) {
      final radius = i.isEven ? size : size * 0.5;
      final x = center.dx + radius * cos(i * angle - pi / 2);
      final y = center.dy + radius * sin(i * angle - pi / 2);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
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

// Enhanced Advice Square Painter with shimmer
class _AdviceSquarePainter extends CustomPainter {
  final GameService game;
  final double shimmerValue;
  
  _AdviceSquarePainter(this.game, this.shimmerValue);

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / 10;
    
    for (final cell in game.adviceSquares) {
      final rc = _cellToRowCol(cell);
      final rect = Rect.fromLTWH(
        rc['col']! * cellSize + 2,
        rc['row']! * cellSize + 2,
        cellSize - 4,
        cellSize - 4,
      );

      // Animated gradient background
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(const Color(0xFFFBBF24), const Color(0xFFFFD700), shimmerValue)!,
          const Color(0xFFF59E0B),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cellSize * 0.14));
      
      // Shadow
      canvas.drawRRect(
        rrect.shift(const Offset(0, 1.5)),
        Paint()..color = Colors.black.withAlpha(38)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      
      canvas.drawRRect(rrect, paint);

      // Border with pulse effect
      final borderPaint = Paint()
        ..color = Color.lerp(const Color(0xFFF59E0B), Colors.white, shimmerValue * 0.5)!
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(rrect, borderPaint);

      // Inner glow
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withAlpha((shimmerValue * 100).round() + 50),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: rect.topLeft + Offset(cellSize * 0.3, cellSize * 0.3), radius: cellSize * 0.4));
      canvas.drawRRect(rrect, glowPaint);

      // Icon
      final iconPainter = TextPainter(
        text: TextSpan(
          text: '💡',
          style: TextStyle(fontSize: cellSize * 0.45),
        ),
        textDirection: TextDirection.ltr,
      );
      iconPainter.layout();
      iconPainter.paint(
        canvas,
        Offset(
          rect.center.dx - iconPainter.width / 2,
          rect.center.dy - iconPainter.height / 2,
        ),
      );
    }
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
  bool shouldRepaint(covariant _AdviceSquarePainter oldDelegate) => 
    oldDelegate.shimmerValue != shimmerValue;
}

// Occupied cells painter (unchanged)
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
      return RRect.fromRectAndRadius(rect, const Radius.circular(3));
    }

    for (final entry in game.playerPositions.entries) {
      final playerIndex = int.tryParse(entry.key.replaceAll('player', '')) ?? 0;
      final pos = entry.value;
      if (playerIndex < 1 || playerIndex > game.numberOfPlayers) continue;
      if (pos <= 0 || pos > 100) continue;

      final Color? base = game.playerColors[entry.key];
      if (base == null) continue;

      final Color fill = base.withAlpha(70);

      final paint = Paint()
        ..color = fill
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrectForCell(pos), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OccupiedCellsPainter oldDelegate) => true;
}

// ENHANCED Board connections painter (snakes & ladders)
class _EnhancedBoardConnectionsPainter extends CustomPainter {
  final GameService game;
  final double boardSize;
  final double animationValue;

  _EnhancedBoardConnectionsPainter(this.game, this.boardSize, this.animationValue);

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

    // Draw ladders first
    for (final e in game.ladders.entries) {
      final start = centerOf(e.key);
      final int endCell = _endCellOf(e.value);
      final end = centerOf(endCell);
      _drawEnhancedLadder(canvas, start, end, cellSize, e.key);
    }

    // Draw snakes on top
    for (final e in game.snakes.entries) {
      final head = centerOf(e.key);
      final int endCell = _endCellOf(e.value);
      final tail = centerOf(endCell);
      _drawEnhancedSnake(canvas, head, tail, cellSize, e.key, e.value);
    }
  }

  int _endCellOf(dynamic v) {
    if (v is int) return v;
    if (v is Map && v['end'] is int) return v['end'] as int;
    throw StateError('Invalid snake/ladder value: $v');
  }

  void _drawEnhancedLadder(Canvas canvas, Offset start, Offset end, double cellSize, int startPos) {
    // More vibrant ladder colors
    const colorPalettes = [
      [Color(0xFFFF6B9D), Color(0xFFC44569)], // Hot pink
      [Color(0xFF4ECDC4), Color(0xFF44A08D)], // Turquoise
      [Color(0xFFFFE66D), Color(0xFFF9CA24)], // Bright yellow
      [Color(0xFF95E1D3), Color(0xFF38ADA9)], // Mint green
      [Color(0xFFFF9FF3), Color(0xFFDA22FF)], // Vibrant magenta
      [Color(0xFFFECA57), Color(0xFFEE5A6F)], // Peach coral
      [Color(0xFF48DBFB), Color(0xFF0ABDE3)], // Sky blue
      [Color(0xFF00D2D3), Color(0xFF01A3A4)], // Cyan
    ];

    final colorIndex = startPos % colorPalettes.length;
    final colors = colorPalettes[colorIndex];

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;

    final ux = dx / len;
    final uy = dy / len;
    final railWidth = cellSize * 0.11;
    final perp = Offset(-uy, ux) * railWidth;

    // Enhanced shadow
    final shadowPath = Path()
      ..moveTo(start.dx + perp.dx + 2, start.dy + perp.dy + 2)
      ..lineTo(end.dx + perp.dx + 2, end.dy + perp.dy + 2)
      ..lineTo(end.dx - perp.dx + 2, end.dy - perp.dy + 2)
      ..lineTo(start.dx - perp.dx + 2, start.dy - perp.dy + 2)
      ..close();
    
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withAlpha(38)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Gradient for rails
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [colors[0], colors[1]],
    ).createShader(Rect.fromPoints(start, end));

    // Left rail with enhanced styling
    final leftRailPaint = Paint()
      ..shader = gradient
      ..strokeWidth = cellSize * 0.11
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);
    canvas.drawLine(start + perp, end + perp, leftRailPaint);

    // Right rail
    final rightRailPaint = Paint()
      ..shader = gradient
      ..strokeWidth = cellSize * 0.11
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);
    canvas.drawLine(start - perp, end - perp, rightRailPaint);

    // Add white highlight on rails
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(102)
      ..strokeWidth = cellSize * 0.04
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      start + perp - Offset(uy * railWidth * 0.3, -ux * railWidth * 0.3),
      end + perp - Offset(uy * railWidth * 0.3, -ux * railWidth * 0.3),
      highlightPaint,
    );

    // Rungs with gradient and alternating colors
    final rungCount = math.max(3, (len / (cellSize * 0.7)).round());
    for (int i = 0; i <= rungCount; i++) {
      final t = i / rungCount;
      final center = Offset(start.dx + dx * t, start.dy + dy * t);
      
      final rungColor = i % 2 == 0 ? colors[0] : colors[1];
      final rungPaint = Paint()
        ..color = rungColor
        ..strokeWidth = cellSize * 0.09
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(center - perp * 0.92, center + perp * 0.92, rungPaint);
      
      // Rung highlight
      final rungHighlight = Paint()
        ..color = Colors.white.withAlpha(76)
        ..strokeWidth = cellSize * 0.03
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center - perp * 0.92 + Offset(0, -cellSize * 0.02),
        center + perp * 0.92 + Offset(0, -cellSize * 0.02),
        rungHighlight,
      );
    }

    // Decorative stars at top with glow
    final starPositions = [
      Offset(end.dx, end.dy - cellSize * 0.25),
      Offset(end.dx - cellSize * 0.15, end.dy - cellSize * 0.18),
      Offset(end.dx + cellSize * 0.15, end.dy - cellSize * 0.18),
    ];
    
    for (var pos in starPositions) {
      // Glow
      canvas.drawCircle(
        pos,
        cellSize * 0.08,
        Paint()
          ..color = const Color(0xFFFFD700).withAlpha(76)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      // Star
      canvas.drawCircle(
        pos,
        cellSize * 0.06,
        Paint()..color = const Color(0xFFFFD700),
      );
      canvas.drawCircle(
        pos,
        cellSize * 0.03,
        Paint()..color = Colors.white,
      );
    }
  }

  void _drawEnhancedSnake(Canvas canvas, Offset head, Offset tail, double cellSize, int startPos, Map<String, dynamic> snakeData) {
    // Vibrant snake colors
    const snakeColorPalettes = [
      [Color(0xFF2ECC71), Color(0xFF27AE60)], // Emerald
      [Color(0xFFE74C3C), Color(0xFFC0392B)], // Ruby red
      [Color(0xFF9B59B6), Color(0xFF8E44AD)], // Amethyst
      [Color(0xFFF39C12), Color(0xFFE67E22)], // Orange
      [Color(0xFF3498DB), Color(0xFF2980B9)], // Blue
      [Color(0xFFE91E63), Color(0xFFC2185B)], // Pink
      [Color(0xFF00BCD4), Color(0xFF0097A7)], // Cyan
      [Color(0xFFFF5722), Color(0xFFE64A19)], // Deep orange
    ];

    final colorIndex = snakeData['colorIndex'] as int;
    final colors = snakeColorPalettes[colorIndex % snakeColorPalettes.length];
    final darkColor = Color.lerp(colors[1], Colors.black, 0.3)!;

    final distance = (head - tail).distance;
    if (distance == 0) return;

    // Create curved path with wave pattern
    final segments = math.max(25, (distance / (cellSize * 0.25)).round());
    final List<Offset> points = [];
    
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = head.dx + (tail.dx - head.dx) * t;
      final y = head.dy + (tail.dy - head.dy) * t;

      final perpX = -(tail.dy - head.dy) / distance;
      final perpY = (tail.dx - head.dx) / distance;
      final wave = math.sin(t * math.pi * 3) * (cellSize * 0.22);

      points.add(Offset(x + perpX * wave, y + perpY * wave));
    }

    // Draw shadow path
    final shadowPath = Path()..moveTo(points[0].dx + 2, points[0].dy + 2);
    for (int i = 1; i < points.length; i++) {
      shadowPath.lineTo(points[i].dx + 2, points[i].dy + 2);
    }
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withAlpha(51)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = cellSize * 0.22
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Main body path
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Gradient for body
    final bodyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [colors[0], colors[1]],
    ).createShader(Rect.fromPoints(head, tail));

    // Outer dark outline
    canvas.drawPath(
      path,
      Paint()
        ..color = darkColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = cellSize * 0.22,
    );

    // Main body with gradient
    canvas.drawPath(
      path,
      Paint()
        ..shader = bodyGradient
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = cellSize * 0.19,
    );

    // Highlight line on top
    final highlightPath = Path()..moveTo(points[0].dx, points[0].dy - cellSize * 0.04);
    for (int i = 1; i < points.length; i++) {
      highlightPath.lineTo(points[i].dx, points[i].dy - cellSize * 0.04);
    }
    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = Colors.white.withAlpha(89)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = cellSize * 0.05,
    );

    // Pattern spots along body
    for (int i = 0; i < segments; i += 3) {
      if (i >= points.length) break;
      final point = points[i];
      
      // Spot with gradient
      final spotGradient = RadialGradient(
        colors: [
          Colors.white.withAlpha(102),
          darkColor.withAlpha(127),
        ],
      ).createShader(Rect.fromCircle(center: point, radius: cellSize * 0.06));
      
      canvas.drawCircle(
        point,
        cellSize * 0.06,
        Paint()..shader = spotGradient,
      );
    }

    // Enhanced head
    final headSize = cellSize * 0.20;
    
    // Head glow
    canvas.drawCircle(
      head,
      headSize + 3,
      Paint()
        ..color = colors[0].withAlpha(76)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    
    // Head gradient
    final headGradient = RadialGradient(
      colors: [colors[0], colors[1]],
      center: const Alignment(-0.3, -0.3),
    ).createShader(Rect.fromCircle(center: head, radius: headSize));
    
    canvas.drawCircle(head, headSize, Paint()..shader = headGradient);
    
    // Head outline
    canvas.drawCircle(
      head,
      headSize,
      Paint()
        ..color = darkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.04,
    );

    // Eyes with more detail
    final eyeSize = cellSize * 0.05;
    final eyeOffsetX = headSize * 0.35;
    final eyeOffsetY = -headSize * 0.35;
    
    // Left eye
    canvas.drawCircle(
      head + Offset(-eyeOffsetX, eyeOffsetY),
      eyeSize,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      head + Offset(-eyeOffsetX, eyeOffsetY),
      eyeSize * 0.6,
      Paint()..color = Colors.black,
    );
    canvas.drawCircle(
      head + Offset(-eyeOffsetX - eyeSize * 0.2, eyeOffsetY - eyeSize * 0.2),
      eyeSize * 0.25,
      Paint()..color = Colors.white,
    );
    
    // Right eye
    canvas.drawCircle(
      head + Offset(eyeOffsetX, eyeOffsetY),
      eyeSize,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      head + Offset(eyeOffsetX, eyeOffsetY),
      eyeSize * 0.6,
      Paint()..color = Colors.black,
    );
    canvas.drawCircle(
      head + Offset(eyeOffsetX - eyeSize * 0.2, eyeOffsetY - eyeSize * 0.2),
      eyeSize * 0.25,
      Paint()..color = Colors.white,
    );

    // Forked tongue
    final tongueLength = headSize * 0.8;
    final tonguePaint = Paint()
      ..color = const Color(0xFFE74C3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.025
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      head + Offset(0, headSize * 0.6),
      head + Offset(-tongueLength * 0.4, headSize + tongueLength * 0.6),
      tonguePaint,
    );
    canvas.drawLine(
      head + Offset(0, headSize * 0.6),
      head + Offset(tongueLength * 0.4, headSize + tongueLength * 0.6),
      tonguePaint,
    );

    // Enhanced tail
    final tailSize = cellSize * 0.12;
    
    // Tail glow
    canvas.drawCircle(
      tail,
      tailSize + 2,
      Paint()
        ..color = colors[1].withAlpha(51)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    
    canvas.drawCircle(tail, tailSize, Paint()..color = colors[1]);
    canvas.drawCircle(
      tail,
      tailSize,
      Paint()
        ..color = darkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.03,
    );
    canvas.drawCircle(tail, tailSize * 0.5, Paint()..color = darkColor.withAlpha(127));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}