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

class _ControlPanelState extends State<ControlPanel> {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameService>(context);

    // Responsive dice size
    final screenWidth = MediaQuery.of(context).size.width;
    final diceSize = (screenWidth * 0.16).clamp(56.0, 110.0);

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Players info
          Row(
            children: [
              Expanded(
                child: _playerCard(
                  '👤 You',
                  game.humanPosition,
                  game.humanScore,
                  isActive: game.currentPlayer == 'human',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _playerCard(
                  '🤖 Health Bot',
                  game.aiPosition,
                  game.aiScore,
                  isActive: game.currentPlayer == 'ai',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Dice
          Center(
            child: GestureDetector(
              onTap: () async {
                if (!game.gameActive) {
                  widget.onNotify('Start a game first', '⚠️');
                  return;
                }
                if (game.isRolling || game.currentPlayer != 'human') return;
                final roll = await game.rollDice();
                if (roll == 0) return;
                await game.movePlayer('human', roll, onNotify: widget.onNotify);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: diceSize,
                height: diceSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 12,
                      offset: Offset(0, 6),
                      color: Colors.black26,
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: game.isRolling
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            game.lastRoll > 0 ? game.getDiceEmoji(game.lastRoll) : '🎲',
                            style: TextStyle(fontSize: diceSize * 0.45),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap to roll',
                            style: TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerCard(String title, int position, int score, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF3E5F5) : const Color(0xFFf8f9fa),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? const Color(0xFF667eea) : Colors.transparent,
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF667eea).withAlpha((0.12 * 255).round()),

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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Position: ${position == 0 ? 'Start' : position}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            '❤️ $score',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
          ),
        ],
      ),
    );
  }
}
