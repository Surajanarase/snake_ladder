// lib/widgets/home_shell.dart - FIXED VERSION (No Unicode Issues)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../database/database_helper.dart';
import 'board_widget.dart';
import 'control_panel.dart';
//import 'dart:math' as math;
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

  @override
  void initState() {
    super.initState();
    _gameStartTime = DateTime.now();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNameEntry(context, widget.numPlayers, widget.withBot, widget.mode);
    });
  }

  void _showNameEntry(BuildContext context, int numPlayers, bool withBot, GameMode mode) async {
    final game = Provider.of<GameService>(context, listen: false);
    
    final profile = await DatabaseHelper.instance.getUserProfile();
    final player1Name = profile['username'] ?? 'Player 1';
    final player1Initials = profile['avatar_initials'] ?? 'P1';
    
    game.playerNames['player1'] = '\u{1F464} $player1Name'; // Person emoji
    
    final controllers = <TextEditingController>[];
    
    for (int i = 2; i <= numPlayers; i++) {
      if (withBot && i == numPlayers) {
        continue;
      }
      final defaultName = 'Player $i';
      controllers.add(TextEditingController(text: defaultName));
    }

    if (!mounted) return;
    
    final dialogBuildContext = context;
    
    if (!dialogBuildContext.mounted) return;
    
    showDialog<void>(
      context: dialogBuildContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 400;
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Enter player names',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF667eea), width: 2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: isSmallScreen ? 36 : 40,
                              height: isSmallScreen ? 36 : 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  player1Initials,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF667eea),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Player 1 (You)',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 10 : 11,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    player1Name,
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 13 : 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.verified_user,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      
                      for (int i = 0; i < controllers.length; i++) ...[
                        TextField(
                          controller: controllers[i],
                          decoration: InputDecoration(
                            labelText: 'Player ${i + 2} name',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person_outline),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: isSmallScreen ? 12 : 16,
                            ),
                          ),
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        ),
                        SizedBox(height: isSmallScreen ? 10 : 12),
                      ],
                      
                      if (withBot) ...[
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.smart_toy, color: Colors.grey.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Player $numPlayers: AI Bot',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 10 : 12),
                      ],
                      
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              if (dialogBuildContext.mounted) {
                                Navigator.of(dialogBuildContext).pop();
                              }
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              for (int i = 0; i < controllers.length; i++) {
                                final name = controllers[i].text.trim();
                                if (name.isNotEmpty) {
                                  game.playerNames['player${i + 2}'] = '\u{1F464} $name';
                                }
                              }
                              
                              game.startGame(numPlayers, withBot, mode);
                              _gameStartTime = DateTime.now();
                              
                              Navigator.of(dialogContext).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 20 : 24,
                                vertical: isSmallScreen ? 10 : 12,
                              ),
                            ),
                            child: Text(
                              'Start Game',
                              style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameService>(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;
    final isTablet = size.width >= 600;

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = isTablet ? 700.0 : constraints.maxWidth;
              
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8 : 12,
                      vertical: isSmallScreen ? 4 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 18),
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
                        Column(
                          children: [
                            // Header
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 10 : 14),
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
                                    icon: Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: isSmallScreen ? 20 : 24,
                                    ),
                                    onPressed: () => _showExitConfirmation(),
                                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                                    constraints: const BoxConstraints(
                                      minWidth: 40,
                                      minHeight: 40,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Health Heroes',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isSmallScreen ? 18 : 22,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          'Learn & Play',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: isSmallScreen ? 10 : 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        SoundService().toggleSound();
                                      });
                                    },
                                    child: Container(
                                      width: isSmallScreen ? 32 : 36,
                                      height: isSmallScreen ? 32 : 36,
                                      margin: EdgeInsets.only(right: isSmallScreen ? 6 : 8),
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
                                          size: isSmallScreen ? 16 : 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showLegend(context),
                                    child: Container(
                                      width: isSmallScreen ? 32 : 36,
                                      height: isSmallScreen ? 32 : 36,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.help_outline,
                                          color: Colors.white,
                                          size: isSmallScreen ? 16 : 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Game Board
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: isSmallScreen ? 4 : 6,
                                        horizontal: isSmallScreen ? 2 : 4,
                                      ),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          final boardSize = (constraints.maxWidth * 1.08).clamp(
                                            280.0,
                                            isTablet ? 600.0 : 500.0,
                                          );
                                          return Center(
                                            child: SizedBox(
                                              width: boardSize,
                                              height: boardSize,
                                              child: const BoardWidget(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    ControlPanel(
                                      onNotify: (m, i) => _showToast(context, m, i),
                                    ),
                                    SizedBox(height: isSmallScreen ? 8 : 12),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Win Overlay
                        if (!game.gameActive && game.getWinner() != null && !_suppressWinOverlay)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 18),
                              ),
                              child: Center(
                                child: Container(
                                  margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
                                  padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
                                  constraints: BoxConstraints(
                                    maxWidth: constraints.maxWidth - (isSmallScreen ? 32 : 48),
                                    maxHeight: constraints.maxHeight - (isSmallScreen ? 80 : 100),
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
                                  child: _buildWinnerContent(game, isSmallScreen),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWinnerContent(GameService game, bool isSmallScreen) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
              '\u{1F3C6}', // Trophy emoji
              style: TextStyle(fontSize: isSmallScreen ? 48 : 60),
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Text(
            '${game.playerNames[game.getWinner()]} Wins!',
            style: TextStyle(
              fontSize: isSmallScreen ? 22 : 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            '\u{1F389} Congratulations! \u{1F389}', // Party popper emoji
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: const Color(0xFF7F8C8D),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
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
                _statRow('\u{1F3C5} Winner', game.playerNames[game.getWinner()]!, isSmallScreen),
                Divider(height: isSmallScreen ? 16 : 20),
                _statRow('\u{1FA99} Total Coins', '${game.playerCoins[game.getWinner()]}', isSmallScreen),
                Divider(height: isSmallScreen ? 16 : 20),
                _statRow('\u{1F60A} Good Habits', '${game.playerGoodHabits[game.getWinner()]}', isSmallScreen),
                Divider(height: isSmallScreen ? 16 : 20),
                _statRow('\u{1F3B2} Total Moves', '${game.moveCount}', isSmallScreen),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          _buildWinnerButtons(game, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildWinnerButtons(GameService game, bool isSmallScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 400) {
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
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Close (Stay)',
                    style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                  ),
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
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Play Again',
                    style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                  ),
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
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Back to Home',
                    style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                  ),
                ),
              ),
            ],
          );
        } else {
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 10 : 12,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text('Close', style: TextStyle(fontSize: isSmallScreen ? 12 : 13)),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 10 : 12,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text('Play Again', style: TextStyle(fontSize: isSmallScreen ? 12 : 13)),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 10 : 12,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text('Home', style: TextStyle(fontSize: isSmallScreen ? 12 : 13)),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Future<void> _saveGameResult(GameService game) async {
    final winner = game.getWinner();
    if (winner == null) return;

    final duration = DateTime.now().difference(_gameStartTime);
    
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
              Navigator.pop(context);
              Navigator.pop(context);
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

  Widget _statRow(String label, String value, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: const Color(0xFF7F8C8D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showLegend(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? 340 : 420,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: EdgeInsets.all(isSmallScreen ? 18 : 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.help_outline,
                      color: Colors.white,
                      size: isSmallScreen ? 28 : 32,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Text(
                    'Game Guide',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  _legendItem('\u{1F3B2}', 'How to Play', 'Tap the dice to roll. Race to reach square 100 first!', isSmallScreen),
                  _legendItem('\u{1FA9C}', 'Colorful Ladders', 'Good health choices that move you forward and earn coins.', isSmallScreen),
                  _legendItem('\u{1F40D}', 'Colorful Snakes', 'Poor health choices that set you back. Learn from them!', isSmallScreen),
                  _legendItem('\u{1F9E0}', 'Quiz Mode', 'Answer questions to climb ladders or avoid snakes.', isSmallScreen),
                  _legendItem('\u{1F4DA}', 'Knowledge Mode', 'Learn health DOs and DON\'Ts automatically.', isSmallScreen),
                  _legendItem('\u{1F4A1}', 'Advice Squares', 'Land on special tiles for health advice and +5 coins!', isSmallScreen),
                  _legendItem('\u{1FA99}', 'Coins', 'Earn coins through quizzes and good health habits!', isSmallScreen),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 28 : 32,
                        vertical: isSmallScreen ? 10 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'Got it!',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _legendItem(String icon, String label, String desc, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 14),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
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
            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              icon,
              style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
            ),
          ),
          SizedBox(width: isSmallScreen ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 13 : 15,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 3 : 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 13,
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
        // Fall back to toast
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
        // Fall back to toast
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
                  game.onLadderKnowledge(position, playerId, knowledge, makeCallback());
                },
              );
            },
          );
          return;
        }
      } catch (e) {
        // Fall back to toast
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
                  game.onSnakeKnowledge(position, playerId, knowledge, makeCallback());
                },
              );
            },
          );
          return;
        }
      } catch (e) {
        // Fall back to toast
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
        // Fall back to toast
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
                final isSmallScreen = MediaQuery.of(dialogContext).size.width < 400;
                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(icon, style: TextStyle(fontSize: isSmallScreen ? 24 : 28)),
                        SizedBox(height: isSmallScreen ? 10 : 12),
                        Text(
                          '${game.playerNames[playerId]} earned a reward!',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF667eea),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        Text(
                          rewardText,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 14),
                        ElevatedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 20 : 24,
                              vertical: isSmallScreen ? 8 : 10,
                            ),
                          ),
                          child: Text(
                            'OK',
                            style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                          ),
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
        // Fall back to snackbar
      }
    }

    // Default: floating SnackBar
    final messenger = ScaffoldMessenger.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(icon, style: TextStyle(fontSize: isSmallScreen ? 18 : 20)),
            ),
            SizedBox(width: isSmallScreen ? 10 : 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.all(isSmallScreen ? 12 : 16),
        elevation: 8,
      ),
    );
  }
}

// Health Advice Dialog (with responsive sizing)
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
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    
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
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: EdgeInsets.all(isSmallScreen ? 24 : 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
                    style: TextStyle(fontSize: isSmallScreen ? 40 : 48),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: isSmallScreen ? 10 : 12,
                      height: isSmallScreen ? 10 : 12,
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
                    Flexible(
                      child: Text(
                        widget.playerName,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: widget.playerColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  widget.advice.title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  widget.advice.text,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: const Color(0xFF666666),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
                      Row(
                        children: [
                          Icon(Icons.tips_and_updates, 
                            color: const Color(0xFFF59E0B),
                            size: isSmallScreen ? 18 : 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Quick Tip:',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Text(
                        widget.advice.tip,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: const Color(0xFF2C3E50),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 24),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 14 : 16,
                    vertical: isSmallScreen ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: isSmallScreen ? 18 : 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+5 Coins Earned!',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onContinue();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 40 : 48,
                      vertical: isSmallScreen ? 14 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Got it!',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
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