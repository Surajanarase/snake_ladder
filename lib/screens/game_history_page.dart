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

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear History?'),
        content: const Text(
          'Are you sure you want to delete all game history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Delete all game history
      final db = await DatabaseHelper.instance.database;
      await db.delete('game_history');
      
      // Reload history
      await _loadHistory();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Game history cleared successfully'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearHistory,
              tooltip: 'Clear History',
            ),
        ],
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
                      return _buildCompactHistoryCard(_history[index]);
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

  Widget _buildCompactHistoryCard(Map<String, dynamic> game) {
    final dateTime = DateTime.parse(game['game_date']);
    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    final won = game['result'] == 'won';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: won ? const Color(0xFF4CAF50) : const Color(0xFFE74C3C),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Result, Mode, Date
            Row(
              children: [
                // Result Icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: won ? const Color(0xFF4CAF50) : const Color(0xFFE74C3C),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    won ? Icons.emoji_events : Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                
                // Result Text
                Text(
                  won ? 'Victory! 🎉' : 'Try Again 💪',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: won ? const Color(0xFF4CAF50) : const Color(0xFFE74C3C),
                  ),
                ),
                
                const Spacer(),
                
                // Game Mode Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    game['game_mode'] == 'quiz' ? '🧠 Quiz' : '📚 Knowledge',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF667eea),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Date
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Stats Row
            Row(
              children: [
                // Position (only if lost)
                if (!won)
                  Expanded(
                    child: _buildStatChip(
                      'Position',
                      '${game['player_position']}/100',
                      Icons.flag,
                      const Color(0xFF667eea),
                      isCompact: true,
                    ),
                  ),
                if (!won) const SizedBox(width: 6),
                
                // Coins
                Expanded(
                  child: _buildStatChip(
                    'Coins',
                    '+${game['coins_earned']}',
                    Icons.monetization_on,
                    const Color(0xFFF59E0B),
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: 6),
                
                // Good Habits
                Expanded(
                  child: _buildStatChip(
                    'Good',
                    '${game['good_habits']}',
                    Icons.sentiment_satisfied_alt,
                    const Color(0xFF4CAF50),
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: 6),
                
                // Bad Habits
                Expanded(
                  child: _buildStatChip(
                    'Bad',
                    '${game['bad_habits']}',
                    Icons.sentiment_dissatisfied,
                    const Color(0xFFE74C3C),
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: 6),
                
                // Quiz Score
                Expanded(
                  child: _buildStatChip(
                    'Quiz',
                    '${game['quiz_correct']}/${game['quiz_total']}',
                    Icons.quiz,
                    const Color(0xFF9C27B0),
                    isCompact: true,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Opponent Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    game['opponent_type'] == 'bot' 
                        ? Icons.smart_toy 
                        : Icons.person,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'vs ${game['opponent_type'] == 'bot' ? 'Bot' : 'Player 2'} (${game['opponent_position']}/100)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(
    String label, 
    String value, 
    IconData icon, 
    Color color, 
    {bool isCompact = false}
  ) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 6 : 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: isCompact ? 14 : 18, color: color),
          SizedBox(height: isCompact ? 2 : 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isCompact ? 11 : 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (!isCompact)
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}