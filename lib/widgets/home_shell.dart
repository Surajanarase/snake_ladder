// lib/widgets/home_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import 'board_widget.dart';
import 'control_panel.dart';
import 'progress_dashboard.dart';
import 'dart:math' as math;
import '../services/sound_service.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  bool _showStartScreen = true;
  bool _suppressWinOverlay = false;

  // Show a small dialog to collect player names before starting.
  void _showNameEntry(BuildContext context, int numPlayers, bool withBot) {
    final game = Provider.of<GameService>(context, listen: false);
    final controllers = <TextEditingController>[];
    for (int i = 1; i <= numPlayers; i++) {
      final defaultName = game.playerNames['player$i'] ?? '👤 Player $i';
      controllers.add(TextEditingController(text: defaultName));
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter player names',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  for (int i = 0; i < controllers.length; i++) ...[
                    TextField(
                      controller: controllers[i],
                      decoration: InputDecoration(
                        labelText: 'Player ${i + 1} name',
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Back'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Save names and start game
                          for (int i = 0; i < controllers.length; i++) {
                            final name = controllers[i].text.trim();
                            if (name.isNotEmpty) {
                              game.playerNames['player${i + 1}'] = name;
                            }
                          }
                          setState(() => _showStartScreen = false);
                          game.startGame(numPlayers, withBot);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF667eea)),
                        child: const Text('Start'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameService>(context);
    final screenWidth = MediaQuery.of(context).size.width;

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
              constraints: BoxConstraints(maxWidth: math.max(560, screenWidth)),
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
                    // Main game content
                    Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                          ),
                          child: // Replace the header Row with this:
Row(
  children: [
    Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text('❤️', style: TextStyle(fontSize: 22)),
    ),
    const SizedBox(width: 12),
    const Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Heroes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'Learn & Play',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
    // Sound toggle button
    GestureDetector(
      onTap: () {
        setState(() {
          SoundService().toggleSound();
        });
      },
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(51),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Icon(
            SoundService().soundEnabled ? Icons.volume_up : Icons.volume_off,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    ),
    GestureDetector(
      onTap: () => _showLegend(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(51),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Center(
          child: Icon(
            Icons.help_outline,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    ),
  ],
)
                          ),

                        // Scrollable content area
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Board area
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  child: AspectRatio(
                                    aspectRatio: 1.0,
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
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                Colors.grey.shade50,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 40),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF667eea).withAlpha(102),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: const Text('🏥', style: TextStyle(fontSize: 60)),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Health Heroes',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF667eea).withAlpha(38),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Learn health tips while playing!',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF667eea),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(25),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Select Game Mode',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        _buildGameModeButton(
                                          context,
                                          '👥 2 Players',
                                          'Play with a friend',
                                          const Color(0xFF4A90E2),
                                          Icons.people,
                                          () => _showNameEntry(context, 2, false),
                                        ),
                                        const SizedBox(height: 12),
                                        _buildGameModeButton(
                                          context,
                                          '👥👤 3 Players',
                                          'More friends, more fun!',
                                          const Color(0xFF2ECC71),
                                          Icons.groups,
                                          () => _showNameEntry(context, 3, false),
                                        ),
                                        const SizedBox(height: 12),
                                        _buildGameModeButton(
                                          context,
                                          '🤖 Play with AI Bot',
                                          'Challenge the computer',
                                          const Color(0xFFE74C3C),
                                          Icons.smart_toy,
                                          () {
                                            setState(() => _showStartScreen = false);
                                            game.startGame(2, true);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Win overlay
                    if (!game.gameActive && !_showStartScreen && game.getWinner() != null && !_suppressWinOverlay)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(217),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Container(
                              margin: const EdgeInsets.all(24),
                              padding: const EdgeInsets.all(28),
                              constraints: BoxConstraints(
                                maxWidth: screenWidth - 48,
                                maxHeight: MediaQuery.of(context).size.height - 100,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(76),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFFD700).withAlpha(102),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: const Text('🏆', style: TextStyle(fontSize: 60)),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      '${game.playerNames[game.getWinner()]} Wins!',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2C3E50),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      '🎉 Congratulations! 🎉',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF7F8C8D),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.grey.shade50,
                                            Colors.grey.shade100,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          _statRow('🏅 Winner', game.playerNames[game.getWinner()]!),
                                          const Divider(height: 20),
                                          _statRow('❤️ Health Points', '${game.playerScores[game.getWinner()]}'),
                                          const Divider(height: 20),
                                          _statRow('🎲 Total Moves', '${game.moveCount}'),
                                          const Divider(height: 20),
                                          _statRow('📚 Knowledge Gained', '${game.getTotalKnowledgeProgress()}%'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Responsive button layout
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        if (constraints.maxWidth < 400) {
                                          // Stack buttons vertically on small screens
                                          return Column(
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _suppressWinOverlay = true;
                                                    });
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.grey.shade300,
                                                    foregroundColor: Colors.black87,
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  child: const Text('Close (Stay)'),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _suppressWinOverlay = false;
                                                    });
                                                    game.resetGame();
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF667eea),
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  child: const Text('Play Again'),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    game.resetGame();
                                                    setState(() {
                                                      _showStartScreen = true;
                                                      _suppressWinOverlay = false;
                                                    });
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF9E9E9E),
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  child: const Text('Back to Home'),
                                                ),
                                              ),
                                            ],
                                          );
                                        } else {
                                          // Show buttons horizontally on larger screens
                                          return Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _suppressWinOverlay = true;
                                                    });
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.grey.shade300,
                                                    foregroundColor: Colors.black87,
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  child: const Text('Close', style: TextStyle(fontSize: 13)),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _suppressWinOverlay = false;
                                                    });
                                                    game.resetGame();
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF667eea),
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  child: const Text('Play Again', style: TextStyle(fontSize: 13)),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    game.resetGame();
                                                    setState(() {
                                                      _showStartScreen = true;
                                                      _suppressWinOverlay = false;
                                                    });
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF9E9E9E),
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  child: const Text('Home', style: TextStyle(fontSize: 13)),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
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

  Widget _buildGameModeButton(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              color.withAlpha(217),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(76),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(217),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
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
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Game Guide',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _legendItem('🎲', 'How to Play', 'Tap the dice to roll. Race to reach square 100 first!'),
                  _legendItem('🪜', 'Colorful Ladders', 'Good health choices that move you forward and earn health points.'),
                  _legendItem('🐍', 'Colorful Snakes', 'Poor health choices that set you back. Learn from them!'),
                  _legendItem('❤️', 'Health Points', 'Earn points by landing on ladders and learning health tips.'),
                  _legendItem('🎯', 'Dynamic Board', 'Each new game has different snake and ladder positions!'),
                  _legendItem('🤖', 'AI Bot Mode', 'Play against the computer for a challenge!'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Got it!'),
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withAlpha(38),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showToast(BuildContext context, String message, String icon) {
    final game = Provider.of<GameService>(context, listen: false);

    if (message.startsWith('REWARD::')) {
      try {
        final parts = message.split('::');
        if (parts.length >= 3) {
          if (parts.length >= 4 && parts[1].startsWith('player')) {
            final playerId = parts[1];
            final category = parts[2];
            final rewardText = parts.sublist(3).join('::');

            game.addRewardForPlayer(playerId, category, rewardText);

            if (!mounted) return;
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 12),
                        Text(
                          '${game.playerNames[playerId]} earned a reward!',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667eea),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          rewardText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          ),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
            return;
          } else {
            final category = parts[1];
final rewardText = parts.sublist(2).join('::');
final playerId = game.currentPlayer;           // or pick a specific player if you prefer
game.addRewardForPlayer(playerId, category, rewardText);  // ✅ new API

            if (!mounted) return;
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 12),
                        Text(
                          rewardText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          ),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
            return;
          }
        }
      } catch (_) {
        // If parsing fails, fall back to snackbar below
      }
    }

    // default behavior: floating SnackBar
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withAlpha(38),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        elevation: 8,
      ),
    );
  }
}