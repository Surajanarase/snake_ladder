// lib/screens/game_history_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class GameHistoryPage extends StatefulWidget {
  const GameHistoryPage({super.key});

  @override
  State<GameHistoryPage> createState() => _GameHistoryPageState();
}

class _GameHistoryPageState extends State<GameHistoryPage> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await DatabaseHelper.instance.getAllGameHistory();
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      return _buildHistoryCard(_history[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'No games played yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Play your first game to see history here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> game) {
    final dateTime = DateTime.parse(game['game_date']);
    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    final won = game['result'] == 'won';
    final duration = Duration(seconds: game['duration_seconds'] as int);
    final durationStr = '${duration.inMinutes}m ${duration.inSeconds % 60}s';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: won ? const Color(0xFF4CAF50) : const Color(0xFFE74C3C),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: won 
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                  : const Color(0xFFE74C3C).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: won ? const Color(0xFF4CAF50) : const Color(0xFFE74C3C),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    won ? Icons.emoji_events : Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        won ? 'Victory! 🎉' : 'Try Again 💪',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: won ? const Color(0xFF4CAF50) : const Color(0xFFE74C3C),
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    game['game_mode'] == 'quiz' ? '🧠 Quiz' : '📚 Knowledge',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF667eea),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatChip(
                        'Position',
                        '${game['player_position']}/100',
                        Icons.flag,
                        const Color(0xFF667eea),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatChip(
                        'Coins',
                        '+${game['coins_earned']}',
                        Icons.monetization_on,
                        const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatChip(
                        'Good Habits',
                        '${game['good_habits']}',
                        Icons.sentiment_satisfied_alt,
                        const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatChip(
                        'Bad Habits',
                        '${game['bad_habits']}',
                        Icons.sentiment_dissatisfied,
                        const Color(0xFFE74C3C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatChip(
                        'Quiz Score',
                        '${game['quiz_correct']}/${game['quiz_total']}',
                        Icons.quiz,
                        const Color(0xFF9C27B0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatChip(
                        'Duration',
                        durationStr,
                        Icons.timer,
                        const Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        game['opponent_type'] == 'bot' 
                            ? Icons.smart_toy 
                            : Icons.person,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'vs ${game['opponent_type'] == 'bot' ? 'Bot' : 'Player 2'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${game['opponent_position']}/100)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
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
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}