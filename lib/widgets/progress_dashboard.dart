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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showAllTips(context, game),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x4D667eea),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'View Tips',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Grid layout for rewards - 2x2 uniform
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
              const SizedBox(width: 8),
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
          const SizedBox(height: 8),
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
              const SizedBox(width: 8),
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
      totalCount += list.length;
    }

    return GestureDetector(
      onTap: () => _showCategoryRewards(context, game, category, label, icon, color),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withAlpha(51),
            width: 1.5,
          ),
          boxShadow: [
            const BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
            BoxShadow(
              color: color.withAlpha(25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon and label in a row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withAlpha(38),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withAlpha(51),
                    color.withAlpha(25),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    size: 12,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$totalCount',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Hint text
            Text(
              'Tap to view',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  color.withAlpha(13),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withAlpha(51),
                        color.withAlpha(25),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Text(icon, style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(height: 12),
                Text(
                  '$label Rewards',
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Collected by players',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),

                // Show per-player lists (human players only)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (int i = 1; i <= game.numberOfPlayers; i++) ...[
                          // skip bot player when showing per-player lists
                          if (!(game.hasBot && i == game.numberOfPlayers)) ...[
                            if (i > 1) const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: game.playerColors['player$i']!.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: game.playerColors['player$i']!.withAlpha(76),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: game.playerColors['player$i']!,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        game.playerNames['player$i'] ?? 'Player $i',
                                        style: TextStyle(
                                          fontSize: 14, 
                                          fontWeight: FontWeight.bold, 
                                          color: game.playerColors['player$i']!,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Builder(builder: (ctx) {
                                    final list = game.getPlayerRewards('player$i', category);
                                    if (list.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'No rewards collected yet',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      );
                                    }
                                    return Column(
                                      children: list.map((r) {
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 6),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: color.withAlpha(51),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                size: 14,
                                                color: color,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  r,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF2C3E50),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ]
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAllTips(BuildContext context, GameService game) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.purple.shade50,
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
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x4D667eea),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text('💡', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'All Health Tips',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                    letterSpacing: 0.3,
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
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withAlpha(25),
            color.withAlpha(13),
          ],
        ),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.3,
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
                border: Border.all(color: color.withAlpha(51)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 12,
                        height: 1.4,
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
}