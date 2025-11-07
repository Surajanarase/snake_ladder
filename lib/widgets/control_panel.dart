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
        // === Dice row (same as before) ===
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ... (unchanged dice GestureDetector + AnimatedBuilder) ...
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

        // === Player boxes (moved here, replacing the old 4 health tiles) ===
        if (game.numberOfPlayers == 2)
          Row(
            children: [
              Expanded(child: _playerCardWithHabits(game, 'player1', isActive: game.currentPlayer == 'player1')),
              const SizedBox(width: 10),
              Expanded(child: _playerCardWithHabits(game, 'player2', isActive: game.currentPlayer == 'player2')),
            ],
          )
        else
          Row(
            children: [
              Expanded(child: _playerCardWithHabits(game, 'player1', isActive: game.currentPlayer == 'player1')),
              const SizedBox(width: 10),
              Expanded(child: _playerCardWithHabits(game, 'player2', isActive: game.currentPlayer == 'player2')),
              const SizedBox(width: 10),
              Expanded(child: _playerCardWithHabits(game, 'player3', isActive: game.currentPlayer == 'player3')),
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

  // NEW: Player card with habits tracking
  Widget _playerCardWithHabits(GameService game, String playerId, {required bool isActive}) {
    final isThreePlayers = game.numberOfPlayers == 3;
    final color = game.playerColors[playerId]!;
    final name = game.playerNames[playerId]!;
    final position = game.playerPositions[playerId]!;
    final goodHabits = game.playerGoodHabits[playerId] ?? 0;
    final badHabits = game.playerBadHabits[playerId] ?? 0;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isThreePlayers ? 8 : 10),
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
                  name,
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
          
          // Position
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isThreePlayers ? 6 : 8,
              vertical: isThreePlayers ? 4 : 5,
            ),
            decoration: BoxDecoration(
              color: isActive 
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Position: ',
                  style: TextStyle(
                    fontSize: isThreePlayers ? 9 : 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  position == 0 ? 'Start' : '$position',
                  style: TextStyle(
                    fontSize: isThreePlayers ? 11 : 13,
                    fontWeight: FontWeight.bold,
                    color: isActive ? color : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isThreePlayers ? 6 : 8),
          
          // Good and Bad Habits buttons
          Row(
            children: [
              // Good Habits Button
              Expanded(
                child: GestureDetector(
                  onTap: () => _showGoodHabitsDialog(context, game, playerId),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: isThreePlayers ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withAlpha(76),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '😊',
                          style: TextStyle(fontSize: isThreePlayers ? 16 : 18),
                        ),
                        SizedBox(height: isThreePlayers ? 2 : 4),
                        Text(
                          '$goodHabits',
                          style: TextStyle(
                            fontSize: isThreePlayers ? 13 : 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Good',
                          style: TextStyle(
                            fontSize: isThreePlayers ? 8 : 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: isThreePlayers ? 4 : 6),
              
              // Bad Habits Button
              Expanded(
                child: GestureDetector(
                  onTap: () => _showBadHabitsDialog(context, game, playerId),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: isThreePlayers ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE74C3C), Color(0xFFEF5350)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE74C3C).withAlpha(76),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '😞',
                          style: TextStyle(fontSize: isThreePlayers ? 16 : 18),
                        ),
                        SizedBox(height: isThreePlayers ? 2 : 4),
                        Text(
                          '$badHabits',
                          style: TextStyle(
                            fontSize: isThreePlayers ? 13 : 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Bad',
                          style: TextStyle(
                            fontSize: isThreePlayers ? 8 : 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // In the _playerCardWithHabits method, add after the good/bad habits buttons:
          

const SizedBox(height: 8),
ElevatedButton.icon(
  
  onPressed: () => _showPlayerStats(context, game, playerId),
  icon: const Icon(Icons.bar_chart, size: 16),
  label: const Text('Stats', style: TextStyle(fontSize: 11)),
  style: ElevatedButton.styleFrom(
    backgroundColor: color.withAlpha(51),
    foregroundColor: color,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  ),
),


        ],
      ),
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

  // Show Good Habits Dialog with all 4 categories of positive tips
  void _showGoodHabitsDialog(BuildContext context, GameService game, String playerId) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  const Color(0xFF4CAF50).withAlpha(25),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    gradient:  LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('😊', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(height: 12),
                Text(
                  '${game.playerNames[playerId]}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: game.playerColors[playerId],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Good Habits: ${game.playerGoodHabits[playerId] ?? 0}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Positive Health Messages',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHabitCategory(
                          '🎯',
                          'Nutrition',
                          game.getPlayerRewards(playerId, 'nutrition'),
                          const Color(0xFF4CAF50),
                        ),
                        const SizedBox(height: 12),
                        _buildHabitCategory(
                          '💪',
                          'Exercise',
                          game.getPlayerRewards(playerId, 'exercise'),
                          const Color(0xFF2196F3),
                        ),
                        const SizedBox(height: 12),
                        _buildHabitCategory(
                          '😴',
                          'Sleep',
                          game.getPlayerRewards(playerId, 'sleep'),
                          const Color(0xFF9C27B0),
                        ),
                        const SizedBox(height: 12),
                        _buildHabitCategory(
                          '🧘',
                          'Mindfulness',
                          game.getPlayerRewards(playerId, 'mental'),
                          const Color(0xFFFF9800),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBadHabitsDialog(BuildContext context, GameService game, String playerId) {
  showDialog(
    context: context,
    builder: (context) {
      return Consumer<GameService>(
        builder: (context, g, _) {
          final categories = ['nutrition','exercise','sleep','mental','hygiene'];

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFFE74C3C).withAlpha(25),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Emoji header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE74C3C), Color(0xFFEF5350)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('😞', style: TextStyle(fontSize: 40)),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    g.playerNames[playerId]!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: g.playerColors[playerId],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Bad Habits: ${g.playerBadHabits[playerId] ?? 0}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE74C3C),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ✅ NEW: Scroll list of bad events
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: categories.map((cat) {
                          final events = g.getPlayerBadEvents(playerId, cat);

                          if (events.isEmpty) return const SizedBox.shrink();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE74C3C).withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE74C3C).withAlpha(76)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ...events.map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text("• $e",
                                      style: const TextStyle(fontSize: 13)),
                                ))
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}


  Widget _buildHabitCategory(String icon, String title, List<String> items, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha(76),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withAlpha(51)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 14, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'No items collected yet',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
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