// lib/widgets/control_panel.dart - UPDATED VERSION
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;
    final isVerySmallScreen = size.width < 360;
    final diceSize = isVerySmallScreen ? 70.0 : (isSmallScreen ? 80.0 : (size.width * 0.16).clamp(80.0, 110.0));

    if (game.isCurrentPlayerBot() && game.gameActive && !game.isRolling && _displayedRoll == null) {
      Future.microtask(() => _handleBotTurn(game));
    }

    final String displayPlayer = _playerWhoRolled ?? game.currentPlayer;
    final Color diceColor = game.isCurrentPlayerBot()
        ? Colors.grey.shade400
        : (game.playerColors[displayPlayer] ?? game.playerColors[game.currentPlayer]!);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 14,
        vertical: isSmallScreen ? 8 : 12,
      ),
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
                            borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                            border: Border.all(color: diceColor, width: isSmallScreen ? 2.5 : 3.5),
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
                              SizedBox(width: isSmallScreen ? 8 : 12),
                              Container(
                                width: isSmallScreen ? 48 : 56,
                                height: isSmallScreen ? 48 : 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [diceColor.withAlpha(230), diceColor],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: isSmallScreen ? 2.5 : 3),
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
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 24 : 28,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      height: 1.0,
                                      shadows: const [Shadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2))],
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

          SizedBox(height: isSmallScreen ? 12 : 16),

          // Player cards
          if (game.numberOfPlayers == 2)
            Row(
              children: [
                Expanded(child: _buildRefinedPlayerCard(game, 'player1', isActive: game.currentPlayer == 'player1', isSmallScreen: isSmallScreen)),
                SizedBox(width: isSmallScreen ? 8 : 10),
                Expanded(child: _buildRefinedPlayerCard(game, 'player2', isActive: game.currentPlayer == 'player2', isSmallScreen: isSmallScreen)),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _buildRefinedPlayerCard(game, 'player1', isActive: game.currentPlayer == 'player1', isSmallScreen: isSmallScreen, isThreePlayers: true)),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Expanded(child: _buildRefinedPlayerCard(game, 'player2', isActive: game.currentPlayer == 'player2', isSmallScreen: isSmallScreen, isThreePlayers: true)),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Expanded(child: _buildRefinedPlayerCard(game, 'player3', isActive: game.currentPlayer == 'player3', isSmallScreen: isSmallScreen, isThreePlayers: true)),
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

 Widget _buildRefinedPlayerCard(
  GameService game,
  String playerId, {
  required bool isActive,
  required bool isSmallScreen,
  bool isThreePlayers = false,
}) {
  final color = game.playerColors[playerId]!;
  final name = game.playerNames[playerId]!;
  final position = game.playerPositions[playerId]!;
  final coins = game.playerCoins[playerId] ?? 0;
  final goodHabits = game.playerGoodHabits[playerId] ?? 0;
  final badHabits = game.playerBadHabits[playerId] ?? 0;

  // detect bot player (always last player when hasBot == true)
  final bool isBotPlayer = game.hasBot && playerId == 'player${game.numberOfPlayers}';
  final String displayName = isBotPlayer ? 'Bot' : name;

  final fontSize = isThreePlayers
      ? (isSmallScreen ? 9.0 : 10.5)
      : (isSmallScreen ? 11.0 : 12.5);
  final padding = isThreePlayers
      ? (isSmallScreen ? 10.0 : 11.0)
      : (isSmallScreen ? 12.0 : 14.0);

  return AnimatedContainer(
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
        width: isActive ? (isSmallScreen ? 2.5 : 3) : 2,
      ),
      boxShadow: isActive
          ? [
              BoxShadow(
                color: color.withAlpha(120),
                blurRadius: isSmallScreen ? 12 : 16,
                offset: Offset(0, isSmallScreen ? 4 : 5),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: isSmallScreen ? 8 : 12,
                offset: const Offset(0, 3),
              ),
            ],
    ),
    child: Stack(
      children: [
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
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Player Name with Bot Icon (if bot) and Position (CENTERED)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isBotPlayer) ...[
                        // Bot icon
                        Container(
                          width: isSmallScreen ? 20 : 22,
                          height: isSmallScreen ? 20 : 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(180),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.smart_toy_rounded,
                              size: isSmallScreen ? 12 : 14,
                              color: color,
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 8),
                      ],
                      Flexible(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontSize: fontSize + 2,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.white : color,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 3),
                  Text(
                    'Position: ${position == 0 ? 'Start' : position}',
                    style: TextStyle(
                      fontSize: fontSize - 1,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Colors.white.withAlpha(230)
                          : color.withAlpha(180),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              SizedBox(height: isSmallScreen ? 8 : (isThreePlayers ? 9 : 11)),

              // Stats/Info Container - IDENTICAL height for both bot and human
              if (isBotPlayer)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 6 : (isThreePlayers ? 7 : 9),
                    vertical: isSmallScreen ? 5 : (isThreePlayers ? 6 : 7),
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withAlpha(150)
                        : color.withAlpha(25),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                    border: Border.all(
                      color: isActive
                          ? Colors.white.withAlpha(200)
                          : color.withAlpha(50),
                    ),
                  ),
                  child: SizedBox(
                    height: isSmallScreen
                        ? 55
                        : (isThreePlayers ? 60 : 65),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.smart_toy_rounded,
                            size: isSmallScreen ? 24 : (isThreePlayers ? 26 : 28),
                            color: isActive ? Colors.white.withAlpha(230) : color.withAlpha(200),
                          ),
                          SizedBox(height: isSmallScreen ? 4 : 6),
                          Text(
                            "AI Auto-Play",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 10.5 : (isThreePlayers ? 11.5 : 12.5),
                              fontWeight: FontWeight.w700,
                              color: isActive ? Colors.white.withAlpha(230) : color.withAlpha(200),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isSmallScreen ? 1 : 2),
                          Text(
                            "Bot Mode Active",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 9 : (isThreePlayers ? 9.5 : 10),
                              fontWeight: FontWeight.w600,
                              color: isActive ? Colors.white.withAlpha(200) : color.withAlpha(180),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                // Stats container for human players
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 6 : (isThreePlayers ? 7 : 9),
                    vertical: isSmallScreen ? 5 : (isThreePlayers ? 6 : 7),
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withAlpha(150)
                        : color.withAlpha(25),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                    border: Border.all(
                      color: isActive
                          ? Colors.white.withAlpha(200)
                          : color.withAlpha(50),
                    ),
                  ),
                  child: SizedBox(
                    height: isSmallScreen
                        ? 55
                        : (isThreePlayers ? 60 : 65),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickStat('🪙', '$coins', isActive, const Color(0xFFF59E0B),
                            isCompact: isThreePlayers,
                            isSmallScreen: isSmallScreen),
                        GestureDetector(
                          onTap: () => _showHabitsDialog(context, game, playerId, true),
                          child: _buildQuickStat('😊', '$goodHabits', isActive,
                              const Color(0xFF4CAF50),
                              isCompact: isThreePlayers,
                              isSmallScreen: isSmallScreen,
                              isClickable: true),
                        ),
                        GestureDetector(
                          onTap: () => _showHabitsDialog(context, game, playerId, false),
                          child: _buildQuickStat(
                              '😞', '$badHabits', isActive, const Color(0xFFE74C3C),
                              isCompact: isThreePlayers,
                              isSmallScreen: isSmallScreen,
                              isClickable: true),
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: isSmallScreen ? 6 : (isThreePlayers ? 7 : 9)),

              // View Stats Button - For human players (clickable), For bot (invisible placeholder for height matching)
              GestureDetector(
                onTap: isBotPlayer ? null : () => _showPlayerStats(context, game, playerId),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : (isThreePlayers ? 12 : 14),
                    vertical: isSmallScreen ? 6 : (isThreePlayers ? 7 : 9),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isBotPlayer
                          ? [Colors.transparent, Colors.transparent] // Invisible for bot
                          : isActive
                              ? [
                                  Colors.white,
                                  Colors.white.withAlpha(240),
                                ]
                              : [
                                  color.withAlpha(230),
                                  color.withAlpha(200),
                                ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: isBotPlayer
                        ? null // No border for bot
                        : Border.all(
                            color: isActive ? color.withAlpha(150) : Colors.white.withAlpha(200),
                            width: 1.5,
                          ),
                    boxShadow: isBotPlayer
                        ? null // No shadow for bot
                        : [
                            BoxShadow(
                              color: (isActive ? color : Colors.black).withAlpha(40),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Opacity(
                    opacity: isBotPlayer ? 0.0 : 1.0, // Invisible content for bot
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 4 : 5),
                          decoration: BoxDecoration(
                            color: (isActive ? color : Colors.white).withAlpha(100),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.analytics_rounded,
                            size: isSmallScreen ? 12 : (isThreePlayers ? 13 : 15),
                            color: isActive ? color : Colors.white,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 8),
                        Text(
                          'View Stats',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 9.5 : (isThreePlayers ? 10.5 : 11.5),
                            fontWeight: FontWeight.w700,
                            color: isActive ? color : Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildQuickStat(String icon, String value, bool isActive, Color color, {
    bool isCompact = false,
    required bool isSmallScreen,
    bool isClickable = false,
  }) {
    final iconSize = isSmallScreen ? 13.0 : (isCompact ? 15.0 : 17.0);
    final valueSize = isSmallScreen ? 11.0 : (isCompact ? 12.0 : 14.0);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 3 : (isCompact ? 4 : 5),
        vertical: isSmallScreen ? 2 : (isCompact ? 3 : 4),
      ),
      decoration: isClickable ? BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(50), width: 1),
      ) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: iconSize)),
          SizedBox(height: isSmallScreen ? 1 : (isCompact ? 2 : 3)),
          Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.bold,
              color: isActive ? color : color.withAlpha(220),
            ),
          ),
        ],
      ),
    );
  }

  void _showHabitsDialog(BuildContext context, GameService game, String playerId, bool isGoodHabits) {
    final playerName = game.playerNames[playerId]!;
    final playerColor = game.playerColors[playerId]!;
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isGoodHabits ? const Color(0xFF4CAF50) : const Color(0xFFE74C3C),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    isGoodHabits ? '😊' : '😞',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 14),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: playerColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        playerName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: playerColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                Text(
                  isGoodHabits ? 'Good Habits Earned' : 'Bad Habits to Avoid',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isGoodHabits ? const Color(0xFF2E7D32) : const Color(0xFFB91C1C),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Vertical Category List
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildVerticalCategorySection(game, playerId, 'nutrition', '🎯 Nutrition', isGoodHabits),
                        const SizedBox(height: 16),
                        _buildVerticalCategorySection(game, playerId, 'exercise', '💪 Exercise', isGoodHabits),
                        const SizedBox(height: 16),
                        _buildVerticalCategorySection(game, playerId, 'sleep', '😴 Sleep', isGoodHabits),
                        const SizedBox(height: 16),
                        _buildVerticalCategorySection(game, playerId, 'mental', '🧘 Mindfulness', isGoodHabits),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isGoodHabits ? const Color(0xFF4CAF50) : const Color(0xFFE74C3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerticalCategorySection(GameService game, String playerId, String category, String title, bool isGoodHabits) {
    final habits = isGoodHabits 
        ? game.getPlayerGoodHabits(playerId, category)
        : game.getPlayerBadHabits(playerId, category);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isGoodHabits 
            ? const Color(0xFF4CAF50).withAlpha(15)
            : const Color(0xFFE74C3C).withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGoodHabits 
              ? const Color(0xFF4CAF50).withAlpha(76)
              : const Color(0xFFE74C3C).withAlpha(76),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Title
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isGoodHabits ? const Color(0xFF2E7D32) : const Color(0xFFB91C1C),
            ),
          ),
          const SizedBox(height: 10),
          
          // Habits List
          if (habits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    isGoodHabits ? '🌟' : '⚠️',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isGoodHabits ? 'No good habits earned yet' : 'No bad habits recorded yet',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...habits.map((habit) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isGoodHabits 
                    ? const Color(0xFF4CAF50).withAlpha(40)
                    : const Color(0xFFE74C3C).withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isGoodHabits ? Icons.check_circle : Icons.cancel,
                    color: isGoodHabits ? const Color(0xFF4CAF50) : const Color(0xFFE74C3C),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      habit,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2C3E50),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
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