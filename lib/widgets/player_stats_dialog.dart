// lib/widgets/player_stats_dialog.dart
import 'package:flutter/material.dart';
import '../services/game_service.dart';

class PlayerStatsDialog extends StatelessWidget {
  final String playerId;
  final GameService game;

  const PlayerStatsDialog({
    super.key,
    required this.playerId,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final playerName = game.playerNames[playerId]!;
    final playerColor = game.playerColors[playerId]!;
    final position = game.playerPositions[playerId]!;
    final score = game.playerScores[playerId]!;
    final goodHabits = game.playerGoodHabits[playerId] ?? 0;
    final badHabits = game.playerBadHabits[playerId] ?? 0;

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isTablet = size.width >= 600;
    
    final maxWidth = isTablet ? 550.0 : (isSmallScreen ? size.width * 0.92 : 480.0);
    final maxHeight = isTablet ? 780.0 : (isSmallScreen ? size.height * 0.88 : 720.0);
    final padding = isTablet ? 24.0 : (isSmallScreen ? 14.0 : 18.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isTablet ? 32 : 24)),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF8F9FA),
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(isTablet ? 32 : 24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isTablet ? 32 : 24),
          child: Stack(
            children: [
              // Ambient glow effect
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        playerColor.withAlpha(25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    _buildHeader(playerName, playerColor, isTablet, isSmallScreen),
                    SizedBox(height: isTablet ? 20 : (isSmallScreen ? 12 : 16)),

                    // Game Progress Section
                    _buildPremiumSection(
                      title: 'Game Progress',
                      icon: Icons.trending_up_rounded,
                      iconColor: playerColor,
                      isTablet: isTablet,
                      isSmallScreen: isSmallScreen,
                      child: Column(
                        children: [
                          // Top Stats Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildCompactStatChip(
                                  icon: Icons.location_on_rounded,
                                  label: 'Position',
                                  value: '#$position',
                                  color: playerColor,
                                  isSmallScreen: isSmallScreen,
                                ),
                              ),
                              SizedBox(width: isSmallScreen ? 6 : 8),
                              Expanded(
                                child: _buildCompactStatChip(
                                  icon: Icons.stars_rounded,
                                  label: 'Score',
                                  value: '$score',
                                  color: const Color(0xFFFFB800),
                                  isSmallScreen: isSmallScreen,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 8),
                          // Middle Stats Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildCompactStatChip(
                                  icon: Icons.favorite_rounded,
                                  label: 'Good',
                                  value: '$goodHabits',
                                  color: const Color(0xFF4CAF50),
                                  isSmallScreen: isSmallScreen,
                                ),
                              ),
                              SizedBox(width: isSmallScreen ? 6 : 8),
                              Expanded(
                                child: _buildCompactStatChip(
                                  icon: Icons.warning_rounded,
                                  label: 'Bad',
                                  value: '$badHabits',
                                  color: const Color(0xFFEF5350),
                                  isSmallScreen: isSmallScreen,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 10),
                          // Game Actions Row
                          _buildGameActionRow(
                            icon: '🪙',
                            label: 'Coins',
                            value: '${game.playerCoins[playerId]}',
                            color: const Color(0xFFF59E0B),
                            isSmallScreen: isSmallScreen,
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 7),
                          _buildGameActionRow(
                            icon: '🪜',
                            label: 'Ladders',
                            value: '${game.playerLaddersHit[playerId]}',
                            color: const Color(0xFF4CAF50),
                            isSmallScreen: isSmallScreen,
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 7),
                          _buildGameActionRow(
                            icon: '🐍',
                            label: 'Snakes',
                            value: '${game.playerSnakesHit[playerId]}',
                            color: const Color(0xFFE74C3C),
                            isSmallScreen: isSmallScreen,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : (isSmallScreen ? 10 : 12)),

                    // Quiz Performance
                    _buildPremiumSection(
                      title: 'Quiz Performance',
                      icon: Icons.psychology_rounded,
                      iconColor: const Color(0xFF667eea),
                      isTablet: isTablet,
                      isSmallScreen: isSmallScreen,
                      child: Column(
                        children: [
                          _buildQuizStats('🎯 Nutrition', game.playerQuizStats[playerId]?['nutrition'], isSmallScreen),
                          SizedBox(height: isSmallScreen ? 6 : 7),
                          _buildQuizStats('💪 Exercise', game.playerQuizStats[playerId]?['exercise'], isSmallScreen),
                          SizedBox(height: isSmallScreen ? 6 : 7),
                          _buildQuizStats('😴 Sleep', game.playerQuizStats[playerId]?['sleep'], isSmallScreen),
                          SizedBox(height: isSmallScreen ? 6 : 7),
                          _buildQuizStats('🧘 Mindfulness', game.playerQuizStats[playerId]?['mental'], isSmallScreen),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : (isSmallScreen ? 10 : 12)),

                    // Good Habits Section
                    _buildPremiumSection(
                      title: 'Good Habits Earned',
                      icon: Icons.check_circle_rounded,
                      iconColor: const Color(0xFF4CAF50),
                      isTablet: isTablet,
                      isSmallScreen: isSmallScreen,
                      child: _buildHabitsGrid([
                        {'label': '🎯 Nutrition', 'habits': game.getPlayerGoodHabits(playerId, 'nutrition'), 'color': const Color(0xFF4CAF50)},
                        {'label': '💪 Exercise', 'habits': game.getPlayerGoodHabits(playerId, 'exercise'), 'color': const Color(0xFF2196F3)},
                        {'label': '😴 Sleep', 'habits': game.getPlayerGoodHabits(playerId, 'sleep'), 'color': const Color(0xFF9C27B0)},
                        {'label': '🧘 Mindfulness', 'habits': game.getPlayerGoodHabits(playerId, 'mental'), 'color': const Color(0xFFFF9800)},
                      ], isSmallScreen),
                    ),
                    SizedBox(height: isTablet ? 16 : (isSmallScreen ? 10 : 12)),

                    // Bad Habits Section
                    _buildPremiumSection(
                      title: 'Bad Habits to Avoid',
                      icon: Icons.block_rounded,
                      iconColor: const Color(0xFFEF5350),
                      isTablet: isTablet,
                      isSmallScreen: isSmallScreen,
                      child: _buildHabitsGrid([
                        {'label': '🎯 Nutrition', 'habits': game.getPlayerBadHabits(playerId, 'nutrition'), 'color': const Color(0xFFEF5350)},
                        {'label': '💪 Exercise', 'habits': game.getPlayerBadHabits(playerId, 'exercise'), 'color': const Color(0xFFEF5350)},
                        {'label': '😴 Sleep', 'habits': game.getPlayerBadHabits(playerId, 'sleep'), 'color': const Color(0xFFEF5350)},
                        {'label': '🧘 Mindfulness', 'habits': game.getPlayerBadHabits(playerId, 'mental'), 'color': const Color(0xFFEF5350)},
                      ], isSmallScreen),
                    ),
                    SizedBox(height: isTablet ? 20 : (isSmallScreen ? 14 : 16)),

                    // Close Button
                    _buildCloseButton(playerColor, isTablet, isSmallScreen, context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String playerName, Color playerColor, bool isTablet, bool isSmallScreen) {
    final iconSize = isTablet ? 32.0 : (isSmallScreen ? 24.0 : 28.0);
    final nameSize = isTablet ? 21.0 : (isSmallScreen ? 16.0 : 18.0);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            playerColor,
            playerColor.withAlpha(230),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 22 : 18),
        boxShadow: [
          BoxShadow(
            color: playerColor.withAlpha(100),
            blurRadius: isTablet ? 32 : 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isTablet ? 22 : 18),
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    Colors.white.withAlpha(30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 14 : 18,
              vertical: isSmallScreen ? 12 : 14,
            ),
            child: Row(
              children: [
                // Icon badge
                Container(
                  width: isSmallScreen ? 42 : 48,
                  height: isSmallScreen ? 42 : 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.white.withAlpha(80),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.insights_rounded,
                    size: iconSize,
                    color: playerColor,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playerName,
                        style: TextStyle(
                          fontSize: nameSize,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                          height: 1.2,
                          shadows: const [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 3),
                      Row(
                        children: [
                          Container(
                            width: isSmallScreen ? 3 : 4,
                            height: isSmallScreen ? 3 : 4,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 5 : 6),
                          Text(
                            'Statistics Dashboard',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 9 : 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 7 : 9,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
        border: Border.all(color: color.withAlpha(40), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: isSmallScreen ? 15 : 17),
          SizedBox(width: isSmallScreen ? 4 : 5),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 15,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1.1,
                    ),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 8 : 9,
                    fontWeight: FontWeight.w600,
                    color: color.withAlpha(180),
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameActionRow({
    required String icon,
    required String label,
    required String value,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 12,
        vertical: isSmallScreen ? 8 : 9,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(8),
        borderRadius: BorderRadius.circular(isSmallScreen ? 9 : 10),
        border: Border.all(color: color.withAlpha(35), width: 1),
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: isSmallScreen ? 18 : 20)),
          SizedBox(width: isSmallScreen ? 8 : 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 9,
              vertical: isSmallScreen ? 3 : 4,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(isSmallScreen ? 7 : 8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    required bool isTablet,
    required bool isSmallScreen,
  }) {
    final titleSize = isTablet ? 15.0 : (isSmallScreen ? 12.0 : 13.5);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 14,
              vertical: isSmallScreen ? 10 : 11,
            ),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(12),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isTablet ? 20 : 16),
                topRight: Radius.circular(isTablet ? 20 : 16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 5 : 6),
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 7 : 8),
                  ),
                  child: Icon(icon, color: iconColor, size: isSmallScreen ? 14 : 15),
                ),
                SizedBox(width: isSmallScreen ? 8 : 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      color: iconColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizStats(String categoryLabel, QuizStats? stats, bool isSmallScreen) {
    if (stats == null || stats.totalAttempts == 0) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 10 : 12,
          vertical: isSmallScreen ? 8 : 9,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(isSmallScreen ? 9 : 10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              categoryLabel,
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'Not attempted',
              style: TextStyle(
                fontSize: isSmallScreen ? 9 : 10,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    final accuracy = stats.accuracy;
    final color = accuracy >= 75
        ? const Color(0xFF4CAF50)
        : accuracy >= 50
            ? const Color(0xFFFF9800)
            : const Color(0xFFE74C3C);

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withAlpha(10),
            color.withAlpha(5),
          ],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 9 : 10),
        border: Border.all(color: color.withAlpha(45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  categoryLabel,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 9,
                  vertical: isSmallScreen ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 7 : 8),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: isSmallScreen ? 10 : 11),
                    SizedBox(width: isSmallScreen ? 3 : 4),
                    Text(
                      '${accuracy.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 6 : 7),
          Stack(
            children: [
              Container(
                height: isSmallScreen ? 5 : 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: accuracy / 100,
                child: Container(
                  height: isSmallScreen ? 5 : 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withAlpha(200)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(50),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 5 : 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${stats.correctAnswers}/${stats.totalAttempts} correct',
                style: TextStyle(
                  fontSize: isSmallScreen ? 9 : 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsGrid(List<Map<String, dynamic>> categories, bool isSmallScreen) {
    return Column(
      children: categories.asMap().entries.map((entry) {
        final isLast = entry.key == categories.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : (isSmallScreen ? 6 : 7)),
          child: _buildHabitCard(
            entry.value['label'] as String,
            entry.value['habits'] as List<String>,
            entry.value['color'] as Color,
            isSmallScreen,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHabitCard(String categoryLabel, List<String> habits, Color color, bool isSmallScreen) {
    return Container(
      constraints: BoxConstraints(minHeight: isSmallScreen ? 65 : 72),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withAlpha(8),
            color.withAlpha(4),
          ],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
        border: Border.all(color: color.withAlpha(40), width: 1.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 9 : 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 4 : 5),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 5 : 6),
                  ),
                  child: Icon(
                    Icons.circle,
                    size: isSmallScreen ? 6 : 7,
                    color: color,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 6 : 7),
                Expanded(
                  child: Text(
                    categoryLabel,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (habits.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 6 : 7,
                      vertical: isSmallScreen ? 2 : 3,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(isSmallScreen ? 7 : 8),
                    ),
                    child: Text(
                      '${habits.length}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 9 : 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 6 : 7),
            if (habits.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 5),
                  child: Text(
                    'No habits recorded yet',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 9 : 10,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...habits.take(2).map((habit) => Padding(
                    padding: EdgeInsets.only(bottom: isSmallScreen ? 4 : 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: isSmallScreen ? 11 : 12,
                          color: color,
                        ),
                        SizedBox(width: isSmallScreen ? 5 : 6),
                        Expanded(
                          child: Text(
                            habit,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 9 : 10,
                              color: Colors.grey.shade800,
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                  if (habits.length > 2)
                    Padding(
                      padding: EdgeInsets.only(top: isSmallScreen ? 2 : 3),
                      child: Text(
                        '+ ${habits.length - 2} more habits',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 8 : 9,
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton(Color playerColor, bool isTablet, bool isSmallScreen, BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [playerColor, playerColor.withAlpha(230)],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
        boxShadow: [
          BoxShadow(
            color: playerColor.withAlpha(50),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: isSmallScreen ? 16 : 18,
                ),
                SizedBox(width: isSmallScreen ? 5 : 6),
                Text(
                  'Close',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
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