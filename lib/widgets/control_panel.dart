// lib/widgets/control_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameService>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final diceSize = (screenWidth * 0.18).clamp(70.0, 120.0);

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Players info
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
            Column(
              children: [
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
                ),
                const SizedBox(height: 10),
                _playerCard(
                  game.playerNames['player3']!,
                  game.playerPositions['player3']!,
                  game.playerScores['player3']!,
                  game.playerColors['player3']!,
                  isActive: game.currentPlayer == 'player3',
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Enhanced Dice
          Center(
            child: GestureDetector(
              onTap: () async {
                if (!game.gameActive) {
                  widget.onNotify('Start a game first', '⚠️');
                  return;
                }
                if (game.isRolling) return;
                
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
                            game.playerColors[game.currentPlayer]!,
                            game.playerColors[game.currentPlayer]!.withAlpha((0.7 * 255).round()),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: game.playerColors[game.currentPlayer]!.withAlpha((0.4 * 255).round()),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: game.isRolling
                          ? const Center(
                              child: Icon(
                                Icons.casino,
                                color: Colors.white,
                                size: 50,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (game.lastRoll > 0)
                                  _buildDiceFace(game.lastRoll, diceSize * 0.7)
                                else
                                  Icon(
                                    Icons.casino,
                                    size: diceSize * 0.5,
                                    color: Colors.white,
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  game.lastRoll > 0 ? 'Roll: ${game.lastRoll}' : 'Roll Dice',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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

  Widget _buildDiceFace(int number, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _DiceDotsPainter(number),
      ),
    );
  }

  Widget _playerCard(String title, int position, int score, Color color, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? color.withAlpha((0.15 * 255).round()) : const Color(0xFFf8f9fa),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? color : Colors.transparent,
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withAlpha((0.3 * 255).round()),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isActive ? color : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Position: ${position == 0 ? 'Start' : position}',
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('❤️', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
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

class _DiceDotsPainter extends CustomPainter {
  final int number;
  
  _DiceDotsPainter(this.number);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final dotRadius = size.width * 0.08;
    final spacing = size.width * 0.3;

    void drawDot(double x, double y) {
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    switch (number) {
      case 1:
        drawDot(centerX, centerY);
        break;
      case 2:
        drawDot(centerX - spacing, centerY - spacing);
        drawDot(centerX + spacing, centerY + spacing);
        break;
      case 3:
        drawDot(centerX - spacing, centerY - spacing);
        drawDot(centerX, centerY);
        drawDot(centerX + spacing, centerY + spacing);
        break;
      case 4:
        drawDot(centerX - spacing, centerY - spacing);
        drawDot(centerX + spacing, centerY - spacing);
        drawDot(centerX - spacing, centerY + spacing);
        drawDot(centerX + spacing, centerY + spacing);
        break;
      case 5:
        drawDot(centerX - spacing, centerY - spacing);
        drawDot(centerX + spacing, centerY - spacing);
        drawDot(centerX, centerY);
        drawDot(centerX - spacing, centerY + spacing);
        drawDot(centerX + spacing, centerY + spacing);
        break;
      case 6:
        drawDot(centerX - spacing, centerY - spacing);
        drawDot(centerX + spacing, centerY - spacing);
        drawDot(centerX - spacing, centerY);
        drawDot(centerX + spacing, centerY);
        drawDot(centerX - spacing, centerY + spacing);
        drawDot(centerX + spacing, centerY + spacing);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
