// lib/widgets/control_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import 'dart:async';
import 'player_stats_dialog.dart'; 

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

  Future<void> _resetDice() async {
    if (_isResetting) return;
    _isResetting = true;
    
    await _resultFadeController.forward();
    
    if (mounted) {
      setState(() {
        _displayedRoll = null;
        _playerWhoRolled = null;
      });
      
      _resultFadeController.reset();
    }
    
    _isResetting = false;
  }

  Future<void> _handleBotTurn(GameService game) async {
    if (!game.isCurrentPlayerBot() || !game.gameActive) return;
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!mounted || !game.gameActive) return;
    
    setState(() {
      _playerWhoRolled = game.currentPlayer;
      _displayedRoll = null;
    });
    
    _diceController.forward(from: 0);
    final roll = await game.rollDice();
    if (roll == 0) return;
    
    setState(() {
      _displayedRoll = roll;
    });
    
    widget.onNotify('🤖 Bot rolled $roll', '🎲');
    await game.movePlayer(game.currentPlayer, roll, onNotify: (msg, ic) => widget.onNotify(msg, ic));
    
    await Future.delayed(const Duration(milliseconds: 1000));
    
    await _resetDice();
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (mounted && game.gameActive) {
      _handleBotTurn(game);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameService>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final diceSize = (screenWidth * 0.16).clamp(80.0, 110.0);

    if (game.isCurrentPlayerBot() && game.gameActive && !game.isRolling && _displayedRoll == null) {
      Future.microtask(() => _handleBotTurn(game));
    }

    final String displayPlayer = _playerWhoRolled ?? game.currentPlayer;
    final Color diceColor = game.isCurrentPlayerBot()
        ? Colors.grey.shade400
        : (game.playerColors[displayPlayer] ?? game.playerColors[game.currentPlayer]!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dice row
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    if (!game.gameActive) {
                      widget.onNotify('Start a game first', '⚠️');
                      return;
                    }
                    if (game.isRolling || game.isCurrentPlayerBot() || _displayedRoll != null) return;

                    setState(() {
                      _playerWhoRolled = game.currentPlayer;
                      _displayedRoll = null;
                    });

                    _diceController.forward(from: 0);
                    final roll = await game.rollDice();
                    if (roll == 0) {
                      setState(() {
                        _playerWhoRolled = null;
                      });
                      return;
                    }

                    setState(() {
                      _displayedRoll = roll;
                    });

                    await game.movePlayer(game.currentPlayer, roll, onNotify: (msg, ic) => widget.onNotify(msg, ic));
                    await Future.delayed(const Duration(milliseconds: 1000));
                    await _resetDice();
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
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white, Color(0xFFFAFAFA)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: diceColor, width: 3.5),
                            boxShadow: [
                              const BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 15,
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
                              transitionBuilder: (child, animation) => ScaleTransition(
                                scale: animation,
                                child: FadeTransition(opacity: animation, child: child),
                              ),
                              child: game.isRolling
                                  ? Icon(
                                      key: const ValueKey('rolling'),
                                      Icons.casino_outlined,
                                      color: diceColor,
                                      size: diceSize * 0.5,
                                    )
                                  : _displayedRoll != null
                                      ? _buildStandardDiceFace(_displayedRoll!, diceSize * 0.7, diceColor)
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

                if (_displayedRoll != null)
                  AnimatedBuilder(
                    animation: _resultFadeController,
                    builder: (context, child) {
                      if (_resultFadeController.value >= 0.99) return const SizedBox.shrink();
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
                                    colors: [diceColor.withAlpha(230), diceColor],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
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
                                      shadows: [Shadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2))],
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

          const SizedBox(height: 16),

          // Player cards (ONLY View Stats button, no duplicate stats)
          if (game.numberOfPlayers == 2)
            Row(
              children: [
                Expanded(child: _buildModernPlayerCard(game, 'player1', isActive: game.currentPlayer == 'player1')),
                const SizedBox(width: 10),
                Expanded(child: _buildModernPlayerCard(game, 'player2', isActive: game.currentPlayer == 'player2')),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _buildModernPlayerCard(game, 'player1', isActive: game.currentPlayer == 'player1')),
                const SizedBox(width: 8),
                Expanded(child: _buildModernPlayerCard(game, 'player2', isActive: game.currentPlayer == 'player2')),
                const SizedBox(width: 8),
                Expanded(child: _buildModernPlayerCard(game, 'player3', isActive: game.currentPlayer == 'player3')),
              ],
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

  // Player card with stats display
  Widget _buildModernPlayerCard(GameService game, String playerId, {required bool isActive}) {
    final isThreePlayers = game.numberOfPlayers == 3;
    final color = game.playerColors[playerId]!;
    final name = game.playerNames[playerId]!;
    final position = game.playerPositions[playerId]!;
    final coins = game.playerCoins[playerId] ?? 0;
    final goodHabits = game.playerGoodHabits[playerId] ?? 0;
    final badHabits = game.playerBadHabits[playerId] ?? 0;
    
    return GestureDetector(
      onTap: () => _showPlayerStats(context, game, playerId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive 
                ? [
                    color.withAlpha(230),
                    color.withAlpha(180),
                  ]
                : [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
          ),
          borderRadius: BorderRadius.circular(isThreePlayers ? 14 : 16),
          border: Border.all(
            color: isActive ? Colors.white : color.withAlpha(100),
            width: isActive ? 3 : 2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withAlpha(120),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: 2,
                  ),
                  const BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isThreePlayers ? 14 : 16),
          child: Stack(
            children: [
              // Animated glow effect for active player
              if (isActive)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: 0.15,
                    duration: const Duration(milliseconds: 1000),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withAlpha(100),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              
              Padding(
                padding: EdgeInsets.all(isThreePlayers ? 10 : 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header: Avatar + Name (NO play button indicator)
                    Row(
                      children: [
                        // Avatar Circle
                        Container(
                          width: isThreePlayers ? 32 : 38,
                          height: isThreePlayers ? 32 : 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isActive
                                  ? [Colors.white, Colors.white.withAlpha(200)]
                                  : [color, color.withAlpha(200)],
                            ),
                            border: Border.all(
                              color: isActive ? color : Colors.white,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isActive ? color : Colors.black).withAlpha(40),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              playerId == 'player3' && game.hasBot ? '🤖' : 'P${playerId.replaceAll('player', '')}',
                              style: TextStyle(
                                fontSize: isThreePlayers ? 12 : 14,
                                fontWeight: FontWeight.bold,
                                color: isActive ? color : Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Name + Position
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: isThreePlayers ? 11 : 13,
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? Colors.white : color,
                                  letterSpacing: 0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pos: ${position == 0 ? 'Start' : position}',
                                style: TextStyle(
                                  fontSize: isThreePlayers ? 9 : 10,
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? Colors.white.withAlpha(230) : color.withAlpha(180),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: isThreePlayers ? 8 : 10),
                    
                    // Quick Stats Display
                    Container(
                      padding: EdgeInsets.all(isThreePlayers ? 6 : 8),
                      decoration: BoxDecoration(
                        color: isActive 
                            ? Colors.white.withAlpha(150)
                            : color.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isActive 
                              ? Colors.white.withAlpha(200)
                              : color.withAlpha(50),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQuickStat('🪙', '$coins', isActive, color, isCompact: isThreePlayers),
                          _buildQuickStat('😊', '$goodHabits', isActive, const Color(0xFF4CAF50), isCompact: isThreePlayers),
                          _buildQuickStat('😞', '$badHabits', isActive, const Color(0xFFE74C3C), isCompact: isThreePlayers),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: isThreePlayers ? 6 : 8),
                    
                    // View Stats Button
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isThreePlayers ? 8 : 10,
                        vertical: isThreePlayers ? 4 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive 
                            ? Colors.white.withAlpha(200)
                            : color.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive 
                              ? Colors.white
                              : color.withAlpha(100),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart_rounded,
                            size: isThreePlayers ? 12 : 14,
                            color: isActive ? color : color.withAlpha(200),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'View Stats',
                            style: TextStyle(
                              fontSize: isThreePlayers ? 9 : 10,
                              fontWeight: FontWeight.bold,
                              color: isActive ? color : color.withAlpha(200),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Simple stat display
  Widget _buildQuickStat(String icon, String value, bool isActive, Color color, {bool isCompact = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: TextStyle(fontSize: isCompact ? 14 : 16)),
        SizedBox(height: isCompact ? 2 : 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isCompact ? 11 : 13,
            fontWeight: FontWeight.bold,
            color: isActive ? color : color.withAlpha(220),
          ),
        ),
      ],
    );
  }

  void _showPlayerStats(BuildContext context, GameService game, String playerId) {
    showDialog(
      context: context,
      builder: (context) {
        return PlayerStatsDialog(
          playerId: playerId,
          game: game,
        );
      },
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
      canvas.drawCircle(
        Offset(x + 1, y + 1), 
        dotRadius, 
        Paint()..color = const Color(0x26000000)
      );
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
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