// lib/widgets/progress_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';

class ProgressDashboard extends StatelessWidget {
  const ProgressDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameService>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        border: const Border(
          top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🏆 Health Rewards',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showAllTips(context, game),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'View Tips',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildRewardTile(
                  context,
                  '🎯',
                  'Nutrition',
                  game,
                  'nutrition',
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRewardTile(
                  context,
                  '💪',
                  'Exercise',
                  game,
                  'exercise',
                  const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildRewardTile(
                  context,
                  '😴',
                  'Sleep',
                  game,
                  'sleep',
                  const Color(0xFF9C27B0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRewardTile(
                  context,
                  '🧘',
                  'Mental',
                  game,
                  'mental',
                  const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardTile(
    BuildContext context,
    String icon,
    String label,
    GameService game,
    String category,
    Color color,
  ) {
    // Count total across all players for display
    int totalCount = 0;
    for (int i = 1; i <= game.numberOfPlayers; i++) {
      final pid = 'player$i';
      final list = game.getPlayerRewards(pid, category);
      if (i == game.numberOfPlayers && game.hasBot) {
        // skip bot in the totalCount display if you prefer, but user asked "except bot" only for viewing
      }
      totalCount += list.length;
    }

    return GestureDetector(
      onTap: () => _showCategoryRewards(context, game, category, label, icon, color),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withAlpha(38),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                // Show count of rewards collected
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$totalCount collected',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Small hint text (no percent)
            Center(
              child: Text(
                'Tap to view rewards by player',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryRewards(
    BuildContext context,
    GameService game,
    String category,
    String label,
    String icon,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(38),
                    shape: BoxShape.circle,
                  ),
                  child: Text(icon, style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(height: 12),
                Text(
                  '$label Rewards',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 12),

                // Show per-player lists (human players only)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (int i = 1; i <= game.numberOfPlayers; i++) ...[
                          // skip bot player when showing per-player lists (user requested except bot)
                          if (!(game.hasBot && i == game.numberOfPlayers)) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                game.playerNames['player$i'] ?? 'Player $i',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Builder(builder: (ctx) {
                              final list = game.getPlayerRewards('player$i', category);
                              if (list.isEmpty) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: color.withAlpha(40)),
                                  ),
                                  child: Text('No rewards yet for ${game.playerNames['player$i'] ?? 'Player $i'}', style: TextStyle(color: Colors.grey.shade700)),
                                );
                              }
                              return Column(
                                children: list.map((r) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: color.withAlpha(40)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                        const SizedBox(width: 10),
                                        Expanded(child: Text(r, style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50)))),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            }),
                          ]
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  void _showAllTips(BuildContext context, GameService game) {
    // Keep the existing "View Tips" behavior (shows preexisting tips)
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '💡 All Health Tips',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTipSection('🎯', 'Nutrition', game.healthTips['nutrition']!, const Color(0xFF4CAF50)),
                        _buildTipSection('💪', 'Exercise', game.healthTips['exercise']!, const Color(0xFF2196F3)),
                        _buildTipSection('😴', 'Sleep', game.healthTips['sleep']!, const Color(0xFF9C27B0)),
                        _buildTipSection('🧘', 'Mental Health', game.healthTips['mental']!, const Color(0xFFFF9800)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTipSection(String icon, String title, List<String> tips, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final t in tips)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withAlpha(30)),
              ),
              child: Text(t, style: TextStyle(color: Colors.grey.shade800)),
            ),
        ],
      ),
    );
  }
}
