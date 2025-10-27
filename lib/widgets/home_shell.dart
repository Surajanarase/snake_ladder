// lib/widgets/home_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import 'board_widget.dart';
import 'control_panel.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameService>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFf2f4fb),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Card(
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 14,
              child: Column(
                children: [
                  // Header
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(child: Text('❤️')),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Health Heroes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showLegend(context),
                          icon: const Icon(Icons.info_outline, color: Colors.white),
                        )
                      ],
                    ),
                  ),

                  // Main area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Board
                          const Expanded(flex: 6, child: BoardWidget()),

                          const SizedBox(width: 12),

                          // Control panel
                          Expanded(
                            flex: 4,
                            child: ControlPanel(
                              onNotify: (m, i) => _showToast(context, m, i),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => game.resetGame(),
                          icon: const Icon(Icons.replay),
                          label: const Text('Reset'),
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => game.startGame('easy'),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Easy'),
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => game.startGame('hard'),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Smart'),
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                          ),
                        ),
                        const Spacer(),
                        Text('Moves: ${game.moveCount}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

 void _showLegend(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Game Guide'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Text('🎲'),
              title: Text('Click dice to roll. Race to 100!'),
            ),
            ListTile(
              leading: Text('🪜'),
              title: Text('Green cells - Ladders (health boosts)'),
            ),
            ListTile(
              leading: Text('🐍'),
              title: Text('Red cells - Snakes (setbacks)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}



  void _showToast(BuildContext context, String message, String icon) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
