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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Players info
        Row(
          children: [
            Expanded(child: _playerCard('👤 You', game.humanPosition, game.humanScore, isActive: game.currentPlayer == 'human')),
            const SizedBox(width: 8),
            Expanded(child: _playerCard('🤖 Health Bot', game.aiPosition, game.aiScore, isActive: game.currentPlayer == 'ai')),
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
              widget.onNotify('You rolled $roll', '🎲');
              game.movePlayer('human', roll, onNotify: widget.onNotify);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(blurRadius: 8, offset: Offset(0, 6), color: Colors.black26)],
              ),
              alignment: Alignment.center,
              child: game.isRolling ? const CircularProgressIndicator(color: Colors.white) : const Text('🎲', style: TextStyle(fontSize: 36)),
            ),
          ),
        ),

        const SizedBox(height: 18),

        const Text('Your Health Knowledge', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // Health categories
        Expanded(
          child: GridView(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 3),
            children: [
              _categoryCard('🍎', 'Nutrition', game.healthProgress['nutrition'] ?? 0),
              _categoryCard('💪', 'Exercise', game.healthProgress['exercise'] ?? 0),
              _categoryCard('😴', 'Sleep', game.healthProgress['sleep'] ?? 0),
              _categoryCard('🧘', 'Mental', game.healthProgress['mental'] ?? 0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _playerCard(String title, int position, int score, {required bool isActive}) {
    return Card(
      color: isActive ? Colors.deepPurple.shade50 : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Position: ${position == 0 ? 'Start' : position}'),
            const SizedBox(height: 6),
            Text('❤️ $score', style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _categoryCard(String icon, String name, int value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: value / 100, minHeight: 8),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('$value%'),
          ],
        ),
      ),
    );
  }
}
