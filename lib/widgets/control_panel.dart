// lib/widgets/control_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import 'dart:async';

typedef NotifyCallback = void Function(String message, String icon);

class ControlPanel extends StatefulWidget {
  final NotifyCallback onNotify;
  const ControlPanel({required this.onNotify, super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> with SingleTickerProviderStateMixin {
  late AnimationController _diceController;
  late Animation<double> _diceRotation;

  @override
  void initState() {
    super.initState();
    _diceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _diceRotation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _diceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _diceController.dispose();
    super.dispose();
  }

  // Auto-play for bot
  Future<void> _handleBotTurn(GameService game) async {
    if (!game.isCurrentPlayerBot() || !game.gameActive) return;
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!mounted || !game.gameActive) return;
    
    _diceController.forward(from: 0);
    final roll = await game.rollDice();
    if (roll == 0) return;
    
    widget.onNotify('🤖 Bot rolled $roll', '🎲');
    await game.movePlayer(game.currentPlayer, roll, onNotify: widget.onNotify);
    
    // Continue if still bot's turn
    if (mounted && game.gameActive) {
      _handleBotTurn(game);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameService>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final diceSize = (screenWidth * 0.16).clamp(80.0, 110.0);

    // Auto-play bot turn
    if (game.isCurrentPlayerBot() && game.gameActive && !game.isRolling) {
      Future.microtask(() => _handleBotTurn(game));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Players info - Uniform layout for 2 or 3 players
          if (game.numberOfPlayers == 2)
            Row(
              children: [
                Expanded(
                  child: _playerCard(
                    game.playerNames['player1']!,
                    game.playerPositions['player1']!,
                    game.playerScores['player1']!,
                    game.playerColors['player1']!,
                    isActive: game.currentPlayer == 'player1',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _playerCard(
                    game.playerNames['player2']!,
                    game.playerPositions['player2']!,
                    game.playerScores['player2']!,
                    game.playerColors['player2']!,
                    isActive: game.currentPlayer == 'player2',
                  ),
                ),
              ],
            )
          else
            // Three players - all uniform size
            Row(
              children: [
                Expanded(
                  child: _playerCard(
                    game.playerNames['player1']!,
                    game.playerPositions['player1']!,
                    game.playerScores['player1']!,
                    game.playerColors['player1']!,
                    isActive: game.currentPlayer == 'player1',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _playerCard(
                    game.playerNames['player2']!,
                    game.playerPositions['player2']!,
                    game.playerScores['player2']!,
                    game.playerColors['player2']!,
                    isActive: game.currentPlayer == 'player2',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _playerCard(
                    game.playerNames['player3']!,
                    game.playerPositions['player3']!,
                    game.playerScores['player3']!,
                    game.playerColors['player3']!,
                    isActive: game.currentPlayer == 'player3',
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Enhanced Professional Dice
          Center(
            child: GestureDetector(
              onTap: () async {
                if (!game.gameActive) {
                  widget.onNotify('Start a game first', '⚠️');
                  return;
                }
                if (game.isRolling || game.isCurrentPlayerBot()) return;
                
                _diceController.forward(from: 0);
                final roll = await game.rollDice();
                if (roll == 0) return;
                await game.movePlayer(game.currentPlayer, roll, onNotify: widget.onNotify);
              },
              child: AnimatedBuilder(
                animation: _diceRotation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: game.isRolling ? _diceRotation.value : 0,
                    child: Container(
                      width: diceSize,
                      height: diceSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.grey.shade50,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: game.isCurrentPlayerBot() 
                              ? Colors.grey.shade400
                              : game.playerColors[game.currentPlayer]!,
                          width: 3.5,
                        ),
                        boxShadow: [
                          const BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 15,
                            spreadRadius: 0,
                            offset: Offset(0, 5),
                          ),
                          BoxShadow(
                            color: (game.isCurrentPlayerBot() 
                                ? Colors.grey.shade400
                                : game.playerColors[game.currentPlayer]!).withAlpha(76),
                            blurRadius: 25,
                            spreadRadius: -3,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: game.isRolling
                          ? Center(
                              child: Icon(
                                Icons.casino_outlined,
                                color: game.playerColors[game.currentPlayer]!,
                                size: diceSize * 0.5,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (game.lastRoll > 0)
                                  _buildStandardDiceFace(
                                    game.lastRoll, 
                                    diceSize * 0.65,
                                    game.isCurrentPlayerBot() 
                                        ? Colors.grey.shade400
                                        : game.playerColors[game.currentPlayer]!,
                                  )
                                else
                                  Icon(
                                    Icons.casino_outlined,
                                    size: diceSize * 0.45,
                                    color: Colors.grey.shade400,
                                  ),
                                SizedBox(height: diceSize * 0.08),
                                Text(
                                  game.lastRoll > 0 ? '${game.lastRoll}' : 'Roll',
                                  style: TextStyle(
                                    fontSize: diceSize * 0.16,
                                    color: game.isCurrentPlayerBot()
                                        ? Colors.grey.shade600
                                        : game.playerColors[game.currentPlayer]!,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardDiceFace(int number, double size, Color dotColor) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StandardDicePainter(number, dotColor),
      ),
    );
  }

  Widget _playerCard(String title, int position, int score, Color color, {required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        gradient: isActive 
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withAlpha(38),
                  color.withAlpha(13),
                ],
              )
            : null,
        color: isActive ? null : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color : Colors.grey.shade300,
          width: isActive ? 2.5 : 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withAlpha(76),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isActive ? color : Colors.black87,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            'Pos: ${position == 0 ? 'Start' : position}',
            style: TextStyle(
              fontSize: 11, 
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('❤️', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 3),
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StandardDicePainter extends CustomPainter {
  final int number;
  final Color dotColor;
  
  _StandardDicePainter(this.number, this.dotColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final dotRadius = size.width * 0.10;
    final margin = size.width * 0.22;

    void drawDot(double x, double y) {
      // Shadow for 3D effect
      canvas.drawCircle(
        Offset(x + 1, y + 1), 
        dotRadius, 
        Paint()..color = const Color(0x26000000)
      );
      // Main dot
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
      // Highlight
      canvas.drawCircle(
        Offset(x - dotRadius * 0.3, y - dotRadius * 0.3), 
        dotRadius * 0.3, 
        Paint()..color = const Color(0x66FFFFFF)
      );
    }

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final left = margin;
    final right = size.width - margin;
    final top = margin;
    final bottom = size.height - margin;

    switch (number) {
      case 1:
        drawDot(centerX, centerY);
        break;
      case 2:
        drawDot(left, top);
        drawDot(right, bottom);
        break;
      case 3:
        drawDot(left, top);
        drawDot(centerX, centerY);
        drawDot(right, bottom);
        break;
      case 4:
        drawDot(left, top);
        drawDot(right, top);
        drawDot(left, bottom);
        drawDot(right, bottom);
        break;
      case 5:
        drawDot(left, top);
        drawDot(right, top);
        drawDot(centerX, centerY);
        drawDot(left, bottom);
        drawDot(right, bottom);
        break;
      case 6:
        drawDot(left, top);
        drawDot(right, top);
        drawDot(left, centerY);
        drawDot(right, centerY);
        drawDot(left, bottom);
        drawDot(right, bottom);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}