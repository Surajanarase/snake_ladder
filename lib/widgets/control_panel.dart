// lib/widgets/control_panel.dart
// Final polished version with smooth animations and perfect timing
// =============================================================================

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

class _ControlPanelState extends State<ControlPanel> with TickerProviderStateMixin {
  late AnimationController _diceController;
  late Animation<double> _diceRotation;
  late AnimationController _resultFadeController;
  late Animation<double> _resultOpacity;
  late Animation<double> _resultScale;
  
  // Track the player who rolled and the displayed roll result
  String? _playerWhoRolled;
  int? _displayedRoll;
  bool _isResetting = false;

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
    
    // Controller for result badge fade out animation
    _resultFadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _resultOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _resultFadeController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );
    
    _resultScale = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _resultFadeController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInBack),
      ),
    );
  }

  @override
  void dispose() {
    _diceController.dispose();
    _resultFadeController.dispose();
    super.dispose();
  }

  // Reset dice to clean state with beautiful animation
  Future<void> _resetDice() async {
    if (_isResetting) return;
    _isResetting = true;
    
    // Start fade out animation
    await _resultFadeController.forward();
    
    if (mounted) {
      setState(() {
        _displayedRoll = null;
        _playerWhoRolled = null;
      });
      
      // Reset controllers
      _resultFadeController.reset();
    }
    
    _isResetting = false;
  }

  // Auto-play for bot
  Future<void> _handleBotTurn(GameService game) async {
    if (!game.isCurrentPlayerBot() || !game.gameActive) return;
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!mounted || !game.gameActive) return;
    
    // Set who is rolling
    setState(() {
      _playerWhoRolled = game.currentPlayer;
      _displayedRoll = null; // Clear previous roll
    });
    
    _diceController.forward(from: 0);
    final roll = await game.rollDice();
    if (roll == 0) return;
    
    setState(() {
      _displayedRoll = roll;
    });
    
    widget.onNotify('🤖 Bot rolled $roll', '🎲');
    await game.movePlayer(game.currentPlayer, roll, onNotify: widget.onNotify);
    
    // Wait 1 second to show the result (reduced from 1.5s)
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Reset dice with smooth animation
    await _resetDice();
    
    // Small pause for smooth transition
    await Future.delayed(const Duration(milliseconds: 200));
    
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
    if (game.isCurrentPlayerBot() && game.gameActive && !game.isRolling && _displayedRoll == null) {
      Future.microtask(() => _handleBotTurn(game));
    }

    // Determine which player's color to show on dice
    final String displayPlayer = _playerWhoRolled ?? game.currentPlayer;
    final Color diceColor = game.isCurrentPlayerBot() 
        ? Colors.grey.shade400
        : (game.playerColors[displayPlayer] ?? game.playerColors[game.currentPlayer]!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Player cards
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

          // Dice with elegant result display
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Main Dice
                GestureDetector(
                  onTap: () async {
                    if (!game.gameActive) {
                      widget.onNotify('Start a game first', '⚠️');
                      return;
                    }
                    if (game.isRolling || game.isCurrentPlayerBot() || _displayedRoll != null) return;
                    
                    // Set who is rolling and clear any previous result
                    setState(() {
                      _playerWhoRolled = game.currentPlayer;
                      _displayedRoll = null; // Important: Clear previous roll
                    });
                    
                    _diceController.forward(from: 0);
                    final roll = await game.rollDice();
                    if (roll == 0) {
                      setState(() {
                        _playerWhoRolled = null;
                      });
                      return;
                    }
                    
                    // Show the NEW roll result
                    setState(() {
                      _displayedRoll = roll;
                    });
                    
                    // Move player and wait for movement to complete
                    await game.movePlayer(game.currentPlayer, roll, onNotify: widget.onNotify);
                    
                    // Wait 1 second to show the result (reduced from 1.5s for smoother flow)
                    await Future.delayed(const Duration(milliseconds: 1000));
                    
                    // Reset dice with smooth animation
                    await _resetDice();
                    
                    // Small pause for smooth transition
                    await Future.delayed(const Duration(milliseconds: 200));
                  },
                  child: AnimatedBuilder(
                    animation: _diceRotation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: game.isRolling ? _diceRotation.value : 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
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
                              color: diceColor,
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
                                color: diceColor.withAlpha(76),
                                blurRadius: 25,
                                spreadRadius: -3,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: game.isRolling
                                  ? Icon(
                                      key: const ValueKey('rolling'),
                                      Icons.casino_outlined,
                                      color: diceColor,
                                      size: diceSize * 0.5,
                                    )
                                  : _displayedRoll != null
                                      ? _buildStandardDiceFace(
                                          _displayedRoll!, 
                                          diceSize * 0.7,
                                          diceColor,
                                        )
                                      : Icon(
                                          key: const ValueKey('ready'),
                                          Icons.casino_outlined,
                                          size: diceSize * 0.5,
                                          color: Colors.grey.shade400,
                                        ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Result badge with smooth fade animation - FIXED to disappear properly
                if (_displayedRoll != null)
                  AnimatedBuilder(
                    animation: _resultFadeController,
                    builder: (context, child) {
                      // Hide completely when animation is done
                      if (_resultFadeController.value >= 0.99) {
                        return const SizedBox.shrink();
                      }
                      
                      return Opacity(
                        opacity: _resultOpacity.value,
                        child: Transform.scale(
                          scale: _resultScale.value,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 12),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      diceColor.withAlpha(230),
                                      diceColor,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: diceColor.withAlpha(127),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '$_displayedRoll',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      height: 1.0,
                                      shadows: [
                                        Shadow(
                                          color: Color(0x40000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardDiceFace(int number, double size, Color dotColor) {
    return SizedBox(
      key: ValueKey('dice-$number'),
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StandardDicePainter(number, dotColor),
      ),
    );
  }

 Widget _playerCard(String title, int position, int score, Color color, {required bool isActive}) {
    final game = Provider.of<GameService>(context, listen: false);
    final isThreePlayers = game.numberOfPlayers == 3;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: isThreePlayers ? 6 : 10, 
        vertical: isThreePlayers ? 8 : 12,
      ),
      decoration: BoxDecoration(
        gradient: isActive 
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withAlpha(51),
                  color.withAlpha(25),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFAFAFA),
                  Colors.grey.shade50,
                ],
              ),
        borderRadius: BorderRadius.circular(isThreePlayers ? 10 : 12),
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
            : [
                const BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player name with color indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isThreePlayers ? 6 : 8,
                height: isThreePlayers ? 6 : 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(127),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(width: isThreePlayers ? 4 : 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isThreePlayers ? 11 : 13,
                    fontWeight: FontWeight.bold,
                    color: isActive ? color : Colors.black87,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: isThreePlayers ? 6 : 8),
          
          // Position and Score in a clean layout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Position
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isThreePlayers ? 4 : 6, 
                    vertical: isThreePlayers ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Position',
                        style: TextStyle(
                          fontSize: isThreePlayers ? 8 : 9,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                      SizedBox(height: isThreePlayers ? 1 : 2),
                      Text(
                        position == 0 ? 'Start' : '$position',
                        style: TextStyle(
                          fontSize: isThreePlayers ? 12 : 14,
                          fontWeight: FontWeight.bold,
                          color: isActive ? color : Colors.black87,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: isThreePlayers ? 4 : 6),
              // Rewards
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isThreePlayers ? 4 : 6, 
                    vertical: isThreePlayers ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Rewards',
                        style: TextStyle(
                          fontSize: isThreePlayers ? 8 : 9,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                      SizedBox(height: isThreePlayers ? 1 : 2),
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: isThreePlayers ? 12 : 14,
                          fontWeight: FontWeight.bold,
                          color: isActive ? color : const Color(0xFFFFB300),
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
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