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
    final actionChallenges = game.playerActionChallengesCompleted[playerId] ?? 0;
    final bonusSteps = game.playerBonusSteps[playerId] ?? 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              playerColor.withAlpha(25),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Player Avatar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [playerColor, playerColor.withAlpha(204)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: playerColor.withAlpha(102),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Text('📊', style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 16),

              // Player Name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: playerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    playerName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: playerColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Performance Statistics',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7F8C8D),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // Overall Stats Grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    _buildStatRow('🎯', 'Current Position', '$position', playerColor),
                    const Divider(height: 20),
                    _buildStatRow('⭐', 'Total Score', '$score pts', playerColor),
                    const Divider(height: 20),
                    _buildStatRow('😊', 'Good Habits', '$goodHabits', const Color(0xFF4CAF50)),
                    const Divider(height: 20),
                    _buildStatRow('😞', 'Bad Habits', '$badHabits', const Color(0xFFE74C3C)),
                    const Divider(height: 20),
                    _buildStatRow('⚡', 'Action Challenges', '$actionChallenges', const Color(0xFFFFD700)),
                    const Divider(height: 20),
                    _buildStatRow('🎁', 'Bonus Steps Earned', '$bonusSteps', const Color(0xFF2196F3)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Quiz Performance
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF667eea).withAlpha(25),
                      const Color(0xFF764ba2).withAlpha(25),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF667eea).withAlpha(76)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('🧠', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 8),
                        Text(
                          'Quiz Performance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667eea),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildQuizStats('🎯 Nutrition', game.playerQuizStats[playerId]?['nutrition']),
                    const SizedBox(height: 12),
                    _buildQuizStats('💪 Exercise', game.playerQuizStats[playerId]?['exercise']),
                    const SizedBox(height: 12),
                    _buildQuizStats('😴 Sleep', game.playerQuizStats[playerId]?['sleep']),
                    const SizedBox(height: 12),
                    _buildQuizStats('🧘 Mindfulness', game.playerQuizStats[playerId]?['mental']),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Close Button
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: playerColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(icon, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuizStats(String categoryLabel, QuizStats? stats) {
    if (stats == null || stats.totalAttempts == 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              categoryLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7F8C8D),
              ),
            ),
            const Text(
              'No quizzes yet',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF95A5A6),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withAlpha(76)),
                ),
                child: Text(
                  '${accuracy.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: accuracy / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${stats.correctAnswers}/${stats.totalAttempts}',
                style: TextStyle(
                  fontSize: 11,
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
}

// 🆕 Add this method to control_panel.dart to show player stats
