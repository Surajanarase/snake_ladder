// lib/widgets/home_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import 'board_widget.dart';
import 'control_panel.dart';
import 'progress_dashboard.dart';
import 'dart:math' as math;

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  bool _showStartScreen = true;

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameService>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: math.max(560, MediaQuery.of(context).size.width)),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 40, offset: Offset(0, 20)),
                  ],
                ),
                child: Stack(
                  children: [
                    // Main game content with SingleChildScrollView for full visibility
                    Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: const Text('❤️', style: TextStyle(fontSize: 20)),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Health Heroes',
                                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showLegend(context),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '?',
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Scrollable content area
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Board area - now with proper sizing
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  child: AspectRatio(
                                    aspectRatio: 1.0, // Perfect square
                                    child: BoardWidget(),
                                  ),
                                ),

                                // Control Panel
                                ControlPanel(onNotify: (m, i) => _showToast(context, m, i)),

                                // Progress Dashboard
                                const ProgressDashboard(),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Start screen overlay
                    if (_showStartScreen)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🏥', style: TextStyle(fontSize: 72)),
                              const SizedBox(height: 18),
                              const Text('Health Heroes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                              const SizedBox(height: 8),
                              const Text('Learn health tips while playing!', style: TextStyle(fontSize: 16, color: Colors.black54)),
                              const SizedBox(height: 22),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() => _showStartScreen = false);
                                      game.startGame('easy');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      backgroundColor: const Color(0xFF667eea),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Easy AI', style: TextStyle(fontSize: 16)),
                                  ),
                                  const SizedBox(width: 14),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() => _showStartScreen = false);
                                      game.startGame('hard');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      backgroundColor: const Color(0xFF764ba2),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Smart AI', style: TextStyle(fontSize: 16)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Win overlay
                    if (!game.gameActive && !_showStartScreen && (game.humanPosition == 100 || game.aiPosition == 100))
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Container(
                              margin: const EdgeInsets.all(24),
                              padding: const EdgeInsets.all(26),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🏆', style: TextStyle(fontSize: 72)),
                                    const SizedBox(height: 14),
                                    Text(
                                      game.humanPosition == 100 ? 'You Win! 🎉' : 'AI Wins! Try Again!',
                                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 14),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(color: const Color(0xFFf8f9fa), borderRadius: BorderRadius.circular(10)),
                                      child: Column(
                                        children: [
                                          _statRow('Winner:', game.humanPosition == 100 ? '👤 You' : '🤖 Health Bot'),
                                          const SizedBox(height: 8),
                                          _statRow('Health Points:', '${game.humanPosition == 100 ? game.humanScore : game.aiScore}'),
                                          const SizedBox(height: 8),
                                          _statRow('Moves Taken:', '${game.moveCount}'),
                                          const SizedBox(height: 8),
                                          _statRow('Knowledge Gained:', '${game.getTotalKnowledgeProgress()}%'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() => _showStartScreen = true);
                                        game.resetGame();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                        backgroundColor: const Color(0xFF667eea),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Play Again', style: TextStyle(fontSize: 16)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
    ]);
  }

  void _showLegend(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Game Guide', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _legendItem('🎲', 'How to Play', 'Tap the dice to roll. Race to reach square 100.'),
                  _legendItem('🪜', 'Green Ladders', 'Good health choices that move you forward.'),
                  _legendItem('🐍', 'Green Snakes', 'Poor health choices that set you back.'),
                  _legendItem('❤️', 'Health Points', 'Earn points by landing on ladders.'),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF667eea)),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _legendItem(String icon, String label, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFf8f9fa), borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showToast(BuildContext context, String message, String icon) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        elevation: 8,
      ),
    );
  }
}