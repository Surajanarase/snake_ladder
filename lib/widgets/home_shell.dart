// lib/widgets/home_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../database/database_helper.dart';
import 'board_widget.dart';
import 'control_panel.dart';
import 'dart:math' as math;
import '../services/sound_service.dart';
import 'quiz_dialog.dart';
import 'knowledge_byte_dialog.dart';
import 'dart:async';

class HomeShell extends StatefulWidget {
  final int numPlayers;
  final bool withBot;
  final GameMode mode;

  const HomeShell({
    super.key,
    required this.numPlayers,
    required this.withBot,
    required this.mode,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  bool _suppressWinOverlay = false;
  late DateTime _gameStartTime;
  //Map<String, int> _initialQuizStats = {}; // ✅ Add this line - declare the field

  @override
  void initState() {
    super.initState();
    _gameStartTime = DateTime.now();
    
    // Start game after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ Remove unused 'game' variable from here
      _showNameEntry(context, widget.numPlayers, widget.withBot, widget.mode);
    });
  }

  // Show a dialog to collect player names before starting
  void _showNameEntry(BuildContext context, int numPlayers, bool withBot, GameMode mode) {
    final game = Provider.of<GameService>(context, listen: false);
    final controllers = <TextEditingController>[];
    
    for (int i = 1; i <= numPlayers; i++) {
      if (withBot && i == numPlayers) {
        // Don't create controller for bot
        continue;
      }
      final defaultName = game.playerNames['player$i'] ?? 'Player $i';
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (int i = 0; i < controllers.length; i++) ...[
                    TextField(
                      controller: controllers[i],
                      decoration: InputDecoration(
                        labelText: 'Player ${i + 1} name',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (withBot) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.smart_toy, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Player 2: AI Bot',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
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
                          Navigator.of(context).pop(); // Go back to home page
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Set player names
                          for (int i = 0; i < controllers.length; i++) {
                            final name = controllers[i].text.trim();
                            if (name.isNotEmpty) {
                              game.playerNames['player${i + 1}'] = name;
                            }
                          }
                          
                          // Store initial quiz stats
                         // _storeInitialQuizStats(game);
                          
                          // Start the game
                          game.startGame(numPlayers, withBot, mode);
                          _gameStartTime = DateTime.now();
                          
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                        ),
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

  //void _storeInitialQuizStats(GameService game) {
    // ✅ Now this will work because _initialQuizStats is declared
    //_initialQuizStats = {
     // 'player1_correct': 0,
     // 'player1_total': 0,
   // };
 // }

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
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 40,
                      offset: Offset(0, 20),
                    ),
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
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: () {
                                  _showExitConfirmation();
                                },
                              ),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      SoundService().soundEnabled 
                                          ? Icons.volume_up 
                                          : Icons.volume_off,
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
                                    color: Colors.white.withValues(alpha: 0.2),
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
                          ),
                        ),

                        // Scrollable content area
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Board area
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 4,
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final size = constraints.maxWidth * 1.08;
                                      return Center(
                                        child: SizedBox(
                                          width: size,
                                          height: size,
                                          child: const BoardWidget(),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Control Panel
                                ControlPanel(
                                  onNotify: (m, i) => _showToast(context, m, i),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Win overlay
                    if (!game.gameActive && game.getWinner() != null && !_suppressWinOverlay)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.85),
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
                                    color: Colors.black.withValues(alpha: 0.3),
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
                                            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        '🏆',
                                        style: TextStyle(fontSize: 60),
                                      ),
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
                                          _statRow('🪙 Total Coins', '${game.playerCoins[game.getWinner()]}'),
                                          const Divider(height: 20),
                                          _statRow('😊 Good Habits', '${game.playerGoodHabits[game.getWinner()]}'),
                                          const Divider(height: 20),
                                          _statRow('🎲 Total Moves', '${game.moveCount}'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Responsive button layout
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        if (constraints.maxWidth < 400) {
                                          // Stack buttons vertically
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
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(16),
                                                    ),
                                                  ),
                                                  child: const Text('Close (Stay)'),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    await _saveGameResult(game);
                                                    setState(() {
                                                      _suppressWinOverlay = false;
                                                    });
                                                    game.resetGame();
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF667eea),
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(16),
                                                    ),
                                                  ),
                                                  child: const Text('Play Again'),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    await _saveGameResult(game);
                                                    if (context.mounted) {
                                                      Navigator.of(context).pop();
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF9E9E9E),
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(16),
                                                    ),
                                                  ),
                                                  child: const Text('Back to Home'),
                                                ),
                                              ),
                                            ],
                                          );
                                        } else {
                                          // Show buttons horizontally
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
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 12,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(16),
                                                    ),
                                                  ),
                                                  child: const Text('Close', style: TextStyle(fontSize: 13)),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    await _saveGameResult(game);
                                                    setState(() {
                                                      _suppressWinOverlay = false;
                                                    });
                                                    game.resetGame();
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF667eea),
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 12,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(16),
                                                    ),
                                                  ),
                                                  child: const Text('Play Again', style: TextStyle(fontSize: 13)),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    await _saveGameResult(game);
                                                    if (context.mounted) {
                                                      Navigator.of(context).pop();
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF9E9E9E),
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 12,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(16),
                                                    ),
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

  Future<void> _saveGameResult(GameService game) async {
    final winner = game.getWinner();
    if (winner == null) return;

    final duration = DateTime.now().difference(_gameStartTime);
    
    // Calculate quiz stats for player1
    int quizCorrect = 0;
    int quizTotal = 0;
    final stats = game.playerQuizStats['player1'];
    if (stats != null) {
      for (var categoryStats in stats.values) {
        quizCorrect += categoryStats.correctAnswers;
        quizTotal += categoryStats.totalAttempts;
      }
    }

    await DatabaseHelper.instance.updateGameResult(
      gameMode: game.currentMode == GameMode.quiz ? 'quiz' : 'knowledge',
      opponentType: widget.withBot ? 'bot' : 'player',
      won: winner == 'player1',
      playerPosition: game.playerPositions['player1'] ?? 0,
      opponentPosition: game.playerPositions['player2'] ?? 0,
      coinsEarned: game.playerCoins['player1'] ?? 0,
      goodHabits: game.playerGoodHabits['player1'] ?? 0,
      badHabits: game.playerBadHabits['player1'] ?? 0,
      quizCorrect: quizCorrect,
      quizTotal: quizTotal,
      durationSeconds: duration.inSeconds,
    );

    // Update quiz stats in database
    if (game.currentMode == GameMode.quiz && stats != null) {
      for (var entry in stats.entries) {
        final category = entry.key;
        final categoryStats = entry.value;
        for (int i = 0; i < categoryStats.totalAttempts; i++) {
          await DatabaseHelper.instance.updateQuizStats(
            category,
            i < categoryStats.correctAnswers,
          );
        }
      }
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exit Game?'),
        content: const Text('Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
            ),
            child: const Text('Exit'),
          ),
        ],
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
                  _legendItem('🪜', 'Colorful Ladders', 'Good health choices that move you forward and earn coins.'),
                  _legendItem('🐍', 'Colorful Snakes', 'Poor health choices that set you back. Learn from them!'),
                  _legendItem('🧠', 'Quiz Mode', 'Answer questions to climb ladders or avoid snakes.'),
                  _legendItem('📚', 'Knowledge Mode', 'Learn health DOs and DON\'Ts automatically.'),
                  _legendItem('💡', 'Advice Squares', 'Land on special tiles for health advice and +5 coins!'),
                  _legendItem('⚡', 'Action Challenges', 'Complete physical challenges for bonus steps!'),
                  _legendItem('🪙', 'Coins', 'Earn coins through quizzes, challenges, and good health habits!'),
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
              color: const Color(0xFF667eea).withValues(alpha: 0.15),
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

    void Function(String, String) makeCallback() {
      return (msg, ic) {
        if (mounted) {
          _showToast(context, msg, ic);
        }
      };
    }

    // Handle LADDER_QUIZ trigger
    if (message.startsWith('LADDER_QUIZ::')) {
      try {
        final parts = message.split('::');
        if (parts.length >= 4) {
          final playerId = parts[1];
          final position = int.parse(parts[2]);
          final category = parts[3];
          
          final question = game.getRandomQuizQuestion(category);
          
          if (!mounted) return;
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return QuizDialog(
                player: playerId,
                playerName: game.playerNames[playerId]!,
                playerColor: game.playerColors[playerId]!,
                position: position,
                category: category,
                question: question,
                isLadder: true,
                onAnswer: (bool correct) {
                  game.recordQuizResult(playerId, category, correct);
                  if (correct) {
                    game.onLadderQuizSuccess(position, playerId, makeCallback());
                  } else {
                    game.onLadderQuizFailed(playerId, makeCallback());
                  }
                },
              );
            },
          );
          return;
        }
      } catch (e) {
        // Fall back to default toast
      }
    }

    // Handle SNAKE_QUIZ trigger
    if (message.startsWith('SNAKE_QUIZ::')) {
      try {
        final parts = message.split('::');
        if (parts.length >= 4) {
          final playerId = parts[1];
          final position = int.parse(parts[2]);
          final category = parts[3];
          
          final question = game.getRandomQuizQuestion(category);
          
          if (!mounted) return;
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return QuizDialog(
                player: playerId,
                playerName: game.playerNames[playerId]!,
                playerColor: game.playerColors[playerId]!,
                position: position,
                category: category,
                question: question,
                isLadder: false,
                onAnswer: (bool correct) {
                  game.recordQuizResult(playerId, category, correct);
                  if (correct) {
                    game.onSnakeQuizSuccess(position, playerId, makeCallback());
                  } else {
                    game.onSnakeQuizFailed(position, playerId, makeCallback());
                  }
                },
              );
            },
          );
          return;
        }
      } catch (e) {
        // Fall back to default toast
      }
    }

    // Handle LADDER_KNOWLEDGE trigger
    if (message.startsWith('LADDER_KNOWLEDGE::')) {
      try {
        final parts = message.split('::');
        if (parts.length >= 4) {
          final playerId = parts[1];
          final position = int.parse(parts[2]);
          final category = parts[3];
          
          final knowledge = game.getKnowledgeByte(true, category);
          
          if (!mounted) return;
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return KnowledgeByteDialog(
                player: playerId,
                playerName: game.playerNames[playerId]!,
                playerColor: game.playerColors[playerId]!,
                position: position,
                isLadder: true,
                knowledge: knowledge,
                onContinue: () {
                  game.onLadderKnowledge(position, playerId, makeCallback());
                },
              );
            },
          );
          return;
        }
      } catch (e) {
        // Fall back to default toast
      }
    }

    // Handle SNAKE_KNOWLEDGE trigger
    if (message.startsWith('SNAKE_KNOWLEDGE::')) {
      try {
        final parts = message.split('::');
        if (parts.length >= 4) {
          final playerId = parts[1];
          final position = int.parse(parts[2]);
          final category = parts[3];
          
          final knowledge = game.getKnowledgeByte(false, category);
          
          if (!mounted) return;
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return KnowledgeByteDialog(
                player: playerId,
                playerName: game.playerNames[playerId]!,
                playerColor: game.playerColors[playerId]!,
                position: position,
                isLadder: false,
                knowledge: knowledge,
                onContinue: () {
                  game.onSnakeKnowledge(position, playerId, makeCallback());
                },
              );
            },
          );
          return;
        }
      } catch (e) {
        // Fall back to default toast
      }
    }

    // Handle ADVICE trigger
    if (message.startsWith('ADVICE::')) {
      try {
        final parts = message.split('::');
        if (parts.length >= 3) {
          final playerId = parts[1];
          
          final advice = game.getRandomHealthAdvice();
          
          if (!mounted) return;
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return HealthAdviceDialog(
                player: playerId,
                playerName: game.playerNames[playerId]!,
                playerColor: game.playerColors[playerId]!,
                advice: advice,
                onContinue: () {
                  game.onAdviceRead(playerId);
                  game.switchTurn(makeCallback());
                },
              );
            },
          );
          return;
        }
      } catch (e) {
        // Fall back to default toast
      }
    }

    // Handle Action Challenge trigger
    if (message.startsWith('ACTION_CHALLENGE::')) {
      try {
        final parts = message.split('::');
        if (parts.length >= 3) {
          final playerId = parts[1];
          final currentPos = game.playerPositions[playerId]!;
          
          final challenge = game.getRandomActionChallenge();
          
          if (!mounted) return;
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return ActionChallengeDialog(
                player: playerId,
                playerName: game.playerNames[playerId]!,
                playerColor: game.playerColors[playerId]!,
                challenge: challenge,
                onComplete: (bool completed) async {
                  if (completed) {
                    game.completeActionChallenge(playerId);
                    if (mounted) {
                      _showToast(
                        context,
                        '${game.playerNames[playerId]} completed the challenge! +2 bonus steps!',
                        '🎉',
                      );
                    }
                    
                    // Apply bonus steps
                    const bonusSteps = 2;
                    final newPos = (currentPos + bonusSteps).clamp(0, 100);
                    
                    if (newPos != currentPos && mounted) {
                      for (int step = 1; step <= bonusSteps; step++) {
                        final intermediatePos = currentPos + step;
                        if (intermediatePos <= 100) {
                          game.playerPositions[playerId] = intermediatePos;
                          if (mounted) {
                            setState(() {});
                          }
                          await Future.delayed(const Duration(milliseconds: 400));
                        }
                      }
                    }
                    
                    // Check for special cells after bonus movement
                    if (newPos < 100 && mounted) {
                      await game.checkSpecialCell(newPos, playerId, makeCallback());
                    } else if (mounted) {
                      game.checkWinCondition(makeCallback());
                    }
                  } else {
                    if (mounted) {
                      _showToast(
                        context,
                        'Challenge skipped. No bonus this time!',
                        '😅',
                      );
                    }
                    game.switchTurn(makeCallback());
                  }
                },
              );
            },
          );
          return;
        }
      } catch (e) {
        // Fall back to default toast
      }
    }

    // Handle REWARD message
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
              builder: (dialogContext) {
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
                          onPressed: () => Navigator.of(dialogContext).pop(),
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
        // Fall back to snackbar below
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
                color: const Color(0xFF667eea).withValues(alpha: 0.15),
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

// Health Advice Dialog (used in ADVICE trigger)
class HealthAdviceDialog extends StatefulWidget {
  final String player;
  final String playerName;
  final Color playerColor;
  final HealthAdvice advice;
  final Function() onContinue;

  const HealthAdviceDialog({
    super.key,
    required this.player,
    required this.playerName,
    required this.playerColor,
    required this.advice,
    required this.onContinue,
  });

  @override
  State<HealthAdviceDialog> createState() => _HealthAdviceDialogState();
}

class _HealthAdviceDialogState extends State<HealthAdviceDialog> with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Dialog(
        alignment: Alignment.bottomCenter,
        insetPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          padding: const EdgeInsets.all(30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.advice.icon,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: widget.playerColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.playerColor.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.playerName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.playerColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.advice.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.advice.text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFBBF24).withValues(alpha: 0.1),
                        const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tips_and_updates, 
                            color: Color(0xFFF59E0B), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Quick Tip:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.advice.tip,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2C3E50),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.monetization_on, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '+5 Coins Earned!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onContinue();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Action Challenge Dialog (used in ACTION_CHALLENGE trigger)
class ActionChallengeDialog extends StatefulWidget {
  final String player;
  final String playerName;
  final Color playerColor;
  final ActionChallenge challenge;
  final Function(bool) onComplete;

  const ActionChallengeDialog({
    super.key,
    required this.player,
    required this.playerName,
    required this.playerColor,
    required this.challenge,
    required this.onComplete,
  });

  @override
  State<ActionChallengeDialog> createState() => _ActionChallengeDialogState();
}

class _ActionChallengeDialogState extends State<ActionChallengeDialog> with SingleTickerProviderStateMixin {
  int remainingTime = 0;
  Timer? _timer;
  bool isActive = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.challenge.timeLimit;
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startChallenge() {
    setState(() {
      isActive = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();
        _completeChallenge(true);
      }
    });
  }

  void _completeChallenge(bool completed) {
    _timer?.cancel();
    widget.onComplete(completed);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Color _getCategoryColor() {
    switch (widget.challenge.category) {
      case 'exercise':
        return const Color(0xFF2196F3);
      case 'nutrition':
        return const Color(0xFF4CAF50);
      case 'mental':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF667eea);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();
    final progress = isActive ? remainingTime / widget.challenge.timeLimit : 1.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFFFD700).withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      widget.challenge.icon,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.playerColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.playerName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.playerColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.challenge.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.challenge.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (isActive) ...[
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: categoryColor,
                    width: 8,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                      ),
                    ),
                    Center(
                      child: Text(
                        '$remainingTime',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Complete the challenge!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (!isActive) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFD700).withValues(alpha: 0.1),
                      const Color(0xFFFFA500).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFF59E0B)),
                        SizedBox(width: 8),
                        Text(
                          'Challenge Reward',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '✅ Complete: +2 bonus steps + 15 coins',
                      style: TextStyle(fontSize: 13, color: Color(0xFF2C3E50)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '❌ Skip: No bonus',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (!isActive)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _completeChallenge(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _startChallenge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Start Challenge',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            if (isActive)
              ElevatedButton(
                onPressed: () => _completeChallenge(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'I Completed It!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}